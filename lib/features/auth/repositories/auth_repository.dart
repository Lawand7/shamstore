import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

enum CheckPinFailureType {
  none,
  unauthorized,
  incorrectPin,
  forbidden,
  validation,
  network,
  server,
  unknown,
}

class CheckPinResult {
  final bool isSuccess;
  final int? statusCode;
  final String message;
  final CheckPinFailureType failureType;

  const CheckPinResult({
    required this.isSuccess,
    required this.statusCode,
    required this.message,
    required this.failureType,
  });
}

class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
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

  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.sendOtp,
        queryParameters: {'email': email},
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
        data: {'email': email, 'otp': otp},
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
        data: {
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
        data: {
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
        data: {'password': password, 'new_pin': newPin},
      );

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
            'message': data.trim().isNotEmpty ? data : 'تم تغيير رمز PIN بنجاح',
            'pin': newPin,
          };
        }

        return {'message': 'تم تغيير رمز PIN بنجاح', 'pin': newPin};
      }

      throw Exception('فشل تغيير رمز PIN. كود الخطأ: $statusCode');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<CheckPinResult> checkPin({required String walletPin}) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.checkPin,
        data: {'wallet_pin': walletPin},
      );

      final statusCode = response.statusCode;

      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        final responseMessage = response.data is String
            ? response.data.toString().trim()
            : '';

        return CheckPinResult(
          isSuccess: true,
          statusCode: statusCode,
          message: responseMessage.isNotEmpty
              ? responseMessage
              : 'تم التحقق من رمز PIN بنجاح',
          failureType: CheckPinFailureType.none,
        );
      }

      return CheckPinResult(
        isSuccess: false,
        statusCode: statusCode,
        message: 'تعذر التحقق من رمز PIN',
        failureType: CheckPinFailureType.unknown,
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;

      if (statusCode == 401) {
        return const CheckPinResult(
          isSuccess: false,
          statusCode: 401,
          message: 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول من جديد',
          failureType: CheckPinFailureType.unauthorized,
        );
      }

      if (statusCode == 403) {
        final isIncorrectPinResponse = _isIncorrectPinResponse(responseData);

        return CheckPinResult(
          isSuccess: false,
          statusCode: 403,
          message: isIncorrectPinResponse
              ? 'رمز PIN غير صحيح'
              : 'ليس لديك صلاحية لتنفيذ هذه العملية',
          failureType: isIncorrectPinResponse
              ? CheckPinFailureType.incorrectPin
              : CheckPinFailureType.forbidden,
        );
      }

      if (statusCode == 422) {
        return CheckPinResult(
          isSuccess: false,
          statusCode: 422,
          message:
              _extractWalletPinValidationError(responseData) ??
              'رمز PIN المرسل غير صالح',
          failureType: CheckPinFailureType.validation,
        );
      }

      if (_isConnectionFailure(error)) {
        return const CheckPinResult(
          isSuccess: false,
          statusCode: null,
          message:
              'تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت وحاول مرة أخرى',
          failureType: CheckPinFailureType.network,
        );
      }

      if (statusCode != null && statusCode >= 500) {
        return CheckPinResult(
          isSuccess: false,
          statusCode: statusCode,
          message: 'حدث خطأ في الخادم. حاول مرة أخرى لاحقًا',
          failureType: CheckPinFailureType.server,
        );
      }

      return CheckPinResult(
        isSuccess: false,
        statusCode: statusCode,
        message: _handleDioError(error),
        failureType: CheckPinFailureType.unknown,
      );
    } catch (_) {
      return const CheckPinResult(
        isSuccess: false,
        statusCode: null,
        message: 'حدث خطأ غير متوقع أثناء التحقق من رمز PIN',
        failureType: CheckPinFailureType.unknown,
      );
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

        return {'message': 'تم تحديث الملف الشخصي بنجاح'};
      }

      throw Exception('فشل تحديث الملف الشخصي. كود الخطأ: $statusCode');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await DioClient.dio.post(ApiConstants.logout);

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
            'message': data.trim().isNotEmpty ? data : 'تم تسجيل الخروج بنجاح',
          };
        }

        return {'message': 'تم تسجيل الخروج بنجاح'};
      }

      throw Exception('فشل تسجيل الخروج. كود الخطأ: $statusCode');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  bool _isConnectionFailure(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError;
  }

  bool _isIncorrectPinResponse(dynamic responseData) {
    String? responseMessage;

    if (responseData is String) {
      responseMessage = responseData.trim();
    } else if (responseData is Map) {
      responseMessage = responseData['message']?.toString().trim();
    }

    if (responseMessage == null || responseMessage.isEmpty) {
      return false;
    }

    return responseMessage.toLowerCase().contains('you entered wrong pin');
  }

  String? _extractWalletPinValidationError(dynamic responseData) {
    if (responseData is! Map) {
      return null;
    }

    final errors = responseData['errors'];

    if (errors is Map) {
      final walletPinErrors = errors['wallet_pin'];

      if (walletPinErrors is List && walletPinErrors.isNotEmpty) {
        final firstError = walletPinErrors.first.toString().trim();

        if (firstError.isNotEmpty) {
          return firstError;
        }
      }

      if (walletPinErrors is String && walletPinErrors.trim().isNotEmpty) {
        return walletPinErrors.trim();
      }
    }

    final message = responseData['message']?.toString().trim();

    return message != null && message.isNotEmpty ? message : null;
  }

  String _handleDioError(DioException e) {
    final responseData = e.response?.data;
    final backendMessage = responseData is Map
        ? responseData['message']?.toString().trim() ?? ''
        : responseData?.toString().trim() ?? '';

    if (backendMessage.contains('No query results for model') &&
        backendMessage.contains('User')) {
      return 'لا يوجد حساب مسجل بهذا البريد الإلكتروني';
    }

    if (e.response?.statusCode == 401) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول من جديد';
    }

    if (e.response?.statusCode == 422) {
      return backendMessage.isNotEmpty
          ? backendMessage
          : 'البيانات المرسلة غير صحيحة';
    }

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

    if (e.response?.statusCode == 404) {
      return 'الرابط غير موجود في Laravel';
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
