import 'package:get/get.dart';

import '../repositories/auth_repository.dart';

class UpdateProfileController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<Map<String, dynamic>?> updateProfile({
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String governorate,
    String? profileImagePath,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        governorate: governorate,
        profileImagePath: profileImagePath,
      );

      return result;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
