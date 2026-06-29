import 'package:flutter/material.dart';
import 'package:shamstore/screen/create_account.dart';
import 'package:shamstore/screen/home_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/forgot_password_screen.dart';
import 'package:shamstore/utils/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isBuyerSelected = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(isDarkMode),
            const SizedBox(height: 20),
            _buildLoginCard(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isDarkMode ? 0.05 : 0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 28,
                color: isDarkMode ? AppTheme.accentBlue : AppTheme.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
                AppLocalizations.of(context).translate('welcome_caps'),
                style: TextStyle(
                  color: isDarkMode ? AppTheme.textPrimary : AppTheme.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                )
            ),
            const SizedBox(height: 4),
            Text(
                AppLocalizations.of(context).translate('sign_in_desc'),
                style: TextStyle(
                  color: isDarkMode ? AppTheme.textSecondary : Colors.white60,
                  fontSize: 13,
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRoleToggle(isDarkMode),
            const SizedBox(height: 20),

            _buildField(
              label: AppLocalizations.of(context).translate('email_address'),
              hint: AppLocalizations.of(context).translate('enter_email'),
              icon: Icons.mail_outline,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildPasswordField(isDarkMode),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: Text(
                  AppLocalizations.of(context).translate('forgot_password'),
                  style: TextStyle(
                    color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            _buildLoginButton(isDarkMode),
            const SizedBox(height: 16),
            _buildDivider(isDarkMode),
            const SizedBox(height: 16),
            _buildCreateAccountButton(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleToggle(bool isDarkMode) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
      ),
      child: Row(
        children: [
          // خيار المشتري
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isBuyerSelected = true),
              child: Container(
                decoration: BoxDecoration(
                  color: _isBuyerSelected
                      ? (isDarkMode ? AppTheme.selectedBorder : AppTheme.primary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context).translate('buyer_role'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _isBuyerSelected
                        ? AppTheme.white
                        : (isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
                  ),
                ),
              ),
            ),
          ),
          // خيار البائع
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isBuyerSelected = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !_isBuyerSelected
                      ? (isDarkMode ? AppTheme.selectedBorder : AppTheme.primary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context).translate('seller_role'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: !_isBuyerSelected
                        ? AppTheme.white
                        : (isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool isDarkMode,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
            prefixIcon: Icon(
              icon,
              color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
            ),
            filled: true,
            fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            AppLocalizations.of(context).translate('password'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            )
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).translate('password'),
            hintStyle: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
            prefixIcon: Icon(Icons.lock_outline, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: isDarkMode ? AppTheme.iconUnselected : AppTheme.textLight,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(isBuyer: _isBuyerSelected),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
            AppLocalizations.of(context).translate('login'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Row(
      children: [
        Expanded(child: Divider(color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
              AppLocalizations.of(context).translate('or_continue'),
              style: TextStyle(
                color: isDarkMode ? AppTheme.textSecondary : Colors.grey[400],
                fontSize: 12,
              )
          ),
        ),
        Expanded(child: Divider(color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border)),
      ],
    );
  }

  Widget _buildCreateAccountButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
          side: BorderSide(color: isDarkMode ? Colors.transparent : AppTheme.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
            AppLocalizations.of(context).translate('create_account'),
            style: TextStyle(
              color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )
        ),
      ),
    );
  }
}