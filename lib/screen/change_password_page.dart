import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/auth/controllers/change_password_controller.dart';
import 'package:shamstore/screen/forgot_password_screen.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  late final ChangePasswordController _changePasswordController;

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();

    _changePasswordController = Get.isRegistered<ChangePasswordController>()
        ? Get.find<ChangePasswordController>()
        : Get.put(ChangePasswordController());
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'تنبيه',
        'كلمة المرور الجديدة وتأكيدها غير متطابقين',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await _changePasswordController.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      newPasswordConfirmation: confirmPassword,
    );

    if (!mounted) return;

    if (!success) {
      Get.snackbar(
        'فشل تغيير كلمة المرور',
        _changePasswordController.errorMessage.value.isNotEmpty
            ? _changePasswordController.errorMessage.value
            : 'حدث خطأ أثناء تغيير كلمة المرور',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'نجاح',
      'تم تغيير كلمة المرور بنجاح',
      snackPosition: SnackPosition.BOTTOM,
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
          AppLocalizations.of(context).translate('Change Password Title'),
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
                      color: activePrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 60,
                      color: activePrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                _buildPasswordField(
                  controller: _oldPasswordController,
                  label: AppLocalizations.of(
                    context,
                  ).translate('Old Password Label'),
                  hint: AppLocalizations.of(
                    context,
                  ).translate('Old Password Hint'),
                  isObscure: _obscureOld,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  onToggleVisibility: () {
                    setState(() => _obscureOld = !_obscureOld);
                  },
                ),

                const SizedBox(height: 16),

                _buildPasswordField(
                  controller: _newPasswordController,
                  label: AppLocalizations.of(
                    context,
                  ).translate('New Password Label'),
                  hint: AppLocalizations.of(
                    context,
                  ).translate('New Password Hint'),
                  isObscure: _obscureNew,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  onToggleVisibility: () {
                    setState(() => _obscureNew = !_obscureNew);
                  },
                ),

                const SizedBox(height: 16),

                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: AppLocalizations.of(
                    context,
                  ).translate('Confirm Password Label'),
                  hint: AppLocalizations.of(
                    context,
                  ).translate('Confirm Password Hint'),
                  isObscure: _obscureConfirm,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  onToggleVisibility: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),

                Align(
                  alignment: isArabic
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).translate('Forgot Password Link'),
                      style: TextStyle(
                        color: activePrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Obx(() {
                  final isLoading = _changePasswordController.isLoading.value;

                  return ElevatedButton(
                    onPressed: isLoading ? null : _submitChangePassword,
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
                            ).translate('Save Changes Button'),
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
          style: TextStyle(
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            fontSize: 14,
          ),
          validator: (value) {
            final password = value?.trim() ?? '';

            if (password.isEmpty) {
              return 'هذا الحقل مطلوب';
            }

            if (password.length < 8) {
              return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
            }

            return null;
          },
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
