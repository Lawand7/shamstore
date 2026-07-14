import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/storage/token_storage.dart';
import '../repositories/auth_repository.dart';

class LogoutController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool apiLogoutSucceeded = false.obs;

  Future<bool> logout() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      apiLogoutSucceeded.value = false;

      try {
        final result = await _authRepository.logout();

        apiLogoutSucceeded.value = true;

        debugPrint('========== LOGOUT API SUCCESS ==========');
        debugPrint(result.toString());
        debugPrint('========================================');
      } catch (e) {
        apiLogoutSucceeded.value = false;
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');

        debugPrint('========== LOGOUT API FAILED ==========');
        debugPrint(e.toString());
        debugPrint('=======================================');
      }

      await TokenStorage.clear();

      debugPrint('========== LOCAL SESSION CLEARED ==========');
      debugPrint('Token, role, and user id removed locally.');
      debugPrint('===========================================');

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Logout local clear error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}