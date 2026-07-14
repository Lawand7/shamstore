import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../repositories/auth_repository.dart';

class ChangePinController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> changePin({
    required String password,
    required String newPin,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.changePin(
        password: password,
        newPin: newPin,
      );

      debugPrint('========== CHANGE PIN RESPONSE ==========');
      debugPrint(result.toString());
      debugPrint('=========================================');

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Change PIN error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}