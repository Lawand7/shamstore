import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/core/storage/token_storage.dart';
import 'package:shamstore/features/auth/controllers/logout_controller.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/screen/login_page.dart';
import 'package:shamstore/screen/about_app_page.dart';
import 'package:shamstore/screen/settings_page.dart';
import 'package:shamstore/screen/my_ads_page.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/screen/support_page.dart';
import 'package:shamstore/screen/security_settings_page.dart';
import 'package:shamstore/screen/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final bool isBuyer;

  const ProfilePage({super.key, this.isBuyer = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final LogoutController _logoutController;

  String _firstName = '';
  String _lastName = '';
  String _selectedGovernorate = '';
  String _dateOfBirth = '';

  String? _profileImagePath;
  String? _profileImageUrl;

  String get _fullName => '${_firstName.trim()} ${_lastName.trim()}'.trim();

  String get _email {
    final email = TokenStorage.getUserEmail();
    if (email == null || email.trim().isEmpty) {
      return AppLocalizations.of(context).translate('not_available');
    }
    return email;
  }

  String get _accountRole {
    final role = TokenStorage.getUserRole();

    if (role != null && role.trim().isNotEmpty) {
      return role.trim().toLowerCase();
    }

    return widget.isBuyer ? 'buyer' : 'seller';
  }

  bool get _isSeller => _accountRole == 'seller';

  String _accountTypeLabel(BuildContext context) {
    if (_accountRole == 'seller') {
      return AppLocalizations.of(context).translate('Seller');
    }

    return AppLocalizations.of(context).translate('Buyer');
  }

  @override
  void initState() {
    super.initState();

    _logoutController = Get.isRegistered<LogoutController>()
        ? Get.find<LogoutController>()
        : Get.put(LogoutController());

    _loadProfileFromStorage();
  }

  void _loadProfileFromStorage() {
    _firstName = TokenStorage.getProfileFirstName() ?? '';
    _lastName = TokenStorage.getProfileLastName() ?? '';
    _selectedGovernorate = TokenStorage.getProfileGovernorate() ?? '';
    _dateOfBirth = TokenStorage.getProfileDateOfBirth() ?? '';
    _profileImageUrl = _normalizeProfileImageUrl(
      TokenStorage.getProfileImageUrl(),
    );
  }

  String? _normalizeProfileImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;

    final value = rawUrl.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final serverBaseUrl = ApiConstants.baseUrl.replaceFirst('/api', '');

    if (value.startsWith('/storage/')) {
      return '$serverBaseUrl$value';
    }

    if (value.startsWith('storage/')) {
      return '$serverBaseUrl/$value';
    }

    return '$serverBaseUrl/storage/$value';
  }

  Future<void> _performLogout(BuildContext dialogContext) async {
    final dialogNavigator = Navigator.of(dialogContext);
    final pageNavigator = Navigator.of(context);

    final localLogoutDone = await _logoutController.logout();

    if (!mounted) return;

    if (dialogNavigator.canPop()) {
      dialogNavigator.pop();
    }

    if (!localLogoutDone) {
      AppFeedback.error(
        context,
        _logoutController.errorMessage.value.isNotEmpty
            ? _logoutController.errorMessage.value
            : AppLocalizations.of(context).translate('error_logout'),
      );
      return;
    }

    pageNavigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _openEditProfilePage() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          initialFirstName: _firstName,
          initialLastName: _lastName,
          initialGovernorate: _selectedGovernorate.isNotEmpty
              ? _selectedGovernorate
              : 'Daraa',
          initialDateOfBirth: _dateOfBirth.isNotEmpty
              ? _dateOfBirth
              : '2000-01-01',
          initialProfileImagePath: _profileImagePath ?? _profileImageUrl,
        ),
      ),
    );

    if (!mounted || result == null) return;

    final firstName = result['first_name']?.toString() ?? _firstName;
    final lastName = result['last_name']?.toString() ?? _lastName;
    final dateOfBirth = result['date_of_birth']?.toString() ?? _dateOfBirth;
    final governorate =
        result['governorate']?.toString() ?? _selectedGovernorate;

    final returnedLocalPath = result['profile_image_path']?.toString();
    final returnedImageUrl = result['profile_image_url']?.toString();

    await TokenStorage.saveProfileData(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      governorate: governorate,
      profileImageUrl: returnedImageUrl,
    );

    if (!mounted) return;

    setState(() {
      _firstName = firstName;
      _lastName = lastName;
      _dateOfBirth = dateOfBirth;
      _selectedGovernorate = governorate;

      if (returnedLocalPath != null && returnedLocalPath.trim().isNotEmpty) {
        _profileImagePath = returnedLocalPath;
      }

      if (returnedImageUrl != null && returnedImageUrl.trim().isNotEmpty) {
        _profileImageUrl = _normalizeProfileImageUrl(returnedImageUrl);
      }
    });
  }

  bool _isLocalImagePath(String? path) {
    if (path == null || path.trim().isEmpty) return false;

    final value = path.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return false;
    }

    return File(value).existsSync();
  }

  bool _isNetworkImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;

    final value = url.trim();
    return value.startsWith('http://') || value.startsWith('https://');
  }

  String _safeValue(BuildContext context, String value) {
    return value.trim().isNotEmpty
        ? value.trim()
        : AppLocalizations.of(context).translate('not_available');
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
            _buildHero(isDarkMode),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildInfoCard(isDarkMode),
                  const SizedBox(height: 16),
                  _buildMenuCard(isDarkMode),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(bool isDarkMode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(top: 54, bottom: 28),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: ClipOval(child: _buildProfileImage()),
          ),
          const SizedBox(height: 12),
          Text(
            _fullName.isNotEmpty
                ? _fullName
                : AppLocalizations.of(context).translate('not_available'),
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _accountTypeLabel(context),
              style: const TextStyle(color: AppTheme.white, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _openEditProfilePage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit_outlined,
                    size: 15,
                    color: AppTheme.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).translate('Edit Profile'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_isLocalImagePath(_profileImagePath)) {
      return Image.file(
        File(_profileImagePath!),
        fit: BoxFit.cover,
        width: 92,
        height: 92,
        errorBuilder: (_, __, ___) => _defaultProfileIcon(),
      );
    }

    if (_isNetworkImageUrl(_profileImageUrl)) {
      return Image.network(
        _profileImageUrl!,
        fit: BoxFit.cover,
        width: 92,
        height: 92,
        errorBuilder: (_, __, ___) => _defaultProfileIcon(),
      );
    }

    return _defaultProfileIcon();
  }

  Widget _defaultProfileIcon() {
    return const Icon(Icons.person_outline, size: 46, color: AppTheme.white);
  }

  Widget _buildInfoCard(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.person_outline,
            AppLocalizations.of(context).translate('Full Name'),
            _fullName.isNotEmpty
                ? _fullName
                : AppLocalizations.of(context).translate('not_available'),
            isDarkMode,
          ),
          _divider(isDarkMode),
          _infoRow(
            Icons.email_outlined,
            AppLocalizations.of(context).translate('Email Address'),
            _email,
            isDarkMode,
          ),
          _divider(isDarkMode),
          _infoRow(
            Icons.calendar_today_outlined,
            AppLocalizations.of(context).translate('Date of Birth'),
            _safeValue(context, _dateOfBirth),
            isDarkMode,
          ),
          _divider(isDarkMode),
          _infoRow(
            Icons.location_on_outlined,
            AppLocalizations.of(context).translate('Governorate'),
            _selectedGovernorate.trim().isNotEmpty
                ? AppLocalizations.of(
                    context,
                  ).translate(_selectedGovernorate.trim())
                : AppLocalizations.of(context).translate('not_available'),
            isDarkMode,
          ),
          _divider(isDarkMode),
          _infoRow(
            _isSeller ? Icons.store_outlined : Icons.shopping_bag_outlined,
            AppLocalizations.of(context).translate('Account Type'),
            _accountTypeLabel(context),
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode
                        ? AppTheme.textSecondary
                        : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? AppTheme.textPrimary
                        : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDarkMode) {
    return Divider(
      height: 1,
      color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildMenuCard(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _menuItem(
            AppLocalizations.of(context).translate('support_title'),
            Icons.support_agent_rounded,
            isDarkMode,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportPage()),
              );
            },
          ),
          _divider(isDarkMode),
          _menuItem(
            AppLocalizations.of(context).translate('my_ads'),
            Icons.campaign_outlined,
            isDarkMode,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyAdsPage()),
              );
            },
          ),
          _divider(isDarkMode),
          _menuItem(
            AppLocalizations.of(context).translate('Notifications'),
            Icons.notifications_none_outlined,
            isDarkMode,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
          _divider(isDarkMode),
          _menuItem(
            AppLocalizations.of(context).translate('Security Settings'),
            Icons.security_rounded,
            isDarkMode,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecuritySettingsPage()),
              );
            },
          ),
          _divider(isDarkMode),
          _menuItem(
            AppLocalizations.of(context).translate('Settings'),
            Icons.settings_outlined,
            isDarkMode,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
          _divider(isDarkMode),
          _menuItem(
            AppLocalizations.of(context).translate('About App'),
            Icons.info_outline,
            isDarkMode,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutAppPage()),
              );
            },
          ),
          _divider(isDarkMode),
          _menuItem(
            AppLocalizations.of(context).translate('Logout'),
            Icons.logout,
            isDarkMode,
            color: AppTheme.error,
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: isDarkMode
                        ? AppTheme.cardBackground
                        : AppTheme.white,
                    title: Text(
                      AppLocalizations.of(
                        dialogContext,
                      ).translate('Logout Confirm Title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppTheme.textPrimary
                            : AppTheme.textDark,
                      ),
                    ),
                    content: Text(
                      AppLocalizations.of(
                        dialogContext,
                      ).translate('Logout Confirm Message'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textGrey,
                      ),
                    ),
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    actions: [
                      Obx(() {
                        final isLoading = _logoutController.isLoading.value;

                        return TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(dialogContext),
                          child: Text(
                            AppLocalizations.of(dialogContext).translate('No'),
                            style: TextStyle(
                              color: isDarkMode
                                  ? AppTheme.textSecondary
                                  : AppTheme.textLight,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }),
                      Obx(() {
                        final isLoading = _logoutController.isLoading.value;

                        return ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => _performLogout(dialogContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(
                                    dialogContext,
                                  ).translate('Yes'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      }),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    String label,
    IconData icon,
    bool isDarkMode, {
    Color? color,
    required VoidCallback onTap,
  }) {
    final c = color ?? (isDarkMode ? AppTheme.textPrimary : AppTheme.textDark);
    final Color activePrimary = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.chevron_left,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
              size: 18,
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: c,
                fontWeight: color != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (color ?? activePrimary).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color ?? activePrimary),
            ),
          ],
        ),
      ),
    );
  }
}
