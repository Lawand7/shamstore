import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../repositories/auth_repository.dart';

class ChangePasswordController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      debugPrint('========== CHANGE PASSWORD RESPONSE ==========');
      debugPrint(result.toString());
      debugPrint('==============================================');

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Change password error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
