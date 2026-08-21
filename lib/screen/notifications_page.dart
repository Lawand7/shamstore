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
                ? '${AppLocalizations.of(context).translate('Notifications')} (${_controller.unreadCount})'
                : AppLocalizations.of(context).translate('Notifications'),
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
              final String notificationTitle = notification.title;

              return Dismissible(
                key: ValueKey<int>(notification.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  final bool? shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: Text(
                          AppLocalizations.of(
                            dialogContext,
                          ).translate('delete_notification_title'),
                        ),
                        content: Text(
                          '${AppLocalizations.of(dialogContext).translate('delete_notification_msg')} "$notificationTitle"؟',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: Text(
                              AppLocalizations.of(
                                dialogContext,
                              ).translate('Cancel'),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: Text(
                              AppLocalizations.of(
                                dialogContext,
                              ).translate('Delete Action'),
                              style: const TextStyle(color: AppTheme.error),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  return shouldDelete ?? false;
                },
                onDismissed: (_) async {
                  final success = await _controller.deleteNotification(
                    notification.id,
                  );

                  if (!mounted) return;

                  if (!success) {
                    _showSnackBar(
                      title: AppLocalizations.of(
                        context,
                      ).translate('delete_failed'),
                      message: _controller.actionErrorMessage.value.isNotEmpty
                          ? _controller.actionErrorMessage.value
                          : AppLocalizations.of(
                              context,
                            ).translate('error_deleting_notification'),
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
      context,
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

                  if (!mounted) return;

                  if (!success) {
                    _showSnackBar(
                      title: AppLocalizations.of(
                        context,
                      ).translate('failed_action'),
                      message: _controller.actionErrorMessage.value.isNotEmpty
                          ? _controller.actionErrorMessage.value
                          : AppLocalizations.of(
                              context,
                            ).translate('error_marking_read'),
                      isError: true,
                    );
                  }
                }
              },
        onLongPress: isBusy
            ? null
            : () async {
                final bool? shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: Text(
                        AppLocalizations.of(
                          dialogContext,
                        ).translate('delete_notification_title'),
                      ),
                      content: Text(
                        '${AppLocalizations.of(dialogContext).translate('delete_notification_msg')} "${presentation.title}"؟',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: Text(
                            AppLocalizations.of(
                              dialogContext,
                            ).translate('Cancel'),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: Text(
                            AppLocalizations.of(
                              dialogContext,
                            ).translate('Delete Action'),
                            style: const TextStyle(color: AppTheme.error),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (shouldDelete != true || !mounted) {
                  return;
                }

                final success = await _controller.deleteNotification(
                  notification.id,
                );

                if (!mounted) {
                  return;
                }

                _showSnackBar(
                  title: success
                      ? AppLocalizations.of(context).translate('delete_success')
                      : AppLocalizations.of(context).translate('delete_failed'),
                  message: success
                      ? AppLocalizations.of(
                          context,
                        ).translate('success_notification_deleted')
                      : (_controller.actionErrorMessage.value.isNotEmpty
                            ? _controller.actionErrorMessage.value
                            : AppLocalizations.of(
                                context,
                              ).translate('error_deleting_notification')),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delete_outline, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context).translate('Delete Action'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
                child: Text(AppLocalizations.of(context).translate('retry')),
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
                    AppLocalizations.of(
                      context,
                    ).translate('notifications_placeholder_body'),
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
    BuildContext ctx,
  ) {
    final normalizedTitle = notification.title.trim().toLowerCase();
    final body = notification.body.trim();
    IconData icon = Icons.notifications_none_rounded;
    Color color = Theme.of(ctx).brightness == Brightness.dark
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

    final localizations = AppLocalizations.of(ctx);

    return _NotificationPresentation(
      title: notification.title.trim().isEmpty
          ? localizations.translate('notification_generic_title')
          : LocalizedContent.notificationTitle(ctx, notification.title),
      body: body.isEmpty
          ? localizations.translate('notification_generic_body')
          : LocalizedContent.notificationBody(ctx, body),
      icon: icon,
      color: color,
    );
  }

  String _formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) {
      return AppLocalizations.of(context).translate('time_unavailable');
    }

    final difference = DateTime.now().difference(dateTime);

    if (difference.isNegative) {
      return AppLocalizations.of(context).translate('time_now');
    }

    if (difference.inSeconds < 60) {
      return AppLocalizations.of(context).translate('time_now');
    }

    if (difference.inMinutes < 60) {
      return AppLocalizations.of(context)
          .translate('time_minutes_ago')
          .replaceAll('{minutes}', difference.inMinutes.toString());
    }

    if (difference.inHours < 24) {
      return AppLocalizations.of(context)
          .translate('time_hours_ago')
          .replaceAll('{hours}', difference.inHours.toString());
    }

    if (difference.inDays < 7) {
      return AppLocalizations.of(context)
          .translate('time_days_ago')
          .replaceAll('{days}', difference.inDays.toString());
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
