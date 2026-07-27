import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

class SupportQuestionsResult {
  final List<Map<String, dynamic>> questions;
  final int currentPage;
  final int lastPage;

  const SupportQuestionsResult({
    required this.questions,
    required this.currentPage,
    required this.lastPage,
  });
}

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

  Future<SupportQuestionsResult> getMyQuestionsByStatus({
    required String status,
    int page = 1,
  }) async {
    const allowedStatuses = {'pending', 'answered'};
    final cleanStatus = status.trim().toLowerCase();

    if (!allowedStatuses.contains(cleanStatus)) {
      throw Exception('حالة طلب الدعم غير صحيحة');
    }

    try {
      final response = await DioClient.dio.post(
        ApiConstants.myQuestions,
        data: {'status': cleanStatus},
        queryParameters: {'page': page},
      );

      final responseData = response.data;
      if (responseData is! Map) {
        throw Exception('صيغة استجابة طلبات الدعم غير متوقعة');
      }

      final map = Map<String, dynamic>.from(responseData);
      final rawQuestions = map['questions'];
      final List<dynamic> items;

      if (rawQuestions is List) {
        items = rawQuestions;
      } else if (rawQuestions is Map && rawQuestions['data'] is List) {
        items = rawQuestions['data'] as List<dynamic>;
      } else {
        throw Exception('لم يتم العثور على طلبات الدعم');
      }

      final questions = items
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) => _toInt(item['id']) > 0)
          .toList();

      final pagination = map['pagination'];
      final paginationMap = pagination is Map
          ? Map<String, dynamic>.from(pagination)
          : const <String, dynamic>{};

      return SupportQuestionsResult(
        questions: questions,
        currentPage: _toInt(paginationMap['current_page'], fallback: page),
        lastPage: _toInt(paginationMap['last_page'], fallback: 1),
      );
    } on DioException catch (error) {
      throw Exception(_handleQuestionsError(error));
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
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

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _handleQuestionsError(DioException error) {
    final responseData = error.response?.data;

    if (error.response?.statusCode == 401) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول من جديد';
    }
    if (error.response?.statusCode == 403) {
      return 'ليس لديك صلاحية عرض طلبات الدعم';
    }
    if (error.response?.statusCode == 422) {
      return 'حالة طلب الدعم غير صحيحة';
    }
    if (error.response?.statusCode == 500) {
      return 'حدث خطأ داخلي في الخادم. حاول مرة أخرى';
    }
    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData.trim();
    }

    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت وحاول مرة أخرى';
      default:
        return 'تعذر تحميل طلبات الدعم. حاول مرة أخرى';
    }
  }
}
