import 'package:dio/dio.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/core/network/dio_client.dart';

class AdsPageResult {
  final List<Map<String, dynamic>> ads;
  final int currentPage;
  final int lastPage;

  const AdsPageResult({
    required this.ads,
    required this.currentPage,
    required this.lastPage,
  });
}

class AdvertisementRepository {
  static const Set<String> _allowedStatuses = {
    'pending',
    'approved',
    'declined',
  };

  Future<AdsPageResult> getMyAdsByStatus({
    required String status,
    int page = 1,
  }) async {
    final cleanStatus = status.trim().toLowerCase();

    if (!_allowedStatuses.contains(cleanStatus)) {
      throw Exception('حالة الإعلان غير صحيحة');
    }

    try {
      final response = await DioClient.dio.get(
        ApiConstants.myAds,
        queryParameters: {'status': cleanStatus, 'page': page},
      );

      final responseData = response.data;
      if (responseData is! Map) {
        throw Exception('صيغة استجابة الإعلانات غير متوقعة');
      }

      final map = Map<String, dynamic>.from(responseData);
      final rawTransactions = map['transactions'];
      final List<dynamic> rawAds;

      if (rawTransactions is List) {
        rawAds = rawTransactions;
      } else if (rawTransactions is Map && rawTransactions['data'] is List) {
        rawAds = rawTransactions['data'] as List<dynamic>;
      } else {
        throw Exception('لم يتم العثور على قائمة الإعلانات في الاستجابة');
      }

      final ads = rawAds
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((ad) => _toInt(ad['id']) > 0)
          .toList();

      final pagination = map['pagination'];
      final paginationMap = pagination is Map
          ? Map<String, dynamic>.from(pagination)
          : const <String, dynamic>{};

      return AdsPageResult(
        ads: ads,
        currentPage: _toInt(paginationMap['current_page'], fallback: page),
        lastPage: _toInt(paginationMap['last_page'], fallback: 1),
      );
    } on DioException catch (error) {
      throw Exception(_handleDioError(error));
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> createAd({
    required String title,
    required String phoneNumber,
    required String description,
    required String governorate,
    required double amount,
  }) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.createAd,
        data: {
          'title': title.trim(),
          'phone_number': phoneNumber.trim(),
          'description': description.trim(),
          'governorate': governorate,
          'amount': amount,
        },
      );

      final responseData = response.data;
      if (responseData is String && responseData.trim().isNotEmpty) {
        return responseData.trim();
      }
      if (responseData is Map && responseData['message'] != null) {
        return responseData['message'].toString();
      }

      return 'تم إنشاء الإعلان وهو قيد المراجعة';
    } on DioException catch (error) {
      throw Exception(_handleCreateAdError(error));
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> deleteAd(int adId) async {
    if (adId <= 0) {
      throw Exception('معرّف الإعلان غير صحيح');
    }

    try {
      final response = await DioClient.dio.delete(ApiConstants.deleteAd(adId));
      final responseData = response.data;

      if (responseData is String && responseData.trim().isNotEmpty) {
        return responseData.trim();
      }
      if (responseData is Map && responseData['message'] != null) {
        return responseData['message'].toString();
      }

      return 'تم حذف الإعلان بنجاح';
    } on DioException catch (error) {
      throw Exception(_handleDeleteAdError(error));
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _handleDioError(DioException error) {
    switch (error.response?.statusCode) {
      case 401:
        return 'انتهت الجلسة، يرجى تسجيل الدخول من جديد';
      case 403:
        return 'لا تملك صلاحية عرض هذه الإعلانات';
      case 422:
        return 'حالة الإعلان المطلوبة غير صحيحة';
      case 500:
        return 'تعذر تحميل الإعلانات بسبب خطأ في الخادم';
    }

    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'تعذر الاتصال بالخادم لتحميل الإعلانات';
      default:
        return 'تعذر تحميل الإعلانات';
    }
  }

  String _handleCreateAdError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    if (statusCode == 401) {
      return 'انتهت الجلسة، يرجى تسجيل الدخول من جديد';
    }
    if (statusCode == 403) {
      if (responseData is String && responseData.trim().isNotEmpty) {
        return responseData.trim();
      }
      if (responseData is Map && responseData['message'] != null) {
        return responseData['message'].toString();
      }
      return 'لا يمكن إنشاء الإعلان بهذه الجلسة';
    }
    if (statusCode == 422) {
      if (responseData is Map && responseData['errors'] is Map) {
        final errors = responseData['errors'] as Map;
        final firstError = errors.values
            .expand((value) => value is List ? value : [value])
            .firstWhere(
              (value) => value != null && value.toString().trim().isNotEmpty,
              orElse: () => null,
            );
        if (firstError != null) {
          return firstError.toString();
        }
      }
      return 'تحقق من بيانات الإعلان المدخلة';
    }
    if (statusCode == 500) {
      return 'تعذر إنشاء الإعلان بسبب خطأ في الخادم';
    }

    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'تعذر الاتصال بالخادم لإنشاء الإعلان';
      default:
        return 'تعذر إنشاء الإعلان';
    }
  }

  String _handleDeleteAdError(DioException error) {
    final responseData = error.response?.data;

    if (error.response?.statusCode == 401) {
      return 'انتهت الجلسة، يرجى تسجيل الدخول من جديد';
    }
    if (error.response?.statusCode == 403) {
      return 'لا تملك صلاحية حذف هذا الإعلان';
    }
    if (error.response?.statusCode == 400) {
      if (responseData is String && responseData.trim().isNotEmpty) {
        return responseData.trim();
      }
      if (responseData is Map && responseData['message'] != null) {
        return responseData['message'].toString();
      }
      return 'لا يمكنك حذف هذا الإعلان';
    }
    if (error.response?.statusCode == 404) {
      return 'الإعلان غير موجود';
    }
    if (error.response?.statusCode == 500) {
      return 'تعذر حذف الإعلان بسبب خطأ في الخادم';
    }

    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'تعذر الاتصال بالخادم لحذف الإعلان';
      default:
        return 'تعذر حذف الإعلان';
    }
  }
}
