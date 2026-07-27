import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class ExitConfirmationScope extends StatefulWidget {
  final Widget child;

  const ExitConfirmationScope({super.key, required this.child});

  @override
  State<ExitConfirmationScope> createState() => _ExitConfirmationScopeState();
}

class _ExitConfirmationScopeState extends State<ExitConfirmationScope> {
  bool _isShowingDialog = false;

  Future<void> _confirmExit() async {
    if (_isShowingDialog || !mounted) {
      return;
    }

    _isShowingDialog = true;

    final bool shouldExit =
        await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) {
            final bool isDarkMode =
                Theme.of(dialogContext).brightness == Brightness.dark;

            return AlertDialog(
              backgroundColor: isDarkMode
                  ? AppTheme.cardBackground
                  : AppTheme.white,
              title: Text(
                AppLocalizations.of(dialogContext).translate('exit_app_title'),
                textAlign: TextAlign.right,
              ),
              content: Text(
                AppLocalizations.of(
                  dialogContext,
                ).translate('exit_app_message'),
                textAlign: TextAlign.right,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    AppLocalizations.of(dialogContext).translate('Cancel'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? AppTheme.selectedBorder
                        : AppTheme.primary,
                    foregroundColor: AppTheme.white,
                  ),
                  child: Text(
                    AppLocalizations.of(dialogContext).translate('Yes'),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    _isShowingDialog = false;

    if (shouldExit && mounted) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmExit();
        }
      },
      child: widget.child,
    );
  }
}
