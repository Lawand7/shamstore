import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/auth/controllers/forgot_password_controller.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final ForgotPasswordController _forgotPasswordController;

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String get _email => widget.email.trim();

  @override
  void initState() {
    super.initState();

    _forgotPasswordController = Get.isRegistered<ForgotPasswordController>()
        ? Get.find<ForgotPasswordController>()
        : Get.put(ForgotPasswordController());
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }

    for (final focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }

    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text.trim()).join();
  }

  void _setOtpCode(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    for (int i = 0; i < _otpControllers.length; i++) {
      final text = i < digits.length ? digits[i] : '';

      _otpControllers[i].value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    if (digits.length >= 6) {
      FocusScope.of(context).unfocus();
    } else {
      _otpFocusNodes[digits.length].requestFocus();
    }
  }

  void _handleOtpChanged(String value, int index) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 1) {
      _setOtpCode(digits);
      return;
    }

    if (digits.isEmpty) {
      _otpControllers[index].clear();

      if (index > 0) {
        _otpFocusNodes[index - 1].requestFocus();
      }

      return;
    }

    _otpControllers[index].value = TextEditingValue(
      text: digits,
      selection: const TextSelection.collapsed(offset: 1),
    );

    if (index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _resendOtp() async {
    final success = await _forgotPasswordController.sendOtp(email: _email);

    if (!mounted) return;

    if (!success) {
      AppFeedback.error(
        context,
        _forgotPasswordController.errorMessage.value.isNotEmpty
            ? _forgotPasswordController.errorMessage.value
            : 'حدث خطأ أثناء إرسال رمز جديد',
      );
      return;
    }

    AppFeedback.success(context, 'تم إرسال رمز جديد إلى البريد الإلكتروني');
  }

  Future<void> _submitResetPassword() async {
    final otp = _getOtpCode();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (otp.length != 6) {
      AppFeedback.error(context, 'يرجى إدخال رمز التحقق المكون من 6 أرقام');
      return;
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      AppFeedback.error(context, 'يرجى إدخال كلمة المرور وتأكيدها');
      return;
    }

    if (password.length < 8) {
      AppFeedback.error(context, 'كلمة المرور يجب أن تكون 8 أحرف على الأقل');
      return;
    }

    if (password != confirmPassword) {
      AppFeedback.error(context, 'كلمة المرور وتأكيد كلمة المرور غير متطابقين');
      return;
    }

    final success = await _forgotPasswordController.resetPassword(
      email: _email,
      otp: otp,
      password: password,
      passwordConfirmation: confirmPassword,
    );

    if (!mounted) return;

    if (!success) {
      AppFeedback.error(
        context,
        _forgotPasswordController.errorMessage.value.isNotEmpty
            ? _forgotPasswordController.errorMessage.value
            : 'حدث خطأ أثناء استعادة كلمة المرور',
      );
      return;
    }

    AppFeedback.success(context, 'message_password_changed');

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final Color activePrimary = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;
    final Color activeTextDark = isDarkMode
        ? AppTheme.textPrimary
        : AppTheme.textDark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.white,
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
          AppLocalizations.of(context).translate('Set Password Title'),
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
              const SizedBox(height: 30),

              Text(
                AppLocalizations.of(context).translate('Reset Password Header'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: activePrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'أدخل رمز التحقق المرسل إلى:\n$_email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? AppTheme.textSecondary : Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              Align(
                alignment: isArabic
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12.0,
                    right: 4,
                    left: 4,
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('Verification Code'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: activePrimary,
                    ),
                  ),
                ),
              ),

              _buildOtpBoxes(isDarkMode, activePrimary),

              const SizedBox(height: 12),

              Align(
                alignment: isArabic
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Obx(() {
                  final isSending =
                      _forgotPasswordController.isSendingOtp.value;

                  return TextButton(
                    onPressed: isSending ? null : _resendOtp,
                    child: isSending
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: activePrimary,
                            ),
                          )
                        : Text(
                            'إعادة إرسال الرمز',
                            style: TextStyle(
                              color: activePrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                }),
              ),

              const SizedBox(height: 18),

              _buildPasswordLabel(
                text: AppLocalizations.of(
                  context,
                ).translate('New Password Label'),
                isArabic: isArabic,
                activePrimary: activePrimary,
              ),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: TextStyle(color: activeTextDark, fontSize: 14),
                decoration: _passwordDecoration(
                  hint: AppLocalizations.of(
                    context,
                  ).translate('Enter new password hint'),
                  icon: Icons.lock_outline,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  isObscure: _obscurePassword,
                  onToggle: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              _buildPasswordLabel(
                text: AppLocalizations.of(
                  context,
                ).translate('Confirm New Password Label'),
                isArabic: isArabic,
                activePrimary: activePrimary,
              ),

              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: TextStyle(color: activeTextDark, fontSize: 14),
                decoration: _passwordDecoration(
                  hint: AppLocalizations.of(
                    context,
                  ).translate('Retype password hint'),
                  icon: Icons.lock_clock_outlined,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  isObscure: _obscureConfirmPassword,
                  onToggle: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 35),

              Obx(() {
                final isLoading =
                    _forgotPasswordController.isResettingPassword.value;

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
                    onPressed: isLoading ? null : _submitResetPassword,
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
                            ).translate('Save Password Button'),
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

  Widget _buildOtpBoxes(bool isDarkMode, Color activePrimary) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        textDirection: TextDirection.ltr,
        children: List.generate(6, (index) {
          return SizedBox(
            width: 46,
            height: 56,
            child: TextFormField(
              controller: _otpControllers[index],
              focusNode: _otpFocusNodes[index],
              onChanged: (value) => _handleOtpChanged(value, index),
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: activePrimary,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: isDarkMode
                    ? AppTheme.inputFieldBg
                    : const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: isDarkMode
                      ? BorderSide.none
                      : const BorderSide(color: Color(0xFFE9ECEF), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: isDarkMode
                      ? BorderSide.none
                      : const BorderSide(color: Color(0xFFE9ECEF), width: 1.5),
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
          );
        }),
      ),
    );
  }

  Widget _buildPasswordLabel({
    required String text,
    required bool isArabic,
    required Color activePrimary,
  }) {
    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, right: 4, left: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: activePrimary,
          ),
        ),
      ),
    );
  }

  InputDecoration _passwordDecoration({
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    required Color activePrimary,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDarkMode
            ? AppTheme.textSecondary.withOpacity(0.5)
            : Colors.black26,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: activePrimary),
      suffixIcon: IconButton(
        icon: Icon(
          isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
        ),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: isDarkMode ? AppTheme.inputFieldBg : const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: isDarkMode
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFE9ECEF), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: isDarkMode
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFE9ECEF), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
          width: 2,
        ),
      ),
    );
  }
}
