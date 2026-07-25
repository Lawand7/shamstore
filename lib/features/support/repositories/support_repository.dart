import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

class SupportRepository {
  Future<void> sendQuestion({
    required String subject,
    required String question,
  }) async {
    try {
      await DioClient.dio.post(
        ApiConstants.askQuestion,
        data: {'subject': subject, 'question': question},
      );
    } on DioException catch (error) {
      throw Exception(_handleDioError(error));
    } catch (_) {
      throw Exception('حدث خطأ غير متوقع أثناء إرسال طلب الدعم');
    }
  }

  String _handleDioError(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      final errors = responseData['errors'];

      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final firstError = value.first.toString().trim();

            if (firstError.isNotEmpty) {
              return firstError;
            }
          }

          final errorText = value.toString().trim();

          if (errorText.isNotEmpty) {
            return errorText;
          }
        }
      }

      final message = responseData['message']?.toString().trim();

      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData.trim();
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت وحاول مرة أخرى';
    }

    switch (error.response?.statusCode) {
      case 401:
        return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول من جديد';
      case 403:
        return 'ليس لديك صلاحية لإرسال طلب دعم';
      case 422:
        return 'بيانات طلب الدعم غير صحيحة';
      case 500:
        return 'حدث خطأ داخلي في الخادم. حاول مرة أخرى';
    }

    return 'تعذر إرسال طلب الدعم. حاول مرة أخرى';
  }
}
