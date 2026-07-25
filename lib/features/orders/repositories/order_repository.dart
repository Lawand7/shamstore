import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/core/network/dio_client.dart';

class PlaceOrderResult {
  final int orderId;
  final String message;
  final Map<String, dynamic> orderData;

  const PlaceOrderResult({
    required this.orderId,
    required this.message,
    required this.orderData,
  });
}

class OrderRepository {
  Future<PlaceOrderResult> placeOrder({
    required int productId,
    required int quantity,
    required String phone,
    required String address,
  }) async {
    final cleanPhone = phone.trim();
    final cleanAddress = address.trim();

    _validateOrderData(
      productId: productId,
      quantity: quantity,
      phone: cleanPhone,
      address: cleanAddress,
    );

    try {
      final response = await DioClient.dio.post(
        ApiConstants.storeOrder,
        data: {
          'product_id': productId,
          'quantity': quantity,
          'phone': cleanPhone,
          'address': cleanAddress,
        },
      );

      if (kDebugMode) {
        debugPrint('========== PLACE ORDER RESPONSE ==========');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Data: ${response.data}');
        debugPrint('==========================================');
      }

      final responseData = _convertToMap(response.data);

      /*
       * يعالج مشكلة الباك الحالية:
       *
       * السيرفر قد يعيد 201 Created، لكن داخل data يوجد:
       *
       * {
       *   "original": {
       *     "message": "Insufficient wallet balance."
       *   }
       * }
       *
       * لذلك لا نعتمد على statusCode وحده.
       */
      _throwIfNestedBackendError(responseData);

      final rawOrderData = responseData['data'];

      if (rawOrderData is! Map) {
        throw Exception(
          'تم إرسال الطلب، لكن السيرفر لم يرجع بيانات الطلب بشكل صحيح',
        );
      }

      final orderData = Map<String, dynamic>.from(rawOrderData);

      final orderId = _toInt(orderData['id']);

      if (orderId <= 0) {
        throw Exception('تم إرسال الطلب، لكن السيرفر لم يرجع رقم الطلب');
      }

      final message = responseData['message']?.toString().trim();

      return PlaceOrderResult(
        orderId: orderId,
        message: message != null && message.isNotEmpty
            ? _translateBackendMessage(message)
            : 'تم إنشاء الطلب بنجاح',
        orderData: orderData,
      );
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint('========== PLACE ORDER ERROR ==========');
        debugPrint('Type: ${error.type}');
        debugPrint('Status Code: ${error.response?.statusCode}');
        debugPrint('Response Data: ${error.response?.data}');
        debugPrint('Message: ${error.message}');
        debugPrint('=======================================');
      }

      throw Exception(_handleDioError(error));
    } on Exception {
      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected place-order error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      throw Exception('حدث خطأ غير متوقع أثناء إنشاء الطلب');
    }
  }

  void _validateOrderData({
    required int productId,
    required int quantity,
    required String phone,
    required String address,
  }) {
    if (productId <= 0) {
      throw Exception('رقم المنتج غير صالح');
    }

    if (quantity <= 0) {
      throw Exception('يجب أن تكون الكمية المطلوبة أكبر من صفر');
    }

    if (phone.isEmpty) {
      throw Exception('يرجى إدخال رقم الهاتف');
    }

    if (address.isEmpty) {
      throw Exception('يرجى إدخال عنوان التوصيل');
    }
  }

  Map<String, dynamic> _convertToMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw Exception('صيغة استجابة إنشاء الطلب غير صحيحة');
  }

  void _throwIfNestedBackendError(Map<String, dynamic> responseData) {
    final nestedData = responseData['data'];

    if (nestedData is! Map) {
      return;
    }

    final nestedMap = Map<String, dynamic>.from(nestedData);
    final original = nestedMap['original'];

    if (original is! Map) {
      return;
    }

    final originalMap = Map<String, dynamic>.from(original);

    final message = _extractMessage(originalMap);

    if (message != null && message.isNotEmpty) {
      throw Exception(_translateBackendMessage(message));
    }

    final validationError = _extractValidationError(originalMap);

    if (validationError != null && validationError.isNotEmpty) {
      throw Exception(_translateBackendMessage(validationError));
    }

    throw Exception('فشل إنشاء الطلب بسبب خطأ صادر من السيرفر');
  }

  String _handleDioError(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      final data = Map<String, dynamic>.from(responseData);

      final nestedError = _extractNestedError(data);

      if (nestedError != null && nestedError.isNotEmpty) {
        return _translateBackendMessage(nestedError);
      }

      final message = _extractMessage(data);

      if (message != null && message.isNotEmpty) {
        return _translateBackendMessage(message);
      }

      final validationError = _extractValidationError(data);

      if (validationError != null && validationError.isNotEmpty) {
        return _translateBackendMessage(validationError);
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال بالسيرفر';

      case DioExceptionType.sendTimeout:
        return 'تعذر إرسال بيانات الطلب إلى السيرفر';

      case DioExceptionType.receiveTimeout:
        return 'تأخر السيرفر في إرسال الاستجابة';

      case DioExceptionType.transformTimeout:
        return 'استغرق السيرفر وقتاً طويلاً في معالجة الاستجابة';

      case DioExceptionType.connectionError:
        return 'تعذر الاتصال بالسيرفر، تحقق من تشغيل Laravel والاتصال بالشبكة';

      case DioExceptionType.cancel:
        return 'تم إلغاء عملية إنشاء الطلب';

      case DioExceptionType.badCertificate:
        return 'شهادة اتصال السيرفر غير صالحة';

      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    switch (error.response?.statusCode) {
      case 400:
        return 'طلب إنشاء الطلب غير صحيح';

      case 401:
        return 'انتهت جلسة تسجيل الدخول، يرجى تسجيل الدخول مجدداً';

      case 403:
        return 'لا تملك صلاحية تنفيذ هذه العملية';

      case 404:
        return 'المنتج أو مسار إنشاء الطلب غير موجود';

      case 409:
        return 'تعذر إنشاء الطلب بسبب تعارض في البيانات';

      case 422:
        return 'تحقق من الكمية ورقم الهاتف وعنوان التوصيل';

      case 429:
        return 'تم إرسال عدد كبير من الطلبات، حاول بعد قليل';

      case 500:
      case 502:
      case 503:
        return 'يوجد خطأ في السيرفر، حاول مرة أخرى لاحقاً';

      default:
        return 'فشل إنشاء الطلب';
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

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return null;
  }

  String _translateBackendMessage(String message) {
    final normalizedMessage = message.trim().toLowerCase();

    if (normalizedMessage.contains('insufficient wallet balance') ||
        normalizedMessage.contains('not enough money') ||
        normalizedMessage.contains('enough balance')) {
      return 'رصيد المحفظة غير كافٍ لإتمام الطلب';
    }

    if (normalizedMessage.contains('units available') ||
        normalizedMessage.contains('quantity is not available') ||
        normalizedMessage.contains('not enough stock') ||
        normalizedMessage.contains('out of stock')) {
      return 'الكمية المطلوبة أكبر من الكمية المتوفرة';
    }

    if (normalizedMessage.contains('product not found')) {
      return 'المنتج المطلوب غير موجود';
    }

    if (normalizedMessage.contains('unauthenticated')) {
      return 'انتهت جلسة تسجيل الدخول، يرجى تسجيل الدخول مجدداً';
    }

    if (normalizedMessage.contains('phone') &&
        normalizedMessage.contains('required')) {
      return 'رقم الهاتف مطلوب';
    }

    if (normalizedMessage.contains('address') &&
        normalizedMessage.contains('required')) {
      return 'عنوان التوصيل مطلوب';
    }

    if (normalizedMessage.contains('quantity') &&
        normalizedMessage.contains('required')) {
      return 'الكمية المطلوبة غير محددة';
    }

    if (normalizedMessage.contains('product_id') &&
        normalizedMessage.contains('required')) {
      return 'رقم المنتج مطلوب';
    }

    return message.trim();
  }

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }
}
