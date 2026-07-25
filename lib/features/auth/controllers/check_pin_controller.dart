import 'package:get/get.dart';

import 'package:shamstore/core/storage/token_storage.dart';
import 'package:shamstore/features/auth/repositories/auth_repository.dart';

class CheckPinController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final RxBool isLoading = false.obs;
  final RxBool sessionExpired = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> checkPin({required String pin}) async {
    if (isLoading.value) {
      return false;
    }

    final cleanPin = pin.trim();

    if (!RegExp(r'^\d{4}$').hasMatch(cleanPin)) {
      errorMessage.value = 'يجب أن يتكون رمز PIN من أربعة أرقام';
      return false;
    }

    try {
      isLoading.value = true;
      sessionExpired.value = false;
      errorMessage.value = '';

      final result = await _authRepository.checkPin(walletPin: cleanPin);

      if (result.isSuccess) {
        return true;
      }

      if (result.failureType == CheckPinFailureType.unauthorized) {
        await TokenStorage.clear();
        sessionExpired.value = true;
      }

      errorMessage.value = result.message;
      return false;
    } catch (_) {
      errorMessage.value = 'حدث خطأ غير متوقع أثناء التحقق من رمز PIN';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
