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

      await _authRepository.changePin(password: password, newPin: newPin);

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
