import 'package:get/get.dart';

import 'package:shamstore/features/notifications/models/app_notification_model.dart';
import 'package:shamstore/features/notifications/repositories/notifications_repository.dart';

class NotificationsController extends GetxController {
  NotificationsController({NotificationsRepository? repository})
      : _repository = repository ?? NotificationsRepository();

  final NotificationsRepository _repository;

  final RxList<AppNotificationModel> notifications =
      <AppNotificationModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  final RxString errorMessage = ''.obs;
  final RxString actionErrorMessage = ''.obs;
  final RxString actionSuccessMessage = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt total = 0.obs;

  final RxList<int> markingAsReadIds = <int>[].obs;
  final RxList<int> deletingIds = <int>[].obs;

  int get unreadCount =>
      notifications.where((notification) => !notification.isRead).length;

  bool get hasMore => currentPage.value < lastPage.value;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications(refresh: true);
  }

  Future<bool> fetchNotifications({bool refresh = true}) async {
    if (refresh) {
      if (isLoading.value) {
        return false;
      }

      isLoading.value = true;
      errorMessage.value = '';
    } else {
      if (isLoadingMore.value || !hasMore) {
        return false;
      }

      isLoadingMore.value = true;
    }

    try {
      final requestedPage = refresh ? 1 : currentPage.value + 1;

      final result = await _repository.getNotifications(page: requestedPage);

      if (refresh) {
        notifications.assignAll(result.notifications);
      } else {
        final existingIds = notifications.map((item) => item.id).toSet();

        notifications.addAll(
          result.notifications.where((item) => !existingIds.contains(item.id)),
        );
      }

      currentPage.value = result.currentPage;
      lastPage.value = result.lastPage;
      total.value = result.total;

      return true;
    } catch (error) {
      if (refresh) {
        notifications.clear();
      }

      errorMessage.value = _cleanErrorMessage(error);
      return false;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications(refresh: true);
  }

  Future<void> loadMoreNotifications() async {
    await fetchNotifications(refresh: false);
  }

  Future<bool> markAsRead(int notificationId) async {
    if (notificationId <= 0 ||
        markingAsReadIds.contains(notificationId) ||
        deletingIds.contains(notificationId)) {
      return false;
    }

    final index = notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );

    if (index == -1) {
      return false;
    }

    if (notifications[index].isRead) {
      return true;
    }

    _clearActionMessages();
    markingAsReadIds.add(notificationId);

    try {
      final updated = await _repository.markAsRead(
        notificationId: notificationId,
      );

      final current = notifications[index];

      notifications[index] = updated?.copyWith(isRead: true) ??
          current.copyWith(isRead: true);

      notifications.refresh();

      return true;
    } catch (error) {
      actionErrorMessage.value = _cleanErrorMessage(error);
      return false;
    } finally {
      markingAsReadIds.remove(notificationId);
    }
  }

  Future<bool> deleteNotification(int notificationId) async {
    if (notificationId <= 0 ||
        deletingIds.contains(notificationId) ||
        markingAsReadIds.contains(notificationId)) {
      return false;
    }

    _clearActionMessages();
    deletingIds.add(notificationId);

    try {
      final message = await _repository.deleteNotification(
        notificationId: notificationId,
      );

      notifications.removeWhere(
        (notification) => notification.id == notificationId,
      );

      if (total.value > 0) {
        total.value--;
      }

      actionSuccessMessage.value = message;
      return true;
    } catch (error) {
      actionErrorMessage.value = _cleanErrorMessage(error);
      return false;
    } finally {
      deletingIds.remove(notificationId);
    }
  }

  bool isMarkingAsRead(int notificationId) {
    return markingAsReadIds.contains(notificationId);
  }

  bool isDeleting(int notificationId) {
    return deletingIds.contains(notificationId);
  }

  void clearActionMessages() {
    _clearActionMessages();
  }

  void _clearActionMessages() {
    actionErrorMessage.value = '';
    actionSuccessMessage.value = '';
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString().trim();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length).trim();
    }

    if (message.isEmpty) {
      return 'حدث خطأ غير متوقع أثناء تنفيذ العملية';
    }

    return message;
  }
}
