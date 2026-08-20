import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/auth/controllers/change_pin_controller.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';

class ChangeWalletPinPage extends StatefulWidget {
  const ChangeWalletPinPage({super.key});

  @override
  State<ChangeWalletPinPage> createState() => _ChangeWalletPinPageState();
}

class _ChangeWalletPinPageState extends State<ChangeWalletPinPage> {
  final _formKey = GlobalKey<FormState>();

  late final ChangePinController _changePinController;

  final _passwordController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;

  @override
  void initState() {
    super.initState();

    _changePinController = Get.isRegistered<ChangePinController>()
        ? Get.find<ChangePinController>()
        : Get.put(ChangePinController());
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submitChangePin() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (newPin != confirmPin) {
      AppFeedback.error(context, 'رمز PIN الجديد وتأكيده غير متطابقين');
      return;
    }

    final success = await _changePinController.changePin(
      password: password,
      newPin: newPin,
    );

    if (!mounted) return;

    if (!success) {
      AppFeedback.error(
        context,
        _changePinController.errorMessage.value.isNotEmpty
            ? _changePinController.errorMessage.value
            : 'حدث خطأ أثناء تغيير رمز PIN',
      );
      return;
    }

    AppFeedback.success(context, 'message_pin_changed');

    Navigator.pop(context);
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
        title: const Text(
          'تغيير رمز المحفظة PIN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            isArabic
                ? Icons.arrow_back_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: activePrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pin_rounded,
                      size: 60,
                      color: activePrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  isArabic
                      ? 'أدخل كلمة مرور حسابك ثم اختر رمز PIN جديد للمحفظة.'
                      : 'Enter your account password, then choose a new wallet PIN.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode
                        ? AppTheme.textSecondary
                        : AppTheme.textGrey,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                _buildPasswordField(
                  controller: _passwordController,
                  label: isArabic ? 'كلمة مرور الحساب' : 'Account password',
                  hint: isArabic
                      ? 'أدخل كلمة مرور الحساب'
                      : 'Enter account password',
                  isObscure: _obscurePassword,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  keyboardType: TextInputType.text,
                  inputFormatters: const [],
                  validator: (value) {
                    final password = value?.trim() ?? '';

                    if (password.isEmpty) {
                      return isArabic
                          ? 'كلمة مرور الحساب مطلوبة'
                          : 'Account password is required';
                    }

                    if (password.length < 8) {
                      return isArabic
                          ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'
                          : 'Password must be at least 8 characters';
                    }

                    return null;
                  },
                  onToggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),

                const SizedBox(height: 16),

                _buildPasswordField(
                  controller: _newPinController,
                  label: isArabic ? 'رمز PIN الجديد' : 'New PIN',
                  hint: isArabic ? 'أدخل 4 أرقام' : 'Enter 4 digits',
                  isObscure: _obscureNewPin,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    final pin = value?.trim() ?? '';

                    if (pin.isEmpty) {
                      return isArabic
                          ? 'رمز PIN الجديد مطلوب'
                          : 'New PIN is required';
                    }

                    if (pin.length != 4) {
                      return isArabic
                          ? 'رمز PIN يجب أن يكون 4 أرقام'
                          : 'PIN must be 4 digits';
                    }

                    return null;
                  },
                  onToggleVisibility: () {
                    setState(() => _obscureNewPin = !_obscureNewPin);
                  },
                ),

                const SizedBox(height: 16),

                _buildPasswordField(
                  controller: _confirmPinController,
                  label: isArabic ? 'تأكيد رمز PIN الجديد' : 'Confirm new PIN',
                  hint: isArabic ? 'أعد إدخال 4 أرقام' : 'Re-enter 4 digits',
                  isObscure: _obscureConfirmPin,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    final pin = value?.trim() ?? '';

                    if (pin.isEmpty) {
                      return isArabic
                          ? 'تأكيد رمز PIN مطلوب'
                          : 'PIN confirmation is required';
                    }

                    if (pin.length != 4) {
                      return isArabic
                          ? 'تأكيد رمز PIN يجب أن يكون 4 أرقام'
                          : 'PIN confirmation must be 4 digits';
                    }

                    return null;
                  },
                  onToggleVisibility: () {
                    setState(() => _obscureConfirmPin = !_obscureConfirmPin);
                  },
                ),

                const SizedBox(height: 28),

                Obx(() {
                  final isLoading = _changePinController.isLoading.value;

                  return ElevatedButton(
                    onPressed: isLoading ? null : _submitChangePin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? AppTheme.selectedBorder
                          : AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'حفظ رمز PIN الجديد',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isObscure,
    required bool isDarkMode,
    required Color activePrimary,
    required TextInputType keyboardType,
    required List<TextInputFormatter> inputFormatters,
    required String? Function(String?) validator,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppTheme.textSecondary : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            fontSize: 14,
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDarkMode
                  ? AppTheme.textSecondary.withOpacity(0.4)
                  : AppTheme.textLight,
              fontSize: 13,
            ),
            filled: true,
            fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.white,
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
              onPressed: onToggleVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: isDarkMode
                  ? BorderSide.none
                  : const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: isDarkMode
                  ? BorderSide.none
                  : const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: activePrimary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
