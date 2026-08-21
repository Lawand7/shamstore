import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/auth/controllers/forgot_password_controller.dart';
import 'package:shamstore/screen/reset_password_screen.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final ForgotPasswordController _forgotPasswordController;

  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _forgotPasswordController = Get.isRegistered<ForgotPasswordController>()
        ? Get.find<ForgotPasswordController>()
        : Get.put(ForgotPasswordController());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      AppFeedback.error(context, 'يرجى إدخال البريد الإلكتروني');
      return;
    }

    if (!_isValidEmail(email)) {
      AppFeedback.error(context, 'يرجى إدخال بريد إلكتروني صحيح');
      return;
    }

    final success = await _forgotPasswordController.sendOtp(email: email);

    if (!mounted) return;

    if (!success) {
      AppFeedback.error(
        context,
        _forgotPasswordController.errorMessage.value.isNotEmpty
            ? _forgotPasswordController.errorMessage.value
            : 'حدث خطأ أثناء إرسال رمز التحقق',
      );
      return;
    }

    AppFeedback.success(context, 'تم إرسال رمز التحقق إلى البريد الإلكتروني');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: email)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final Color activePrimary = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

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
            isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).translate('Account Recovery'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
                  color: activePrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 50,
                  color: activePrimary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context).translate('Forgot Password?'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: activePrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'أدخل بريدك الإلكتروني لإرسال رمز التحقق وإعادة تعيين كلمة المرور.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode
                      ? AppTheme.textSecondary
                      : AppTheme.textGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: isArabic
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8.0,
                    right: 4,
                    left: 4,
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('Email Address'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: activePrimary,
                    ),
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: isDarkMode
                        ? AppTheme.textPrimary
                        : AppTheme.textDark,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'example@gmail.com',
                    hintStyle: TextStyle(
                      color: isDarkMode
                          ? AppTheme.textSecondary.withValues(alpha: 0.5)
                          : Colors.black26,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: activePrimary,
                    ),
                    filled: true,
                    fillColor: isDarkMode
                        ? AppTheme.inputFieldBg
                        : AppTheme.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? Colors.transparent
                            : const Color(0xFFE9ECEF),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? AppTheme.selectedBorder
                            : AppTheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Obx(() {
                final isLoading = _forgotPasswordController.isSendingOtp.value;

                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? AppTheme.selectedBorder
                          : AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLoading ? null : _submitEmail,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(
                              context,
                            ).translate('Send Button'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
