import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/auth/controllers/change_pin_controller.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';

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
      AppFeedback.error(
        context,
        AppLocalizations.of(context).translate('error_pin_mismatch'),
      );
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
            : AppLocalizations.of(context).translate('error_change_pin_failed'),
      );
      return;
    }

    AppFeedback.success(
      context,
      AppLocalizations.of(context).translate('message_pin_changed'),
    );

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
        title: Text(
          AppLocalizations.of(context).translate('change_wallet_pin_title'),
          style: const TextStyle(
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
                      color: activePrimary.withValues(alpha: 0.1),
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
                  AppLocalizations.of(
                    context,
                  ).translate('change_pin_instructions'),
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
                  label: AppLocalizations.of(
                    context,
                  ).translate('account_password_label'),
                  hint: AppLocalizations.of(
                    context,
                  ).translate('account_password_hint'),
                  isObscure: _obscurePassword,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  keyboardType: TextInputType.text,
                  inputFormatters: const [],
                  validator: (value) {
                    final password = value?.trim() ?? '';

                    if (password.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      ).translate('account_password_required');
                    }

                    if (password.length < 8) {
                      return AppLocalizations.of(
                        context,
                      ).translate('error_password_length');
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
                  label: AppLocalizations.of(
                    context,
                  ).translate('new_pin_label'),
                  hint: AppLocalizations.of(
                    context,
                  ).translate('enter_4_digits'),
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
                      return AppLocalizations.of(
                        context,
                      ).translate('new_pin_required');
                    }

                    if (pin.length != 4) {
                      return AppLocalizations.of(
                        context,
                      ).translate('pin_must_be_4_digits');
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
                  label: AppLocalizations.of(
                    context,
                  ).translate('confirm_new_pin_label'),
                  hint: AppLocalizations.of(
                    context,
                  ).translate('re_enter_4_digits'),
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
                      return AppLocalizations.of(
                        context,
                      ).translate('confirm_pin_required');
                    }

                    if (pin.length != 4) {
                      return AppLocalizations.of(
                        context,
                      ).translate('confirm_pin_must_be_4_digits');
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
                        : Text(
                            AppLocalizations.of(
                              context,
                            ).translate('save_new_pin_btn'),
                            style: const TextStyle(
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
                  ? AppTheme.textSecondary.withValues(alpha: 0.4)
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
