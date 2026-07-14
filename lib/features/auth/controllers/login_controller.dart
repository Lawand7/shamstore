import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/storage/token_storage.dart';
import '../repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      debugPrint('========== LOGIN RESPONSE ==========');
      debugPrint(result.toString());
      debugPrint('====================================');

      final token = _readString(result, 'token') ??
          _readString(result, 'access_token');

      if (token == null || token.isEmpty) {
        errorMessage.value = 'لم يتم العثور على التوكن في استجابة السيرفر';
        return false;
      }

      await TokenStorage.saveToken(token);
      await TokenStorage.saveUserEmail(email);

      final userMap = _extractUserMap(result);
      final profileMap = _extractProfileMap(result);

      final role = userMap != null
          ? _readString(userMap, 'role')
          : _readString(result, 'role');

      if (role != null && role.isNotEmpty) {
        await TokenStorage.saveUserRole(role);
      }

      final userId = userMap != null
          ? _toInt(userMap['id'])
          : _toInt(result['user_id'] ?? result['id']);

      if (userId != null) {
        await TokenStorage.saveUserId(userId);
      }

      if (profileMap != null) {
        await TokenStorage.saveProfileData(
          firstName: _readString(profileMap, 'first_name'),
          lastName: _readString(profileMap, 'last_name'),
          governorate: _readString(profileMap, 'governorate'),
          dateOfBirth: _readString(profileMap, 'date_of_birth'),
          profileImageUrl: _readString(profileMap, 'profile_image_url'),
          identityImageUrl: _readString(profileMap, 'identity_image_url'),
        );
      }

      debugPrint('========== SAVED LOGIN DATA ==========');
      debugPrint('Token saved: ${TokenStorage.getToken() != null}');
      debugPrint('Email: ${TokenStorage.getUserEmail()}');
      debugPrint('User ID: ${TokenStorage.getUserId()}');
      debugPrint('Role: ${TokenStorage.getUserRole()}');
      debugPrint('First name: ${TokenStorage.getProfileFirstName()}');
      debugPrint('Last name: ${TokenStorage.getProfileLastName()}');
      debugPrint('DOB: ${TokenStorage.getProfileDateOfBirth()}');
      debugPrint('Governorate: ${TokenStorage.getProfileGovernorate()}');
      debugPrint('Profile image: ${TokenStorage.getProfileImageUrl()}');
      debugPrint('Identity image: ${TokenStorage.getIdentityImageUrl()}');
      debugPrint('======================================');

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Login error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic>? _extractUserMap(Map<String, dynamic> response) {
    final user = response['user'];

    if (user is Map<String, dynamic>) {
      return user;
    }

    final data = response['data'];
    if (data is Map<String, dynamic> && data['user'] is Map<String, dynamic>) {
      return data['user'] as Map<String, dynamic>;
    }

    return null;
  }

  Map<String, dynamic>? _extractProfileMap(Map<String, dynamic> response) {
    final profile = response['profile'];

    if (profile is Map<String, dynamic>) {
      return profile;
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      if (data['profile'] is Map<String, dynamic>) {
        return data['profile'] as Map<String, dynamic>;
      }

      if (data['user'] is Map<String, dynamic>) {
        final user = data['user'] as Map<String, dynamic>;
        if (user['profile'] is Map<String, dynamic>) {
          return user['profile'] as Map<String, dynamic>;
        }
      }
    }

    final user = response['user'];
    if (user is Map<String, dynamic> && user['profile'] is Map<String, dynamic>) {
      return user['profile'] as Map<String, dynamic>;
    }

    return null;
  }

  String? _readString(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value == null) return null;

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is double) return value.toInt();

    return int.tryParse(value.toString());
  }
}