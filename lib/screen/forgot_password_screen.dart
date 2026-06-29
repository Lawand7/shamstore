import 'package:flutter/material.dart';
import 'reset_password_screen.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).translate('Account Recovery'),
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: activePrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_reset_rounded, size: 50, color: activePrimary),
              ),
              const SizedBox(height: 24),

              Text(
                AppLocalizations.of(context).translate('Forgot Password?'),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: activePrimary),
              ),
              const SizedBox(height: 10),

              Text(
                AppLocalizations.of(context).translate('Forgot password description'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              Align(
                alignment: _isArabic() ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 4, left: 4),
                  child: Text(
                    AppLocalizations.of(context).translate('Email Address'),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: activePrimary),
                  ),
                ),
              ),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.left,
                style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'example@gmail.com',
                  hintStyle: TextStyle(color: isDarkMode ? AppTheme.textSecondary.withOpacity(0.5) : Colors.black26, fontSize: 14),
                  prefixIcon: Icon(Icons.email_outlined, color: activePrimary),
                  filled: true,
                  fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDarkMode ? Colors.transparent : const Color(0xFFE9ECEF), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('Send Button'),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('Temporary Skip'),
                    style: TextStyle(
                      color: isDarkMode ? AppTheme.textPrimary : AppTheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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

  bool _isArabic() => Localizations.localeOf(context).languageCode == 'ar';
}