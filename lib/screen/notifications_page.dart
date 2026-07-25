import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/notifications/controllers/notifications_controller.dart';
import 'package:shamstore/features/notifications/models/app_notification_model.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _controller = Get.isRegistered<NotificationsController>()
        ? Get.find<NotificationsController>()
        : Get.put(NotificationsController());

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 180) {
      _controller.loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isArabic =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward : Icons.arrow_back,
            color: AppTheme.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Obx(
          () => Text(
            _controller.unreadCount > 0
                ? 'الإشعارات (${_controller.unreadCount})'
                : 'الإشعارات',
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.errorMessage.value.isNotEmpty &&
            _controller.notifications.isEmpty) {
          return _buildErrorState(isDarkMode);
        }

        if (_controller.notifications.isEmpty) {
          return _buildEmptyState(context, isDarkMode);
        }

        return RefreshIndicator(
          onRefresh: _controller.refreshNotifications,
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount:
                _controller.notifications.length +
                (_controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index >= _controller.notifications.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              final notification = _controller.notifications[index];

              return Dismissible(
                key: ValueKey<int>(notification.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  return await _confirmDelete(notification);
                },
                onDismissed: (_) async {
                  final success = await _controller.deleteNotification(
                    notification.id,
                  );

                  if (!success && mounted) {
                    _showSnackBar(
                      title: 'فشل الحذف',
                      message: _controller.actionErrorMessage.value.isNotEmpty
                          ? _controller.actionErrorMessage.value
                          : 'تعذر حذف الإشعار',
                      isError: true,
                    );

                    await _controller.refreshNotifications();
                  }
                },
                background: _buildDeleteBackground(isArabic),
                child: _buildNotificationCard(
                  notification: notification,
                  isDarkMode: isDarkMode,
                  isArabic: isArabic,
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationCard({
    required AppNotificationModel notification,
    required bool isDarkMode,
    required bool isArabic,
  }) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    final bool isBusy =
        _controller.isMarkingAsRead(notification.id) ||
        _controller.isDeleting(notification.id);

    final _NotificationPresentation presentation = _presentationFor(
      notification,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isBusy
            ? null
            : () async {
                if (!notification.isRead) {
                  final success = await _controller.markAsRead(notification.id);

                  if (!success && mounted) {
                    _showSnackBar(
                      title: 'فشل العملية',
                      message: _controller.actionErrorMessage.value.isNotEmpty
                          ? _controller.actionErrorMessage.value
                          : 'تعذر تعليم الإشعار كمقروء',
                      isError: true,
                    );
                  }
                }
              },
        onLongPress: isBusy
            ? null
            : () async {
                final shouldDelete = await _confirmDelete(notification);

                if (!shouldDelete) {
                  return;
                }

                final success = await _controller.deleteNotification(
                  notification.id,
                );

                if (!mounted) {
                  return;
                }

                _showSnackBar(
                  title: success ? 'تم الحذف' : 'فشل الحذف',
                  message: success
                      ? 'تم حذف الإشعار بنجاح'
                      : (_controller.actionErrorMessage.value.isNotEmpty
                            ? _controller.actionErrorMessage.value
                            : 'تعذر حذف الإشعار'),
                  isError: !success,
                );
              },
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: !notification.isRead
                  ? activeColor.withValues(alpha: 0.55)
                  : (isDarkMode ? Colors.transparent : AppTheme.border),
              width: !notification.isRead ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                leading: isArabic ? null : _buildNotificationIcon(presentation),
                trailing: isArabic
                    ? _buildNotificationIcon(presentation)
                    : null,
                title: Text(
                  presentation.title,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: !notification.isRead
                        ? FontWeight.bold
                        : FontWeight.w600,
                    color: isDarkMode
                        ? AppTheme.textPrimary
                        : AppTheme.textDark,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      presentation.body,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.45,
                        color: isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (!isArabic)
                          Text(
                            _formatRelativeTime(notification.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode
                                  ? AppTheme.textSecondary
                                  : AppTheme.textLight,
                            ),
                          ),
                        if (!isArabic) const Spacer(),
                        if (!notification.isRead)
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: activeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (isArabic) const Spacer(),
                        if (isArabic)
                          Text(
                            _formatRelativeTime(notification.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode
                                  ? AppTheme.textSecondary
                                  : AppTheme.textLight,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isBusy)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(_NotificationPresentation presentation) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: presentation.color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(presentation.icon, color: presentation.color, size: 22),
    );
  }

  Widget _buildDeleteBackground(bool isArabic) {
    return Container(
      alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppTheme.error,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'حذف',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(AppNotificationModel notification) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف الإشعار', textAlign: TextAlign.right),
          content: Text(
            'هل تريد حذف إشعار "${_presentationFor(notification).title}"؟',
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('حذف', style: TextStyle(color: AppTheme.error)),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Widget _buildErrorState(bool isDarkMode) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? Colors.transparent : AppTheme.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppTheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                _controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _controller.refreshNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: _controller.refreshNotifications,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 70,
                    color: isDarkMode
                        ? AppTheme.textSecondary.withValues(alpha: 0.3)
                        : AppTheme.textLight.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).translate('No new notifications'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? AppTheme.textPrimary
                          : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ستظهر هنا إشعارات الطلبات والدفعات والحالات الأخرى.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode
                          ? AppTheme.textSecondary
                          : AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _NotificationPresentation _presentationFor(
    AppNotificationModel notification,
  ) {
    final normalizedTitle = notification.title.trim().toLowerCase();
    final body = notification.body.trim();

    if (normalizedTitle.contains('new order received')) {
      return _NotificationPresentation(
        title: 'طلب جديد',
        body: _translateBody(
          body,
          englishPrefix: 'You have a new order for:',
          arabicPrefix: 'لديك طلب جديد على المنتج:',
        ),
        icon: Icons.receipt_long_outlined,
        color: Colors.orange,
      );
    }

    if (normalizedTitle.contains('payment received')) {
      return _NotificationPresentation(
        title: 'تم استلام دفعة',
        body: _translateBody(
          body,
          englishPrefix:
              'An amount has been deposited into your wallet for selling:',
          arabicPrefix: 'تمت إضافة مبلغ إلى محفظتك مقابل بيع:',
        ),
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.green,
      );
    }

    if (normalizedTitle.contains('payment successful')) {
      return _NotificationPresentation(
        title: 'تم الدفع بنجاح',
        body: _translateBody(
          body,
          englishPrefix: 'Your wallet was charged for purchasing:',
          arabicPrefix: 'تم خصم قيمة شراء المنتج من محفظتك:',
        ),
        icon: Icons.payments_outlined,
        color: Colors.green,
      );
    }

    if (normalizedTitle.contains('order shipped') ||
        normalizedTitle.contains('shipped')) {
      return _NotificationPresentation(
        title: 'تم شحن الطلب',
        body: _translateOrderShippedBody(body),
        icon: Icons.local_shipping_outlined,
        color: Colors.blue,
      );
    }

    if (normalizedTitle.contains('order rejected') ||
        normalizedTitle.contains('rejected')) {
      return _NotificationPresentation(
        title: 'تم رفض الطلب',
        body: body.isEmpty ? 'قام البائع برفض الطلب.' : body,
        icon: Icons.cancel_outlined,
        color: Colors.red,
      );
    }

    if (normalizedTitle.contains('report')) {
      return _NotificationPresentation(
        title: 'تحديث بخصوص البلاغ',
        body: body.isEmpty ? 'يوجد تحديث جديد بخصوص أحد بلاغاتك.' : body,
        icon: Icons.report_outlined,
        color: Colors.deepOrange,
      );
    }

    return _NotificationPresentation(
      title: notification.title.isEmpty ? 'إشعار جديد' : notification.title,
      body: body.isEmpty ? 'لديك إشعار جديد.' : body,
      icon: Icons.notifications_none_rounded,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.accentBlue
          : AppTheme.primary,
    );
  }

  String _translateOrderShippedBody(String body) {
    final cleanBody = body.trim();

    if (cleanBody.isEmpty) {
      return 'قام البائع بشحن طلبك.';
    }

    final match = RegExp(
      r'^Your order for\s+(.+?)\s+has been shipped\.?$',
      caseSensitive: false,
    ).firstMatch(cleanBody);

    final productName = match?.group(1)?.trim();

    if (productName == null || productName.isEmpty) {
      return cleanBody;
    }

    return 'تم شحن طلبك الخاص بالمنتج: $productName.';
  }

  String _translateBody(
    String body, {
    required String englishPrefix,
    required String arabicPrefix,
  }) {
    final cleanBody = body.trim();

    if (cleanBody.isEmpty) {
      return arabicPrefix;
    }

    final lowerBody = cleanBody.toLowerCase();
    final lowerPrefix = englishPrefix.toLowerCase();

    if (!lowerBody.startsWith(lowerPrefix)) {
      return cleanBody;
    }

    final remainder = cleanBody
        .substring(englishPrefix.length)
        .trim()
        .replaceFirst(RegExp(r'\.$'), '');

    return remainder.isEmpty ? arabicPrefix : '$arabicPrefix $remainder.';
  }

  String _formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'الوقت غير متوفر';
    }

    final difference = DateTime.now().difference(dateTime);

    if (difference.isNegative) {
      return 'الآن';
    }

    if (difference.inSeconds < 60) {
      return 'الآن';
    }

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    }

    if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    }

    if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');

    return '$day/$month/${dateTime.year}';
  }

  void _showSnackBar({
    required String title,
    required String message,
    required bool isError,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? AppTheme.error : Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}

class _NotificationPresentation {
  final String title;
  final String body;
  final IconData icon;
  final Color color;

  const _NotificationPresentation({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
  });
}
