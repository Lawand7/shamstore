import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/home_page.dart';
import 'package:shamstore/utils/app_localizations.dart'; // استيراد ملف الترجمة الخاص بك

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _seconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _resendCode() {
    setState(() => _seconds = 45);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 فحص حالة الدارك مود الحالية بالتطبيق
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(isDarkMode),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildInfoText(isDarkMode),
                  const SizedBox(height: 32),
                  _buildOtpBoxes(isDarkMode),
                  const SizedBox(height: 32),
                  _buildTimer(isDarkMode),
                  const SizedBox(height: 32),
                  _buildVerifyButton(isDarkMode),
                  const SizedBox(height: 16),
                  _buildChangeNumber(isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppTheme.inputFieldBg : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.white, size: 16),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(isDarkMode ? 0.05 : 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Icon(Icons.sms_outlined, color: isDarkMode ? AppTheme.accentBlue : AppTheme.white, size: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context).translate('Verify Your Account'),
                  style: const TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(bool isDarkMode) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context).translate('Enter Verification Code'),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
        ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.of(context).translate('We sent a 6-digit code to your phone'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildOtpBoxes(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        return Container(
          width: 42,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.primary,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
              if (value.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
            },
          ),
        );
      }),
    );
  }

  Widget _buildTimer(bool isDarkMode) {
    Color primaryLinkColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Column(
      children: [
        Text(
          AppLocalizations.of(context).translate("Didn't receive the code?"),
          style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, fontSize: 13),
        ),
        const SizedBox(height: 6),
        _seconds > 0
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 15, color: primaryLinkColor),
            const SizedBox(width: 6),
            Text(
              '${AppLocalizations.of(context).translate('Resend in')} ${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(color: primaryLinkColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        )
            : GestureDetector(
          onTap: _resendCode,
          child: Text(
            AppLocalizations.of(context).translate('Resend Code'),
            style: TextStyle(
              color: primaryLinkColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: primaryLinkColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // منطق التحقق يوضع هنا لاحقاً
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          AppLocalizations.of(context).translate('Verify & Continue'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildChangeNumber(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context).translate('Wrong number? '),
          style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : Colors.grey, fontSize: 13),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context).translate('Change it'),
            style: TextStyle(
              color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          ),
          child: Text(
            AppLocalizations.of(context).translate('Skip'),
            style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey, fontSize: 13),
          ),
        )
      ],
    );
  }
}