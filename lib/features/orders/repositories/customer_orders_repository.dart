import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/core/network/dio_client.dart';
import 'package:shamstore/features/orders/models/customer_order_model.dart';

class CustomerOrdersRepository {
  Future<List<CustomerOrderModel>> getOrders({required String status}) async {
    final normalizedStatus = status.trim().toLowerCase();

    if (normalizedStatus != 'pending' && normalizedStatus != 'complete') {
      throw Exception('حالة الطلب غير صحيحة');
    }

    try {
      final response = await DioClient.dio.get(
        ApiConstants.customerOrders,
        queryParameters: {'status': normalizedStatus},
      );

      if (kDebugMode) {
        debugPrint('========== CUSTOMER ORDERS RESPONSE ==========');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Requested Status: $normalizedStatus');
        debugPrint('Data: ${response.data}');
        debugPrint('==============================================');
      }

      final rawOrders = _extractOrdersList(response.data);

      final orders = rawOrders
          .whereType<Map>()
          .map(
            (item) =>
                CustomerOrderModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((order) => order.id > 0)
          .toList();

      if (normalizedStatus == 'complete') {
        orders.sort(_compareCompletedOrdersNewestFirst);
      }

      return orders;
    } on DioException catch (error) {
      _debugDioError(operation: 'GET CUSTOMER ORDERS', error: error);

      throw Exception(_handleDioError(error));
    } on Exception {
      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected customer-orders error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      throw Exception('حدث خطأ غير متوقع أثناء تحميل الطلبات');
    }
  }

  Future<String> confirmOrder({required int orderId}) async {
    if (orderId <= 0) {
      throw Exception('رقم الطلب غير صالح');
    }

    return _executePostAction(
      operation: 'CONFIRM ORDER',
      path: ApiConstants.confirmOrder(orderId),
      fallbackMessage: 'تم تأكيد استلام الطلب بنجاح',
    );
  }

  Future<String> reportOrder({
    required int orderId,
    required String description,
  }) async {
    final cleanDescription = description.trim();

    if (orderId <= 0) {
      throw Exception('رقم الطلب غير صالح');
    }

    if (cleanDescription.isEmpty) {
      throw Exception('يرجى كتابة تفاصيل المشكلة');
    }

    if (cleanDescription.length < 5) {
      throw Exception('وصف المشكلة قصير جداً');
    }

    return _executePostAction(
      operation: 'REPORT ORDER',
      path: ApiConstants.reportOrder(orderId),
      queryParameters: {'description': cleanDescription},
      fallbackMessage: 'تم إرسال البلاغ إلى الإدارة بنجاح',
    );
  }

  Future<String> rateSeller({required int orderId, required int value}) async {
    if (orderId <= 0) {
      throw Exception('تعذر تحديد الطلب المرتبط بهذا التقييم');
    }

    if (value < 1 || value > 5) {
      throw Exception('يجب أن يكون التقييم من نجمة إلى خمس نجوم');
    }

    return _executePostAction(
      operation: 'RATE SELLER',
      path: ApiConstants.rateSeller,
      data: {'order_id': orderId, 'value': value},
      fallbackMessage: 'تم إرسال تقييم البائع بنجاح',
    );
  }

  Future<String> _executePostAction({
    required String operation,
    required String path,
    required String fallbackMessage,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await DioClient.dio.post(
        path,
        queryParameters: queryParameters,
        data: data,
      );

      if (kDebugMode) {
        debugPrint('========== $operation RESPONSE ==========');
        debugPrint('Path: $path');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Query Parameters: $queryParameters');
        debugPrint('Request Data: $data');
        debugPrint('Response Data: ${response.data}');
        debugPrint('=========================================');
      }

      // يعالج خطأ الباك المتداخل:
      // 200 أو 201 مع data.original.message.
      _throwIfNestedBackendError(response.data);

      final message = _extractSuccessMessage(response.data);

      if (message == null || message.isEmpty) {
        return fallbackMessage;
      }

      return _translateBackendMessage(message, fallback: fallbackMessage);
    } on DioException catch (error) {
      _debugDioError(operation: operation, error: error);

      throw Exception(_handleDioError(error));
    } on Exception {
      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected $operation error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      throw Exception('حدث خطأ غير متوقع أثناء تنفيذ العملية');
    }
  }

  List<dynamic> _extractOrdersList(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }

    if (responseData is Map) {
      final map = Map<String, dynamic>.from(responseData);

      final possibleLists = [map['data'], map['orders'], map['results']];

      for (final value in possibleLists) {
        if (value is List) {
          return value;
        }
      }

      final message = _extractMessage(map);

      if (message != null) {
        throw Exception(_translateBackendMessage(message));
      }
    }

    throw Exception('صيغة استجابة الطلبات غير صحيحة');
  }

  void _throwIfNestedBackendError(dynamic responseData) {
    if (responseData is! Map) {
      return;
    }

    final responseMap = Map<String, dynamic>.from(responseData);

    final nestedData = responseMap['data'];

    if (nestedData is! Map) {
      return;
    }

    final nestedMap = Map<String, dynamic>.from(nestedData);

    final original = nestedMap['original'];

    if (original is! Map) {
      return;
    }

    final originalMap = Map<String, dynamic>.from(original);

    final message =
        _extractMessage(originalMap) ?? _extractValidationError(originalMap);

    if (message != null && message.isNotEmpty) {
      throw Exception(_translateBackendMessage(message));
    }

    throw Exception('فشل تنفيذ العملية بسبب خطأ صادر من السيرفر');
  }

  String? _extractSuccessMessage(dynamic responseData) {
    if (responseData is String) {
      final result = responseData.trim();
      return result.isEmpty ? null : result;
    }

    if (responseData is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(responseData);

    final directMessage = _extractMessage(map);

    if (directMessage != null) {
      return directMessage;
    }

    final data = map['data'];

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    if (data is Map) {
      return _extractMessage(Map<String, dynamic>.from(data));
    }

    return null;
  }

  String? _extractMessage(Map<String, dynamic> data) {
    final message = data['message'];

    if (message == null) {
      return null;
    }

    final result = message.toString().trim();

    return result.isEmpty ? null : result;
  }

  String? _extractValidationError(Map<String, dynamic> data) {
    final errors = data['errors'];

    if (errors is! Map || errors.isEmpty) {
      return null;
    }

    for (final value in errors.values) {
      if (value is List && value.isNotEmpty) {
        return value.first.toString().trim();
      }

      final text = value?.toString().trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  String _handleDioError(DioException error) {
    final responseData = error.response?.data;

    if (responseData is String && responseData.trim().isNotEmpty) {
      return _translateBackendMessage(responseData.trim());
    }

    if (responseData is Map) {
      final data = Map<String, dynamic>.from(responseData);

      final nestedMessage = _extractNestedError(data);

      if (nestedMessage != null) {
        return _translateBackendMessage(nestedMessage);
      }

      final message = _extractMessage(data);

      if (message != null) {
        return _translateBackendMessage(message);
      }

      final validationError = _extractValidationError(data);

      if (validationError != null) {
        return _translateBackendMessage(validationError);
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال بالسيرفر';

      case DioExceptionType.sendTimeout:
        return 'تعذر إرسال البيانات إلى السيرفر';

      case DioExceptionType.receiveTimeout:
        return 'تأخر السيرفر في إرسال الاستجابة';

      case DioExceptionType.transformTimeout:
        return 'استغرقت معالجة استجابة السيرفر وقتاً طويلاً';

      case DioExceptionType.connectionError:
        return 'تعذر الاتصال بالسيرفر';

      case DioExceptionType.cancel:
        return 'تم إلغاء العملية';

      case DioExceptionType.badCertificate:
        return 'شهادة اتصال السيرفر غير صالحة';

      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    switch (error.response?.statusCode) {
      case 400:
        return 'البيانات المرسلة غير صحيحة';

      case 401:
        return 'انتهت جلسة تسجيل الدخول، سجّل الدخول مجدداً';

      case 403:
        return 'لا تملك صلاحية تنفيذ هذه العملية';

      case 404:
        return 'الطلب أو المسار المطلوب غير موجود';

      case 409:
        return 'لا يمكن تنفيذ العملية على الطلب بحالته الحالية';

      case 422:
        return 'تحقق من البيانات المدخلة';

      case 500:
      case 502:
      case 503:
        return 'حدث خطأ في السيرفر أثناء تنفيذ العملية';

      default:
        return 'فشل تنفيذ العملية';
    }
  }

  String? _extractNestedError(Map<String, dynamic> data) {
    final nestedData = data['data'];

    if (nestedData is! Map) {
      return null;
    }

    final nestedMap = Map<String, dynamic>.from(nestedData);

    final original = nestedMap['original'];

    if (original is! Map) {
      return null;
    }

    final originalMap = Map<String, dynamic>.from(original);

    return _extractMessage(originalMap) ?? _extractValidationError(originalMap);
  }

  String _translateBackendMessage(String message, {String? fallback}) {
    final normalized = message.trim().toLowerCase();

    if (normalized.contains('unauthenticated')) {
      return 'انتهت جلسة تسجيل الدخول، سجّل الدخول مجدداً';
    }

    if (normalized.contains('order not found')) {
      return 'الطلب المطلوب غير موجود';
    }

    if (normalized.contains('already been rated') ||
        normalized.contains('already rated')) {
      return 'سبق أن قيّمت هذا المنتج، ولا يمكن تقييمه مرة ثانية';
    }

    if (normalized.contains('only completed orders can be rated')) {
      return 'لا يمكن تقييم البائع قبل اكتمال الطلب';
    }

    if (normalized.contains('does not belong to the authenticated customer')) {
      return 'لا يمكنك تقييم طلب لا يخص حسابك';
    }

    if (normalized.contains('already completed') ||
        normalized.contains('already complete')) {
      return 'تم تأكيد هذا الطلب مسبقاً';
    }

    if (normalized.contains('not shipped') ||
        normalized.contains('has not been shipped')) {
      return 'لا يمكن تأكيد الطلب قبل أن يقوم البائع بشحنه';
    }

    if (normalized.contains('report') && normalized.contains('success')) {
      return 'تم إرسال البلاغ إلى الإدارة بنجاح';
    }

    if (normalized.contains('rate') && normalized.contains('success')) {
      return 'تم إرسال تقييم البائع بنجاح';
    }

    if (normalized.contains('rating') && normalized.contains('success')) {
      return 'تم إرسال تقييم البائع بنجاح';
    }

    if (normalized.contains('confirm') && normalized.contains('success')) {
      return 'تم تأكيد استلام الطلب بنجاح';
    }

    if (normalized.contains('completed successfully')) {
      return 'تم تأكيد استلام الطلب بنجاح';
    }

    if (normalized == 'success' && fallback != null) {
      return fallback;
    }

    return message.trim();
  }

  int _compareCompletedOrdersNewestFirst(
    CustomerOrderModel first,
    CustomerOrderModel second,
  ) {
    final DateTime? firstDate = _completionDate(first);
    final DateTime? secondDate = _completionDate(second);

    if (firstDate != null && secondDate != null) {
      final int dateComparison = secondDate.compareTo(firstDate);

      if (dateComparison != 0) {
        return dateComparison;
      }
    } else if (firstDate != null) {
      return -1;
    } else if (secondDate != null) {
      return 1;
    }

    return second.id.compareTo(first.id);
  }

  DateTime? _completionDate(CustomerOrderModel order) {
    final dynamic rawDate =
        order.rawData['completed_at'] ??
        order.rawData['updated_at'] ??
        order.rawData['created_at'] ??
        order.createdAt;

    return DateTime.tryParse(rawDate?.toString().trim() ?? '');
  }

  void _debugDioError({
    required String operation,
    required DioException error,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('========== $operation ERROR ==========');
    debugPrint('Type: ${error.type}');
    debugPrint('Status Code: ${error.response?.statusCode}');
    debugPrint('Response Data: ${error.response?.data}');
    debugPrint('Message: ${error.message}');
    debugPrint('======================================');
  }
}
