import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/core/network/dio_client.dart';
import 'package:shamstore/features/seller/models/seller_order_model.dart';

class SellerOrdersRepository {
  Future<int> getCompletedOrdersCount() async {
    try {
      final Response<dynamic> response = await DioClient.dio.get(
        ApiConstants.sellerCompletedOrdersCount,
      );

      if (kDebugMode) {
        debugPrint('========== COMPLETED ORDERS COUNT RESPONSE ==========');
        debugPrint('Status code: ${response.statusCode}');
        debugPrint('=====================================================');
      }

      _throwIfNestedBackendError(response.data);

      final int? count = _findCompletedOrdersCount(response.data);

      if (count == null || count < 0) {
        throw Exception('صيغة استجابة عدد الطلبات المكتملة غير صحيحة');
      }

      return count;
    } on DioException catch (error) {
      _printDioError(operation: 'LOAD COMPLETED ORDERS COUNT', error: error);

      throw Exception(_handleDioError(error));
    } on Exception {
      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected completed-orders-count error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      throw Exception('حدث خطأ غير متوقع أثناء تحميل عدد الطلبات المكتملة');
    }
  }

  Future<List<SellerOrderModel>> getOrders({required String status}) async {
    final String normalizedStatus = status.trim().toLowerCase();

    if (normalizedStatus != 'pending' && normalizedStatus != 'complete') {
      throw Exception('حالة الطلب غير صحيحة');
    }

    try {
      final Response<dynamic> response = await DioClient.dio.get(
        ApiConstants.sellerOrders,
        queryParameters: {'status': normalizedStatus},
      );

      if (kDebugMode) {
        debugPrint('========== SELLER ORDERS RESPONSE ==========');
        debugPrint('Requested status: $normalizedStatus');
        debugPrint('Status code: ${response.statusCode}');
        debugPrint('Response data: ${response.data}');
        debugPrint('============================================');
      }

      _throwIfNestedBackendError(response.data);

      final List<dynamic> rawOrders = _extractOrdersList(response.data);

      final orders = rawOrders
          .whereType<Map>()
          .map(
            (dynamic item) => SellerOrderModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .where((SellerOrderModel order) => order.id > 0)
          .toList();

      if (normalizedStatus == 'complete') {
        orders.sort(_compareCompletedOrdersNewestFirst);
      }

      return orders;
    } on DioException catch (error) {
      _printDioError(operation: 'LOAD SELLER ORDERS', error: error);

      throw Exception(_handleDioError(error));
    } on Exception {
      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected seller-orders error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      throw Exception('حدث خطأ غير متوقع أثناء تحميل طلبات البائع');
    }
  }

  Future<String> rejectOrder({required int orderId}) async {
    if (orderId <= 0) {
      throw Exception('معرّف الطلب غير صالح');
    }

    try {
      final Response<dynamic> response = await DioClient.dio.delete(
        ApiConstants.rejectSellerOrder(orderId),
      );

      if (kDebugMode) {
        debugPrint('========== REJECT SELLER ORDER RESPONSE ==========');
        debugPrint('Order id: $orderId');
        debugPrint('Status code: ${response.statusCode}');
        debugPrint('Response data: ${response.data}');
        debugPrint('==================================================');
      }

      _throwIfNestedBackendError(response.data);

      return _extractSuccessMessage(
        response.data,
        fallback: 'تم رفض الطلب بنجاح',
      );
    } on DioException catch (error) {
      _printDioError(operation: 'REJECT SELLER ORDER', error: error);

      throw Exception(_handleDioError(error));
    } on Exception {
      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected reject-order error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      throw Exception('حدث خطأ غير متوقع أثناء رفض الطلب');
    }
  }

  Future<String> shipOrder({
    required int orderId,
    required String period,
    required String imagePath,
  }) async {
    if (orderId <= 0) {
      throw Exception('معرّف الطلب غير صالح');
    }

    final String normalizedPeriod = period.trim();
    final String normalizedImagePath = imagePath.trim();

    if (normalizedPeriod.isEmpty) {
      throw Exception('مدة الشحن مطلوبة');
    }

    if (normalizedImagePath.isEmpty) {
      throw Exception('صورة إثبات الشحن مطلوبة');
    }

    try {
      final FormData formData = FormData.fromMap({
        'period': normalizedPeriod,
        'image': await MultipartFile.fromFile(
          normalizedImagePath,
          filename: normalizedImagePath.replaceAll(r'\', '/').split('/').last,
        ),
      });

      final Response<dynamic> response = await DioClient.dio.post(
        ApiConstants.shipSellerOrder(orderId),
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );

      if (kDebugMode) {
        debugPrint('========== SHIP SELLER ORDER RESPONSE ==========');
        debugPrint('Order id: $orderId');
        debugPrint('Period: $normalizedPeriod');
        debugPrint('Status code: ${response.statusCode}');
        debugPrint('Response data: ${response.data}');
        debugPrint('================================================');
      }

      _throwIfNestedBackendError(response.data);

      return _extractSuccessMessage(
        response.data,
        fallback: 'تم إرسال معلومات الشحن بنجاح',
      );
    } on DioException catch (error) {
      _printDioError(operation: 'SHIP SELLER ORDER', error: error);

      throw Exception(_handleDioError(error));
    } on Exception {
      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected ship-order error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      throw Exception('حدث خطأ غير متوقع أثناء شحن الطلب');
    }
  }

  List<dynamic> _extractOrdersList(dynamic responseData) {
    final List<dynamic>? result = _findOrdersList(responseData);

    if (result != null) {
      return result;
    }

    final String? message = _findMessage(responseData);

    if (message != null && message.trim().isNotEmpty) {
      throw Exception(_translateMessage(message));
    }

    throw Exception('صيغة استجابة طلبات البائع غير صحيحة');
  }

  List<dynamic>? _findOrdersList(dynamic value) {
    if (value is List) {
      return value;
    }

    if (value is! Map) {
      return null;
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(value);

    const List<String> possibleKeys = [
      'data',
      'orders',
      'results',
      'items',
      'original',
    ];

    for (final String key in possibleKeys) {
      final dynamic nestedValue = map[key];

      if (nestedValue is List) {
        return nestedValue;
      }

      if (nestedValue is Map) {
        final List<dynamic>? nestedResult = _findOrdersList(nestedValue);

        if (nestedResult != null) {
          return nestedResult;
        }
      }
    }

    return null;
  }

  void _throwIfNestedBackendError(dynamic responseData) {
    if (responseData is! Map) {
      return;
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(responseData);

    final dynamic successValue = map['success'];
    final dynamic statusValue = map['status'];

    if (successValue == false ||
        statusValue == false ||
        statusValue?.toString().toLowerCase() == 'error' ||
        statusValue?.toString().toLowerCase() == 'failed') {
      final String message = _findMessage(map) ?? 'فشلت العملية في السيرفر';

      throw Exception(_translateMessage(message));
    }

    final dynamic originalValue = map['original'];

    if (originalValue is Map) {
      final Map<String, dynamic> original = Map<String, dynamic>.from(
        originalValue,
      );

      final dynamic originalSuccess = original['success'];
      final dynamic originalStatus = original['status'];
      final int? originalStatusCode = _toNullableInt(
        original['status_code'] ?? original['statusCode'] ?? original['code'],
      );

      final bool hasErrorStatus =
          originalSuccess == false ||
          originalStatus == false ||
          originalStatus?.toString().toLowerCase() == 'error' ||
          originalStatus?.toString().toLowerCase() == 'failed' ||
          (originalStatusCode != null && originalStatusCode >= 400);

      if (hasErrorStatus) {
        final String message =
            _findMessage(original) ?? 'فشلت العملية في السيرفر';

        throw Exception(_translateMessage(message));
      }
    }

    final dynamic dataValue = map['data'];

    if (dataValue is Map) {
      _throwIfNestedBackendError(dataValue);
    }
  }

  String _extractSuccessMessage(
    dynamic responseData, {
    required String fallback,
  }) {
    final String? message = _findMessage(responseData);

    if (message == null || message.trim().isEmpty) {
      return fallback;
    }

    return _translateMessage(message);
  }

  String? _findMessage(dynamic value) {
    if (value is String) {
      final String message = value.trim();
      return message.isEmpty ? null : message;
    }

    if (value is! Map) {
      return null;
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(value);

    const List<String> directMessageKeys = [
      'message',
      'error',
      'detail',
      'description',
    ];

    for (final String key in directMessageKeys) {
      final dynamic directValue = map[key];

      if (directValue is String && directValue.trim().isNotEmpty) {
        return directValue.trim();
      }
    }

    const List<String> nestedKeys = ['data', 'original', 'errors'];

    for (final String key in nestedKeys) {
      final String? nestedMessage = _findMessage(map[key]);

      if (nestedMessage != null) {
        return nestedMessage;
      }
    }

    return null;
  }

  String _handleDioError(DioException error) {
    final String? backendMessage = _findMessage(error.response?.data);

    if (backendMessage != null) {
      return _translateMessage(backendMessage);
    }

    final int? statusCode = error.response?.statusCode;

    switch (statusCode) {
      case 400:
        return 'البيانات المرسلة غير صحيحة';
      case 401:
        return 'انتهت جلسة تسجيل الدخول، سجّل الدخول مجدداً';
      case 403:
        return 'هذا الحساب لا يملك صلاحية تنفيذ العملية';
      case 404:
        return 'الطلب أو مسار العملية غير موجود';
      case 409:
        return 'لا يمكن تنفيذ العملية على الطلب بحالته الحالية';
      case 413:
        return 'حجم صورة الشحن أكبر من الحد المسموح';
      case 422:
        return 'تحقق من مدة الشحن وصورة إثبات الشحن';
      case 500:
      case 502:
      case 503:
        return 'حدث خطأ في السيرفر أثناء تنفيذ العملية';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال بالسيرفر';
      case DioExceptionType.sendTimeout:
        return 'تعذر إرسال الطلب إلى السيرفر';
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
        return 'فشل تنفيذ العملية';
    }
  }

  String _translateMessage(String message) {
    final String normalized = message.trim().toLowerCase();

    if (normalized.contains('unauthenticated')) {
      return 'انتهت جلسة تسجيل الدخول، سجّل الدخول مجدداً';
    }

    if (normalized.contains('seller not found') ||
        normalized.contains('no seller')) {
      return 'تعذر العثور على حساب البائع';
    }

    if (normalized.contains('order not found') ||
        normalized.contains('no order')) {
      return 'تعذر العثور على الطلب';
    }

    if (normalized.contains('unauthorized') ||
        normalized.contains('forbidden')) {
      return 'لا تملك صلاحية تنفيذ هذه العملية';
    }

    if (normalized.contains('already shipped')) {
      return 'تم شحن هذا الطلب مسبقاً';
    }

    if (normalized.contains('already rejected')) {
      return 'تم رفض هذا الطلب مسبقاً';
    }

    if (normalized.contains('invalid status')) {
      return 'لا يمكن تنفيذ العملية على الطلب بحالته الحالية';
    }

    if (normalized.contains('image') &&
        (normalized.contains('required') || normalized.contains('missing'))) {
      return 'صورة إثبات الشحن مطلوبة';
    }

    if (normalized.contains('period') &&
        (normalized.contains('required') || normalized.contains('missing'))) {
      return 'مدة الشحن مطلوبة';
    }

    if (normalized.contains('no orders') ||
        normalized.contains('orders not found')) {
      return 'لا توجد طلبات بهذه الحالة';
    }

    return message.trim();
  }

  int? _toNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString().trim());
  }

  int? _findCompletedOrdersCount(dynamic value) {
    final int? directCount = _toNullableInt(value);

    if (directCount != null) {
      return directCount;
    }

    if (value is! Map) {
      return null;
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(value);
    final int? completedCount = _toNullableInt(map['completed_orders']);

    if (completedCount != null) {
      return completedCount;
    }

    const List<String> nestedKeys = ['data', 'original'];

    for (final String key in nestedKeys) {
      final int? nestedCount = _findCompletedOrdersCount(map[key]);

      if (nestedCount != null) {
        return nestedCount;
      }
    }

    return null;
  }

  int _compareCompletedOrdersNewestFirst(
    SellerOrderModel first,
    SellerOrderModel second,
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

  DateTime? _completionDate(SellerOrderModel order) {
    final dynamic rawDate =
        order.rawData['completed_at'] ??
        order.rawData['updated_at'] ??
        order.rawData['created_at'] ??
        order.createdAt;

    return DateTime.tryParse(rawDate?.toString().trim() ?? '');
  }

  void _printDioError({
    required String operation,
    required DioException error,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('========== $operation ERROR ==========');
    debugPrint('Type: ${error.type}');
    debugPrint('Status code: ${error.response?.statusCode}');
    debugPrint('Response data: ${error.response?.data}');
    debugPrint('Message: ${error.message}');
    debugPrint('======================================');
  }
}
