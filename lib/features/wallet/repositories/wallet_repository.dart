import 'package:dio/dio.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/core/network/dio_client.dart';

class WalletRepository {
  Future<String> deposit({required String transferNumber}) async {
    final cleanTransferNumber = transferNumber.trim();
    if (cleanTransferNumber.isEmpty) {
      throw Exception('رقم عملية التحويل مطلوب');
    }

    try {
      final response = await DioClient.dio.post(
        ApiConstants.deposit,
        data: {'transfer_number': cleanTransferNumber},
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
        final transferErrors = errors['transfer_number'];
        if (transferErrors is List && transferErrors.isNotEmpty) {
          return transferErrors.first.toString();
        }
      }
      return 'رقم عملية التحويل غير صحيح';
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
}
