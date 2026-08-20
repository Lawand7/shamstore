import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/notifications/controllers/notifications_controller.dart';
import 'package:shamstore/features/notifications/models/app_notification_model.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/utils/localized_content.dart';

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
          title: Text(_text('حذف الإشعار', 'Delete notification')),
          content: Text(
            _text(
              'هل تريد حذف إشعار "${_presentationFor(notification).title}"؟',
              'Do you want to delete "${_presentationFor(notification).title}"?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_text('إلغاء', 'Cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                _text('حذف', 'Delete'),
                style: TextStyle(color: AppTheme.error),
              ),
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
                LocalizedContent.message(
                  context,
                  _controller.errorMessage.value,
                  isError: true,
                ),
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
                child: Text(_text('إعادة المحاولة', 'Try again')),
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
    IconData icon = Icons.notifications_none_rounded;
    Color color = Theme.of(context).brightness == Brightness.dark
        ? AppTheme.accentBlue
        : AppTheme.primary;

    if (normalizedTitle.contains('advertis')) {
      icon = normalizedTitle.contains('unaccepted')
          ? Icons.cancel_outlined
          : normalizedTitle.contains('accepted')
          ? Icons.verified_outlined
          : Icons.campaign_outlined;
      color = normalizedTitle.contains('unaccepted') ? Colors.red : Colors.blue;
    } else if (normalizedTitle.contains('withdraw')) {
      icon = Icons.price_check_outlined;
      color = body.toLowerCase().contains('unaccepted')
          ? Colors.red
          : Colors.orange;
    } else if (normalizedTitle.contains('deposit')) {
      icon = Icons.account_balance_wallet_outlined;
      color = body.toLowerCase().contains('unaccepted')
          ? Colors.red
          : Colors.green;
    } else if (normalizedTitle.contains('shipped')) {
      icon = Icons.local_shipping_outlined;
      color = Colors.blue;
    } else if (normalizedTitle.contains('rejected')) {
      icon = Icons.cancel_outlined;
      color = Colors.red;
    } else if (normalizedTitle.contains('report')) {
      icon = Icons.report_outlined;
      color = Colors.deepOrange;
    } else if (normalizedTitle.contains('payment')) {
      icon = Icons.payments_outlined;
      color = Colors.green;
    } else if (normalizedTitle.contains('order')) {
      icon = Icons.receipt_long_outlined;
      color = Colors.orange;
    }

    final localizations = AppLocalizations.of(context);

    return _NotificationPresentation(
      title: notification.title.trim().isEmpty
          ? localizations.translate('notification_generic_title')
          : LocalizedContent.notificationTitle(context, notification.title),
      body: body.isEmpty
          ? localizations.translate('notification_generic_body')
          : LocalizedContent.notificationBody(context, body),
      icon: icon,
      color: color,
    );
  }

  String _formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) {
      return _text('الوقت غير متوفر', 'Time unavailable');
    }

    final difference = DateTime.now().difference(dateTime);

    if (difference.isNegative) {
      return _text('الآن', 'Now');
    }

    if (difference.inSeconds < 60) {
      return _text('الآن', 'Now');
    }

    if (difference.inMinutes < 60) {
      return _text(
        'منذ ${difference.inMinutes} دقيقة',
        '${difference.inMinutes} minutes ago',
      );
    }

    if (difference.inHours < 24) {
      return _text(
        'منذ ${difference.inHours} ساعة',
        '${difference.inHours} hours ago',
      );
    }

    if (difference.inDays < 7) {
      return _text(
        'منذ ${difference.inDays} يوم',
        '${difference.inDays} days ago',
      );
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
    if (isError) {
      AppFeedback.error(context, message);
    } else {
      AppFeedback.success(context, message);
    }
  }

  String _text(String arabic, String english) {
    return Localizations.localeOf(context).languageCode == 'ar'
        ? arabic
        : english;
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
