import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;
    final Color activeTextDark = isDarkMode ? AppTheme.textPrimary : AppTheme.textDark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            _isArabic() ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new, // مرونة السهم حسب اتجاه اللغة
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).translate('Set Password Title'),
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: activePrimary),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).translate('Reset password instructions'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: isDarkMode ? AppTheme.textSecondary : Colors.grey),
              ),
              const SizedBox(height: 30),

              Align(
                alignment: _isArabic() ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, right: 4, left: 4),
                  child: Text(
                    AppLocalizations.of(context).translate('Verification Code'),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: activePrimary),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 56,
                    height: 56,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      onChanged: (value) {
                        if (value.length == 1 && index < 3) FocusScope.of(context).nextFocus();
                        if (value.isEmpty && index > 0) FocusScope.of(context).previousFocus();
                      },
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: activePrimary),
                      inputFormatters: [LengthLimitingTextInputFormatter(1), FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDarkMode ? AppTheme.inputFieldBg : const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: Color(0xFFE9ECEF), width: 1.5)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: Color(0xFFE9ECEF), width: 1.5)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, width: 2)),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              Align(
                alignment: _isArabic() ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 4, left: 4),
                  child: Text(
                    AppLocalizations.of(context).translate('New Password Label'),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: activePrimary),
                  ),
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                textAlign: _isArabic() ? TextAlign.right : TextAlign.left,
                style: TextStyle(color: activeTextDark, fontSize: 14),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('Enter new password hint'),
                  hintStyle: TextStyle(color: isDarkMode ? AppTheme.textSecondary.withOpacity(0.5) : Colors.black26, fontSize: 13),
                  prefixIcon: Icon(Icons.lock_outline, color: activePrimary),
                  filled: true,
                  fillColor: isDarkMode ? AppTheme.inputFieldBg : const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: Color(0xFFE9ECEF), width: 1.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: Color(0xFFE9ECEF), width: 1.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 20),

              Align(
                alignment: _isArabic() ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 4, left: 4),
                  child: Text(
                    AppLocalizations.of(context).translate('Confirm New Password Label'),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: activePrimary),
                  ),
                ),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                textAlign: _isArabic() ? TextAlign.right : TextAlign.left,
                style: TextStyle(color: activeTextDark, fontSize: 14),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('Retype password hint'),
                  hintStyle: TextStyle(color: isDarkMode ? AppTheme.textSecondary.withOpacity(0.5) : Colors.black26, fontSize: 13),
                  prefixIcon: Icon(Icons.lock_clock_outlined, color: activePrimary),
                  filled: true,
                  fillColor: isDarkMode ? AppTheme.inputFieldBg : const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: Color(0xFFE9ECEF), width: 1.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: Color(0xFFE9ECEF), width: 1.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 35),

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).translate('Password changed successfully notice'), textAlign: _isArabic() ? TextAlign.right : TextAlign.left),
                        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
                      ),
                    );
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('Save Password Button'),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  bool _isArabic() => Localizations.localeOf(context).languageCode == 'ar';
}