import 'package:flutter/material.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/screen/login_page.dart';
import 'package:shamstore/screen/widgets/exit_confirmation_scope.dart';
import 'package:shamstore/them/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color barBackground = isDarkMode ? AppTheme.topBottomBar : AppTheme.primary;

    final Color activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.white;
    final Color buttonActiveBg = isDarkMode ? AppTheme.selectedBorder : AppTheme.white;
    final Color buttonActiveText = isDarkMode ? AppTheme.darkBackground : AppTheme.primary;

    final scaffold = Scaffold(
      backgroundColor: barBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 75,
                  color: activePrimary,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                AppLocalizations.of(context).translate('welcome_to'),
                style: const TextStyle(color: Colors.white60, fontSize: 13, letterSpacing: 2.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              Text(
                AppLocalizations.of(context).translate('shamstore'),
                style: TextStyle(
                  color: activePrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                AppLocalizations.of(context).translate('welcome_desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 48),

              Center(
                child: SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonActiveBg,
                      foregroundColor: buttonActiveText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            AppLocalizations.of(context).translate('get_started'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? Icons.arrow_back
                              : Icons.arrow_forward,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );

    return ExitConfirmationScope(child: scaffold);
  }
}
