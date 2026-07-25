import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:shamstore/core/storage/token_storage.dart';
import 'package:shamstore/features/auth/repositories/auth_repository.dart';
import 'package:shamstore/features/notifications/controllers/notifications_controller.dart';

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
      } catch (error) {
        /*
         * حتى لو فشل طلب تسجيل الخروج من السيرفر،
         * يجب إنهاء الجلسة المحلية ومنع ظهور بيانات الحساب السابق.
         */
        apiLogoutSucceeded.value = false;
        errorMessage.value = _cleanErrorMessage(error);

        debugPrint('========== LOGOUT API FAILED ==========');
        debugPrint(error.toString());
        debugPrint('=======================================');
      }

      /*
       * هذا يمسح الإشعارات من ذاكرة التطبيق فقط.
       *
       * لا يحذف أي إشعار من قاعدة بيانات Laravel.
       * الحذف النهائي لا يحدث إلا عبر:
       * DELETE /deleteNotification/{id}
       */
      _clearAccountScopedControllers();

      /*
       * يمسح بيانات الجلسة المحلية فقط:
       * token, role, user id, profile cache...
       */
      await TokenStorage.clear();

      debugPrint('========== LOCAL SESSION CLEARED ==========');
      debugPrint('Local session and account-scoped cache removed.');
      debugPrint('Server notifications were not deleted.');
      debugPrint('===========================================');

      return true;
    } catch (error) {
      errorMessage.value = _cleanErrorMessage(error);
      debugPrint('Logout local clear error: $error');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _clearAccountScopedControllers() {
    if (!Get.isRegistered<NotificationsController>()) {
      return;
    }

    final controller = Get.find<NotificationsController>();

    /*
     * نمسح القائمة قبل حذف الـController لمنع ظهور إشعارات
     * الحساب السابق ولو لجزء من الثانية عند تبديل الحساب.
     */
    controller.notifications.clear();
    controller.currentPage.value = 1;
    controller.lastPage.value = 1;
    controller.total.value = 0;
    controller.errorMessage.value = '';
    controller.actionErrorMessage.value = '';
    controller.actionSuccessMessage.value = '';
    controller.markingAsReadIds.clear();
    controller.deletingIds.clear();

    Get.delete<NotificationsController>(force: true);
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString().trim();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length).trim();
    }

    if (message.isEmpty) {
      return 'حدث خطأ غير متوقع أثناء تسجيل الخروج';
    }

    return message;
  }
}
