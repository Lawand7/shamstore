import 'package:get/get.dart';

import '../../../services/firebase_notification_service.dart';
import '../repositories/auth_repository.dart';

class RegisterController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> register({
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String dateOfBirth,
    required String firstName,
    required String lastName,
    required String governorate,
    required String walletPin,
    required String profileImagePath,
    String? identityImagePath,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final fcmToken = await FirebaseNotificationService.getFcmToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        errorMessage.value = 'تعذر الحصول على Firebase token';
        return false;
      }

      await _authRepository.register(
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
        dateOfBirth: dateOfBirth,
        firstName: firstName,
        lastName: lastName,
        governorate: governorate,
        walletPin: walletPin,
        fcmToken: fcmToken,
        profileImagePath: profileImagePath,
        identityImagePath: identityImagePath,
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
