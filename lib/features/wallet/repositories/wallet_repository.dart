import 'package:dio/dio.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/core/network/dio_client.dart';
import 'package:shamstore/features/wallet/models/wallet_transaction_model.dart';

class WalletTransactionsResult {
  const WalletTransactionsResult({
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
  });

  final List<WalletTransactionModel> transactions;
  final int currentPage;
  final int lastPage;
}

class WalletRepository {
  Future<double> getBalance() async {
    try {
      final response = await DioClient.dio.get(ApiConstants.myBalance);
      final responseData = response.data;

      if (responseData is! Map) {
        throw Exception('صيغة استجابة رصيد المحفظة غير صحيحة');
      }

      final rawBalance = responseData['WalletBalance'];
      final parsedBalance = rawBalance is num
          ? rawBalance.toDouble()
          : double.tryParse(rawBalance?.toString() ?? '');

      if (parsedBalance == null) {
        throw Exception('قيمة رصيد المحفظة غير موجودة في الاستجابة');
      }

      return parsedBalance;
    } on DioException catch (error) {
      throw Exception(_handleWalletError(error));
    } on Exception {
      rethrow;
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> deposit({
    required String transferNumber,
    required String amount,
  }) async {
    final cleanTransferNumber = transferNumber.trim();
    final cleanAmount = amount.trim();

    if (cleanTransferNumber.isEmpty) {
      throw Exception('رقم عملية التحويل مطلوب');
    }
    final parsedAmount = num.tryParse(cleanAmount);
    if (parsedAmount == null || parsedAmount <= 0) {
      throw Exception('أدخل مبلغ شحن صحيحًا أكبر من الصفر');
    }

    try {
      final response = await DioClient.dio.post(
        ApiConstants.deposit,
        data: {'transfer_number': cleanTransferNumber, 'amount': cleanAmount},
      );
      final responseData = response.data;

      if (responseData is String && responseData.trim().isNotEmpty) {
        return responseData.trim();
      }
      if (responseData is Map && responseData['message'] != null) {
        return responseData['message'].toString();
      }

      return 'تم إرسال طلب الشحن وهو قيد المراجعة';
    } on DioException catch (error) {
      throw Exception(_handleDepositError(error));
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> withdraw({
    required String amount,
    required String shamCashNumber,
  }) async {
    final cleanAmount = amount.trim().replaceAll(',', '');
    final cleanShamCashNumber = shamCashNumber.trim();
    final parsedAmount = num.tryParse(cleanAmount);

    if (parsedAmount == null || parsedAmount <= 0) {
      throw Exception('أدخل مبلغ سحب صحيحًا أكبر من الصفر');
    }
    if (!RegExp(r'^\d+$').hasMatch(cleanShamCashNumber)) {
      throw Exception('أدخل رقم حساب ShamCash صحيحًا');
    }

    try {
      final response = await DioClient.dio.post(
        ApiConstants.withdraw,
        data: {'amount': cleanAmount, 'shamcash_number': cleanShamCashNumber},
      );

      return _extractMessage(
        response.data,
        fallback: 'تم إرسال طلب السحب وهو قيد المراجعة',
      );
    } on DioException catch (error) {
      throw Exception(_handleWalletError(error));
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<WalletTransactionsResult> getTransactionsByStatus({
    required String status,
    int page = 1,
  }) async {
    final normalizedStatus = status.trim().toLowerCase();
    if (normalizedStatus != 'pending' && normalizedStatus != 'completed') {
      throw Exception('حالة عملية المحفظة غير صحيحة');
    }

    try {
      final response = await DioClient.dio.get(
        ApiConstants.myTransactions,
        queryParameters: {'status': normalizedStatus, 'page': page},
      );
      final rawTransactions = _findTransactions(response.data);
      final pagination = _findPagination(response.data);

      if (rawTransactions == null) {
        throw Exception('صيغة استجابة عمليات المحفظة غير صحيحة');
      }

      final transactions = rawTransactions
          .whereType<Map>()
          .map(
            (item) => WalletTransactionModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((transaction) => transaction.id > 0)
          .toList();

      return WalletTransactionsResult(
        transactions: transactions,
        currentPage: _toInt(pagination?['current_page'], fallback: page),
        lastPage: _toInt(pagination?['last_page'], fallback: page),
      );
    } on DioException catch (error) {
      throw Exception(_handleWalletError(error));
    } on Exception {
      rethrow;
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  String _handleDepositError(DioException error) {
    final responseData = error.response?.data;

    if (error.response?.statusCode == 401) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول من جديد';
    }
    if (error.response?.statusCode == 403) {
      return 'طلب شحن المحفظة متاح لحساب الزبون فقط';
    }
    if (error.response?.statusCode == 422) {
      if (responseData is Map && responseData['errors'] is Map) {
        final errors = responseData['errors'] as Map;
        for (final key in ['amount', 'transfer_number']) {
          final fieldErrors = errors[key];
          if (fieldErrors is List && fieldErrors.isNotEmpty) {
            return fieldErrors.first.toString();
          }
        }
      }
      return 'بيانات طلب شحن المحفظة غير صحيحة';
    }
    if (error.response?.statusCode == 500) {
      return 'تعذر إرسال طلب الشحن بسبب خطأ في الخادم';
    }

    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'تعذر الاتصال بالخادم. تحقق من الإنترنت وحاول مجددًا';
      default:
        return 'تعذر إرسال طلب شحن المحفظة';
    }
  }

  List<dynamic>? _findTransactions(dynamic value) {
    if (value is List) return value;
    if (value is! Map) return null;

    final map = Map<String, dynamic>.from(value);
    for (final key in ['transactions', 'data', 'items', 'results']) {
      final result = _findTransactions(map[key]);
      if (result != null) return result;
    }

    return null;
  }

  Map<String, dynamic>? _findPagination(dynamic value) {
    if (value is! Map) return null;

    final map = Map<String, dynamic>.from(value);
    if (map['pagination'] is Map) {
      return Map<String, dynamic>.from(map['pagination'] as Map);
    }
    if (map.containsKey('current_page') && map.containsKey('last_page')) {
      return map;
    }

    for (final key in ['transactions', 'data']) {
      final pagination = _findPagination(map[key]);
      if (pagination != null) return pagination;
    }

    return null;
  }

  int _toInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _extractMessage(dynamic value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value is Map && value['message'] != null) {
      final message = value['message'].toString().trim();
      if (message.isNotEmpty) return message;
    }
    return fallback;
  }

  String _handleWalletError(DioException error) {
    final responseData = error.response?.data;
    final backendMessage = _extractMessage(responseData, fallback: '');

    if (error.response?.statusCode == 401) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول من جديد';
    }
    if (error.response?.statusCode == 403) {
      if (backendMessage.toLowerCase().contains('enough money')) {
        return 'الرصيد غير كافٍ لتنفيذ عملية السحب مع العمولة';
      }
      return backendMessage.isNotEmpty
          ? backendMessage
          : 'غير مصرح بتنفيذ العملية';
    }
    if (error.response?.statusCode == 422) {
      if (responseData is Map && responseData['errors'] is Map) {
        final errors = responseData['errors'] as Map;
        for (final key in ['amount', 'shamcash_number', 'status']) {
          final fieldErrors = errors[key];
          if (fieldErrors is List && fieldErrors.isNotEmpty) {
            return fieldErrors.first.toString();
          }
        }
      }
      return backendMessage.isNotEmpty
          ? backendMessage
          : 'بيانات عملية المحفظة غير صحيحة';
    }
    if (error.response?.statusCode == 500) {
      return 'تعذر تنفيذ عملية المحفظة بسبب خطأ في الخادم';
    }

    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'تعذر الاتصال بالخادم. تحقق من الإنترنت وحاول مجددًا';
      default:
        return backendMessage.isNotEmpty
            ? backendMessage
            : 'تعذر تنفيذ عملية المحفظة';
    }
  }
}
