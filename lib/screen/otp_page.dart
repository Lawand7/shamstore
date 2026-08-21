import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:shamstore/core/storage/token_storage.dart';
import 'package:shamstore/features/auth/controllers/otp_controller.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/screen/home_page.dart';
import 'package:shamstore/screen/seller_home_page.dart';
import 'package:shamstore/utils/app_localizations.dart';

class PendingRegistrationData {
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String governorate;

  const PendingRegistrationData({
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.governorate,
  });

  bool get isBuyer {
    final value = role.trim().toLowerCase();
    return value == 'customer' || value == 'buyer';
  }
}

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final PendingRegistrationData? pendingRegistrationData;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.pendingRegistrationData,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final OtpController _otpController;

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _seconds = 60;
  Timer? _timer;

  String get _email => widget.phoneNumber.trim();

  @override
  void initState() {
    super.initState();

    _otpController = Get.isRegistered<OtpController>()
        ? Get.find<OtpController>()
        : Get.put(OtpController());

    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppFeedback.success(
        context,
        AppLocalizations.of(context).translate('success_otp_sent'),
      );
    });
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
      } else {
        if (mounted) {
          setState(() => _seconds--);
        }
      }
    });
  }

  Future<void> _resendCode() async {
    final success = await _otpController.sendOtp(email: _email);

    if (!mounted) return;

    if (success) {
      setState(() => _seconds = 60);
      _startTimer();

      AppFeedback.success(
        context,
        AppLocalizations.of(context).translate('success_new_otp_sent'),
      );
    } else {
      AppFeedback.error(
        context,
        _otpController.errorMessage.value.isNotEmpty
            ? _otpController.errorMessage.value
            : AppLocalizations.of(context).translate('error_resend_otp'),
      );
    }
  }

  String _getOtpCode() {
    return _controllers.map((controller) => controller.text.trim()).join();
  }

  void _setOtpCode(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    for (int i = 0; i < _controllers.length; i++) {
      final text = i < digits.length ? digits[i] : '';

      _controllers[i].value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    if (digits.length >= 6) {
      FocusScope.of(context).unfocus();
    } else if (digits.length < _focusNodes.length) {
      _focusNodes[digits.length].requestFocus();
    }
  }

  void _handleOtpChanged(String value, int index) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 1) {
      _setOtpCode(digits);
      return;
    }

    if (digits.isEmpty) {
      _controllers[index].clear();

      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }

      return;
    }

    _controllers[index].value = TextEditingValue(
      text: digits,
      selection: const TextSelection.collapsed(offset: 1),
    );

    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _getOtpCode();

    if (otp.length != 6) {
      AppFeedback.error(
        context,
        AppLocalizations.of(context).translate('error_otp_6_digits'),
      );
      return;
    }

    final success = await _otpController.verifyOtp(email: _email, otp: otp);

    if (!mounted) return;

    if (!success) {
      AppFeedback.error(
        context,
        _otpController.errorMessage.value.isNotEmpty
            ? _otpController.errorMessage.value
            : AppLocalizations.of(context).translate('error_invalid_otp'),
      );
      return;
    }

    final response = _otpController.lastVerifyRegisterResponse;

    final token = response?['token']?.toString().trim();

    if (token == null || token.isEmpty) {
      AppFeedback.error(
        context,
        AppLocalizations.of(context).translate('error_token_not_returned'),
      );
      return;
    }

    final pending = widget.pendingRegistrationData;

    final dynamic userRaw = response?['user'] ?? response?['0'];

    final dynamic profileRaw = response?['profile'] ?? response?['1'];

    Map<String, dynamic>? user;
    Map<String, dynamic>? profile;

    if (userRaw is Map) {
      user = Map<String, dynamic>.from(userRaw);
    }

    if (profileRaw is Map) {
      profile = Map<String, dynamic>.from(profileRaw);
    }

    await TokenStorage.clear();

    await TokenStorage.saveToken(token);
    await TokenStorage.saveUserEmail(_email);

    String role = pending?.role ?? 'customer';

    if (user != null) {
      final roleValue = user['role']?.toString().trim();

      if (roleValue != null && roleValue.isNotEmpty) {
        role = roleValue;
      }

      final userId = int.tryParse(user['id']?.toString() ?? '');

      if (userId != null) {
        await TokenStorage.saveUserId(userId);
      }
    }

    await TokenStorage.saveUserRole(role);

    if (profile != null) {
      final profileImageUrl =
          profile['profile_image_url'] ??
          profile['profile_image'] ??
          profile['image'] ??
          response?['profile_image_url'];

      final identityImageUrl =
          profile['identity_image_url'] ??
          profile['identity_image'] ??
          response?['identity_image_url'];

      await TokenStorage.saveProfileData(
        firstName: profile['first_name']?.toString(),
        lastName: profile['last_name']?.toString(),
        dateOfBirth: profile['date_of_birth']?.toString(),
        governorate: profile['governorate']?.toString(),
        profileImageUrl: profileImageUrl?.toString(),
        identityImageUrl: identityImageUrl?.toString(),
      );
    } else if (pending != null) {
      await TokenStorage.saveProfileData(
        firstName: pending.firstName,
        lastName: pending.lastName,
        dateOfBirth: pending.dateOfBirth,
        governorate: pending.governorate,
      );
    }

    final roleValue = role.trim().toLowerCase();
    final isBuyer = roleValue == 'customer' || roleValue == 'buyer';

    if (!mounted) return;

    AppFeedback.success(
      context,
      AppLocalizations.of(context).translate('success_account_verified'),
    );

    if (!mounted) return;

    final Widget destination = isBuyer
        ? const HomePage(isBuyer: true)
        : const SellerHomePage();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
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
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
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
              left: isArabic ? null : 20,
              right: isArabic ? 20 : null,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppTheme.inputFieldBg
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isArabic
                        ? Icons.arrow_back_ios_rounded
                        : Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.white,
                    size: 16,
                  ),
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
                    color: Colors.white.withValues(
                      alpha: isDarkMode ? 0.05 : 0.15,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.sms_outlined,
                    color: isDarkMode ? AppTheme.accentBlue : AppTheme.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context).translate('Verify Your Account'),
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
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
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.of(context)
              .translate('verification_code_sent_to')
              .replaceAll('{email}', _email),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBoxes(bool isDarkMode) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        textDirection: TextDirection.ltr,
        children: List.generate(6, (i) {
          return Container(
            width: 42,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: i == 5
                  ? TextInputAction.done
                  : TextInputAction.next,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
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
                  borderSide: isDarkMode
                      ? BorderSide.none
                      : const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: isDarkMode
                      ? BorderSide.none
                      : const BorderSide(color: AppTheme.border),
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
              onChanged: (value) => _handleOtpChanged(value, i),
              onSubmitted: (_) {
                if (i < 5) {
                  _focusNodes[i + 1].requestFocus();
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimer(bool isDarkMode) {
    final Color primaryLinkColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Obx(() {
      final isSending = _otpController.isSending.value;

      return Column(
        children: [
          Text(
            AppLocalizations.of(context).translate("Didn't receive the code?"),
            style: TextStyle(
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          if (isSending)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryLinkColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).translate('sending_code_msg'),
                  style: TextStyle(
                    color: primaryLinkColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else if (_seconds > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, size: 15, color: primaryLinkColor),
                const SizedBox(width: 6),
                Text(
                  '${AppLocalizations.of(context).translate('Resend in')} ${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: primaryLinkColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else
            GestureDetector(
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
    });
  }

  Widget _buildVerifyButton(bool isDarkMode) {
    return Obx(() {
      final isLoading = _otpController.isLoading.value;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : _verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode
                ? AppTheme.selectedBorder
                : AppTheme.primary,
            foregroundColor: AppTheme.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
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
                  AppLocalizations.of(context).translate('Verify & Continue'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      );
    });
  }

  Widget _buildChangeNumber(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context).translate('wrong_email_question'),
          style: TextStyle(
            color: isDarkMode ? AppTheme.textSecondary : Colors.grey,
            fontSize: 13,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context).translate('change_it_btn'),
            style: TextStyle(
              color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
