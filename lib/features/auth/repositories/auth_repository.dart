import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.login,
        queryParameters: {
          'email': email,
          'password': password,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('صيغة استجابة تسجيل الدخول غير متوقعة');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (_) {
      throw Exception('حدث خطأ غير متوقع أثناء تسجيل الدخول');
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String dateOfBirth,
    required String firstName,
    required String lastName,
    required String governorate,
    required String walletPin,
    required String fcmToken,
    required String profileImagePath,
    String? identityImagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
        'date_of_birth': dateOfBirth,
        'first_name': firstName,
        'last_name': lastName,
        'governorate': governorate,
        'wallet_pin': walletPin,
        'token': fcmToken,
        'profile_image': await MultipartFile.fromFile(profileImagePath),
        if (role == 'seller' && identityImagePath != null)
          'identity_image': await MultipartFile.fromFile(identityImagePath),
      });

      final response = await DioClient.dio.post(
        ApiConstants.register,
        data: formData,
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('صيغة استجابة إنشاء الحساب غير متوقعة');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (_) {
      throw Exception('حدث خطأ غير متوقع أثناء إنشاء الحساب');
    }
  }

  Future<Map<String, dynamic>> sendOtp({
    required String email,
  }) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.sendOtp,
        queryParameters: {
          'email': email,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('صيغة استجابة إرسال رمز التحقق غير متوقعة');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (_) {
      throw Exception('حدث خطأ غير متوقع أثناء إرسال رمز التحقق');
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.verifyOtp,
        queryParameters: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('صيغة استجابة التحقق من الرمز غير متوقعة');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (_) {
      throw Exception('حدث خطأ غير متوقع أثناء التحقق من الرمز');
    }
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.forgotPassword,
        queryParameters: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('صيغة استجابة استعادة كلمة المرور غير متوقعة');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (_) {
      throw Exception('حدث خطأ غير متوقع أثناء استعادة كلمة المرور');
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.changePassword,
        queryParameters: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('صيغة استجابة تغيير كلمة المرور غير متوقعة');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (_) {
      throw Exception('حدث خطأ غير متوقع أثناء تغيير كلمة المرور');
    }
  }

  Future<Map<String, dynamic>> changePin({
    required String password,
    required String newPin,
  }) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.changePin,
        queryParameters: {
          'password': password,
          'new_pin': newPin,
        },
      );

      debugPrint('========== CHANGE PIN RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('=============================================');

      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          return data;
        }

        if (data is List) {
          return {
            'message': data.isNotEmpty
                ? data[0].toString()
                : 'تم تغيير رمز PIN بنجاح',
            'pin': data.length > 1 ? data[1].toString() : newPin,
          };
        }

        if (data is String) {
          return {
            'message': data.trim().isNotEmpty
                ? data
                : 'تم تغيير رمز PIN بنجاح',
            'pin': newPin,
          };
        }

        return {
          'message': 'تم تغيير رمز PIN بنجاح',
          'pin': newPin,
        };
      }

      throw Exception('فشل تغيير رمز PIN. كود الخطأ: $statusCode');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected change PIN error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String governorate,
    String? profileImagePath,
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        'first_name': firstName,
        'last_name': lastName,
        'date_of_birth': dateOfBirth,
        'governorate': governorate,
      };

      if (profileImagePath != null && profileImagePath.trim().isNotEmpty) {
        formMap['profile_image'] = await MultipartFile.fromFile(
          profileImagePath,
        );
      }

      final formData = FormData.fromMap(formMap);

      final response = await DioClient.dio.post(
        ApiConstants.updateProfile,
        data: formData,
      );

      debugPrint('========== UPDATE PROFILE RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('=================================================');

      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }

        if (response.data is String) {
          return {
            'message': response.data.toString().trim().isNotEmpty
                ? response.data.toString()
                : 'تم تحديث الملف الشخصي بنجاح',
          };
        }

        return {
          'message': 'تم تحديث الملف الشخصي بنجاح',
        };
      }

      throw Exception('فشل تحديث الملف الشخصي. كود الخطأ: $statusCode');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected update profile error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await DioClient.dio.post(ApiConstants.logout);

      debugPrint('========== LOGOUT RAW RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('=========================================');

      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          return data;
        }

        if (data is List) {
          return {
            'message': data.isNotEmpty
                ? data[0].toString()
                : 'تم تسجيل الخروج بنجاح',
          };
        }

        if (data is String) {
          return {
            'message': data.trim().isNotEmpty
                ? data
                : 'تم تسجيل الخروج بنجاح',
          };
        }

        return {
          'message': 'تم تسجيل الخروج بنجاح',
        };
      }

      throw Exception('فشل تسجيل الخروج. كود الخطأ: $statusCode');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      debugPrint('Unexpected logout error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  String _handleDioError(DioException e) {
    final responseData = e.response?.data;

    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] != null) {
        return responseData['message'].toString();
      }

      if (responseData['error'] != null) {
        return responseData['error'].toString();
      }

      if (responseData['errors'] != null) {
        return responseData['errors'].toString();
      }
    }

    if (responseData is List && responseData.isNotEmpty) {
      return responseData.first.toString();
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData;
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
      return 'تعذر الاتصال بالسيرفر. تأكد أن Laravel يعمل وأن الهاتف متصل بشكل صحيح';
    }

    if (e.response?.statusCode == 401) {
      return 'غير مصرح. يرجى تسجيل الدخول من جديد';
    }

    if (e.response?.statusCode == 404) {
      return 'الرابط غير موجود في Laravel';
    }

    if (e.response?.statusCode == 422) {
      return responseData is Map<String, dynamic> &&
              responseData['message'] != null
          ? responseData['message'].toString()
          : 'البيانات المرسلة غير صحيحة';
    }

    if (e.response?.statusCode == 500) {
      return 'خطأ داخلي في السيرفر';
    }

    if (e.response?.statusCode != null) {
      return 'فشل الطلب. كود الخطأ: ${e.response?.statusCode}';
    }

    return 'فشل الاتصال بالسيرفر';
  }
}