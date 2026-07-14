import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:shamstore/core/network/dio_client.dart';

class OtpController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString errorMessage = ''.obs;

  Map<String, dynamic>? lastVerifyRegisterResponse;

  Future<bool> sendOtp({required String email}) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = await DioClient.dio.post(
        '/otp/send',
        queryParameters: {'email': email},
      );

      debugPrint('========== SEND OTP RESPONSE ==========');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('=======================================');

      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } on DioException catch (e) {
      errorMessage.value = _handleDioError(e);

      debugPrint('========== SEND OTP ERROR ==========');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Data: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('====================================');

      return false;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Unexpected send OTP error: $e');
      return false;
    } finally {
      isSending.value = false;
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      lastVerifyRegisterResponse = null;

      final response = await DioClient.dio.post(
        '/verifyRegister',
        queryParameters: {'email': email, 'otp': otp},
      );

      debugPrint('========== VERIFY REGISTER RESPONSE ==========');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Type: ${response.data.runtimeType}');
      debugPrint('==============================================');

      if (response.data is Map<String, dynamic>) {
        lastVerifyRegisterResponse = response.data as Map<String, dynamic>;
      }

      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } on DioException catch (e) {
      lastVerifyRegisterResponse = null;
      errorMessage.value = _handleDioError(e);

      debugPrint('========== VERIFY REGISTER ERROR ==========');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Data: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('===========================================');

      return false;
    } catch (e) {
      lastVerifyRegisterResponse = null;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Unexpected verify register error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _handleDioError(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        return data['message'].toString();
      }

      if (data['error'] != null) {
        return data['error'].toString();
      }

      if (data['errors'] != null) {
        return data['errors'].toString();
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return 'انتهت مهلة الاتصال بالسيرفر';
    }

    if (e.type == DioExceptionType.receiveTimeout) {
      return 'السيرفر تأخر في إرسال الاستجابة';
    }

    if (e.type == DioExceptionType.sendTimeout) {
      return 'انتهت مهلة إرسال الطلب';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'تعذر الاتصال بالسيرفر. تأكد أن Laravel يعمل وأن adb reverse مفعّل';
    }

    if (e.response?.statusCode == 400) {
      return 'رمز التحقق غير صحيح أو الطلب غير صالح';
    }

    if (e.response?.statusCode == 401) {
      return 'غير مصرح';
    }

    if (e.response?.statusCode == 404) {
      return 'رابط التحقق غير موجود في Laravel';
    }

    if (e.response?.statusCode == 422) {
      return 'بيانات التحقق غير صحيحة';
    }

    if (e.response?.statusCode == 500) {
      return 'خطأ داخلي في السيرفر';
    }

    return 'حدث خطأ أثناء تنفيذ الطلب';
  }
}
