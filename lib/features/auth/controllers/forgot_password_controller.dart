import 'package:get/get.dart';

import '../repositories/auth_repository.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final RxBool isSendingOtp = false.obs;
  final RxBool isResettingPassword = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> sendOtp({required String email}) async {
    try {
      isSendingOtp.value = true;
      errorMessage.value = '';

      await _authRepository.sendOtp(email: email);

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSendingOtp.value = false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      isResettingPassword.value = true;
      errorMessage.value = '';

      await _authRepository.forgotPassword(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isResettingPassword.value = false;
    }
  }
}
