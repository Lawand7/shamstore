import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/core/network/dio_client.dart';
import 'package:shamstore/features/notifications/models/app_notification_model.dart';

class NotificationsPageResult {
  final List<AppNotificationModel> notifications;
  final int currentPage;
  final int lastPage;
  final int total;

  const NotificationsPageResult({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;
}

class NotificationsRepository {
  Future<NotificationsPageResult> getNotifications({int page = 1}) async {
    if (page <= 0) {
      throw Exception('رقم صفحة الإشعارات غير صالح');
    }

    try {
      final response = await DioClient.dio.get(
        ApiConstants.notifications,
        queryParameters: {'page': page},
      );

      if (kDebugMode) {
        debugPrint('========== NOTIFICATIONS RESPONSE ==========');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Requested Page: $page');
        debugPrint('Data: ${response.data}');
        debugPrint('============================================');
      }

      if (response.data is! Map) {
        throw Exception('صيغة استجابة الإشعارات غير صحيحة');
      }

      final map = Map<String, dynamic>.from(response.data as Map);
      final rawItems = map['data'];

      if (rawItems is! List) {
        throw Exception('قائمة الإشعارات غير موجودة في الاستجابة');
      }

      final notifications = rawItems
          .whereType<Map>()
          .map(
            (item) =>
                AppNotificationModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((item) => item.id > 0)
          .toList();

      return NotificationsPageResult(
        notifications: notifications,
        currentPage: _toInt(map['current_page'], fallback: page),
        lastPage: _toInt(map['last_page'], fallback: page),
        total: _toInt(map['total'], fallback: notifications.length),
      );
    } on DioException catch (error) {
      _debugDioError(operation: 'GET NOTIFICATIONS', error: error);
      throw Exception(_handleDioError(error));
    } on Exception {
      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected notifications error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      throw Exception('حدث خطأ غير متوقع أثناء تحميل الإشعارات');
    }
  }

  Future<AppNotificationModel?> markAsRead({
    required int notificationId,
  }) async {
    if (notificationId <= 0) {
      throw Exception('رقم الإشعار غير صالح');
    }

    try {
      final response = await DioClient.dio.put(
        ApiConstants.markNotificationAsRead(notificationId),
      );

      if (kDebugMode) {
        debugPrint('========== MARK NOTIFICATION AS READ ==========');
        debugPrint('Notification ID: $notificationId');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Data: ${response.data}');
        debugPrint('===============================================');
      }

      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        final data = map['data'];

        if (data is Map) {
          return AppNotificationModel.fromJson(Map<String, dynamic>.from(data));
        }
      }

      return null;
    } on DioException catch (error) {
      _debugDioError(operation: 'MARK NOTIFICATION AS READ', error: error);
      throw Exception(_handleDioError(error));
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }

      throw Exception('تعذر تعليم الإشعار كمقروء');
    }
  }

  Future<String> deleteNotification({required int notificationId}) async {
    if (notificationId <= 0) {
      throw Exception('رقم الإشعار غير صالح');
    }

    try {
      final response = await DioClient.dio.delete(
        ApiConstants.deleteNotification(notificationId),
      );

      if (kDebugMode) {
        debugPrint('========== DELETE NOTIFICATION ==========');
        debugPrint('Notification ID: $notificationId');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Data: ${response.data}');
        debugPrint('=========================================');
      }

      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        final message = map['message']?.toString().trim();

        if (message != null && message.isNotEmpty) {
          return message;
        }
      }

      return 'تم حذف الإشعار بنجاح';
    } on DioException catch (error) {
      _debugDioError(operation: 'DELETE NOTIFICATION', error: error);
      throw Exception(_handleDioError(error));
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }

      throw Exception('تعذر حذف الإشعار');
    }
  }

  int _toInt(dynamic value, {required int fallback}) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _handleDioError(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      final map = Map<String, dynamic>.from(responseData);
      final message = map['message']?.toString().trim();

      if (message != null && message.isNotEmpty) {
        if (message.toLowerCase().contains('unauthorized')) {
          return 'لا تملك صلاحية تنفيذ هذه العملية';
        }

        if (message.toLowerCase().contains('not found')) {
          return 'الإشعار المطلوب غير موجود';
        }

        return message;
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'انتهت مهلة الاتصال بالسيرفر';

      case DioExceptionType.connectionError:
        return 'تعذر الاتصال بالسيرفر';

      case DioExceptionType.cancel:
        return 'تم إلغاء العملية';

      case DioExceptionType.badCertificate:
        return 'شهادة اتصال السيرفر غير صالحة';

      case DioExceptionType.transformTimeout:
        return 'استغرقت معالجة الاستجابة وقتاً طويلاً';

      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    switch (error.response?.statusCode) {
      case 401:
        return 'انتهت جلسة تسجيل الدخول، سجّل الدخول مجدداً';

      case 403:
        return 'لا تملك صلاحية تنفيذ هذه العملية';

      case 404:
        return 'الإشعار المطلوب غير موجود';

      case 422:
        return 'البيانات المرسلة غير صحيحة';

      case 500:
      case 502:
      case 503:
        return 'حدث خطأ في السيرفر أثناء تنفيذ العملية';

      default:
        return 'فشل تنفيذ العملية';
    }
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
