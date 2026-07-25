import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:shamstore/core/storage/token_storage.dart';
import 'package:shamstore/features/auth/repositories/auth_repository.dart';
import 'package:shamstore/features/notifications/controllers/notifications_controller.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.login(
        email: email.trim(),
        password: password,
      );

      if (kDebugMode) {
        debugPrint('========== LOGIN RESPONSE ==========');
        debugPrint(result.toString());
        debugPrint('====================================');
      }

      final token = _readFirstString(result, const ['token', 'access_token']);

      if (token == null || token.isEmpty) {
        errorMessage.value =
            'لم يتم العثور على رمز تسجيل الدخول في استجابة السيرفر';
        return false;
      }

      /*
       * هذه الخطوة تمسح كاش الحساب السابق فقط.
       * لا تحذف إشعارات أو بيانات من Laravel.
       */
      await _resetPreviousLocalAccount();

      final userMap = _extractUserMap(result);
      final profileMap = _extractProfileMap(result);

      await TokenStorage.saveToken(token);
      await TokenStorage.saveUserEmail(email);

      final role = _readFirstString(userMap ?? result, const [
        'role',
        'user_role',
      ]);

      if (role != null) {
        await TokenStorage.saveUserRole(role);
      }

      final userId = _toInt(
        userMap?['id'] ??
            userMap?['user_id'] ??
            result['user_id'] ??
            result['id'],
      );

      if (userId != null) {
        await TokenStorage.saveUserId(userId);
      }

      /*
       * بعض استجابات الباك تضع بيانات الملف الشخصي داخل profile،
       * وبعضها قد يضعها مباشرة داخل user؛ لذلك نقرأ من الاثنين.
       */
      final profileSource = <String, dynamic>{
        if (userMap != null) ...userMap,
        if (profileMap != null) ...profileMap,
      };

      await TokenStorage.saveProfileData(
        firstName: _readFirstString(profileSource, const [
          'first_name',
          'firstname',
        ]),
        lastName: _readFirstString(profileSource, const [
          'last_name',
          'lastname',
        ]),
        governorate: _readFirstString(profileSource, const [
          'governorate',
          'city',
        ]),
        dateOfBirth: _readFirstString(profileSource, const [
          'date_of_birth',
          'birth_date',
        ]),
        profileImageUrl: _readFirstString(profileSource, const [
          'profile_image_url',
          'profile_image',
          'image',
          'avatar',
        ]),
        identityImageUrl: _readFirstString(profileSource, const [
          'identity_image_url',
          'identity_image',
          'identity_imag',
        ]),
        replaceExisting: true,
      );

      if (kDebugMode) {
        debugPrint('========== SAVED LOGIN DATA ==========');
        debugPrint('Token saved: ${TokenStorage.getToken() != null}');
        debugPrint('Email: ${TokenStorage.getUserEmail()}');
        debugPrint('User ID: ${TokenStorage.getUserId()}');
        debugPrint('Role: ${TokenStorage.getUserRole()}');
        debugPrint('Display name: ${TokenStorage.getDisplayName()}');
        debugPrint('DOB: ${TokenStorage.getProfileDateOfBirth()}');
        debugPrint('Governorate: ${TokenStorage.getProfileGovernorate()}');
        debugPrint('Profile image: ${TokenStorage.getProfileImageUrl()}');
        debugPrint('Identity image: ${TokenStorage.getIdentityImageUrl()}');
        debugPrint('======================================');
      }

      return true;
    } catch (error) {
      errorMessage.value = _cleanErrorMessage(error);

      if (kDebugMode) {
        debugPrint('Login error: $error');
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _resetPreviousLocalAccount() async {
    if (Get.isRegistered<NotificationsController>()) {
      final controller = Get.find<NotificationsController>();

      controller.notifications.clear();
      controller.currentPage.value = 1;
      controller.lastPage.value = 1;
      controller.total.value = 0;

      Get.delete<NotificationsController>(force: true);
    }

    await TokenStorage.clear();
  }

  Map<String, dynamic>? _extractUserMap(Map<String, dynamic> response) {
    final directUser = _asMap(response['user']);

    if (directUser != null) {
      return directUser;
    }

    final data = _asMap(response['data']);

    if (data == null) {
      return null;
    }

    return _asMap(data['user']) ?? data;
  }

  Map<String, dynamic>? _extractProfileMap(Map<String, dynamic> response) {
    final directProfile = _asMap(response['profile']);

    if (directProfile != null) {
      return directProfile;
    }

    final data = _asMap(response['data']);

    if (data != null) {
      final dataProfile = _asMap(data['profile']);

      if (dataProfile != null) {
        return dataProfile;
      }

      final dataUser = _asMap(data['user']);
      final nestedProfile = _asMap(dataUser?['profile']);

      if (nestedProfile != null) {
        return nestedProfile;
      }
    }

    final directUser = _asMap(response['user']);

    return _asMap(directUser?['profile']);
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  String? _readFirstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      final text = value?.toString().trim() ?? '';

      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }

    return null;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString().trim();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length).trim();
    }

    if (message.isEmpty) {
      return 'حدث خطأ غير متوقع أثناء تسجيل الدخول';
    }

    return message;
  }
}
