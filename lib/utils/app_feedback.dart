import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/utils/localized_content.dart';

class AppFeedback {
  AppFeedback._();

  static void success(
    BuildContext? context,
    Object? message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(context, message, isError: false, duration: duration);
  }

  static void error(
    BuildContext? context,
    Object? message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(context, message, isError: true, duration: duration);
  }

  static void _show(
    BuildContext? context,
    Object? message, {
    required bool isError,
    required Duration duration,
  }) {
    final resolvedContext = context ?? Get.context;
    if (resolvedContext == null) return;

    final text = LocalizedContent.message(
      resolvedContext,
      message,
      isError: isError,
    );
    final color = isError ? AppTheme.error : AppTheme.success;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;
    final messenger = ScaffoldMessenger.maybeOf(resolvedContext);

    if (messenger != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: AppTheme.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            duration: duration,
          ),
        );
      return;
    }

    Get.snackbar(
      isError
          ? AppLocalizations.of(
              resolvedContext,
            ).translate('feedback_error_title')
          : AppLocalizations.of(
              resolvedContext,
            ).translate('feedback_success_title'),
      text,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: AppTheme.white,
      icon: Icon(icon, color: AppTheme.white),
      duration: duration,
    );
  }
}
