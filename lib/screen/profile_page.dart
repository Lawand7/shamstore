import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/screen/login_page.dart';
import 'package:shamstore/screen/about_app_page.dart';
import 'package:shamstore/screen/settings_page.dart';
import 'package:shamstore/screen/forgot_password_screen.dart';
import 'package:shamstore/utils/app_localizations.dart'; // استدعاء ملف الترجمة الخاص بك

class ProfilePage extends StatefulWidget {
  final bool isBuyer;
  const ProfilePage({super.key, this.isBuyer = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  final _nameController     = TextEditingController(text: 'Ahmed Al-Khateeb');
  final _phoneController    = TextEditingController(text: '0911 234 567');
  final _passwordController = TextEditingController(text: '');
  String _selectedGovernorate = 'Damascus';
  String? _profileImagePath;

  bool _obscurePassword = true;

  final List<String> _governorates = [
    'Damascus', 'Aleppo', 'Homs', 'Hama', 'Latakia',
    'Tartus', 'Deir ez-Zor', 'Al-Hasakah', 'Raqqa',
    'Daraa', 'Sweida', 'Quneitra', 'Idlib',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 فحص حالة الدارك مود الحالية بالتطبيق ديناميكياً
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(isDarkMode),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _isEditing ? _buildEditForm(isDarkMode) : _buildInfoCard(isDarkMode),
                  const SizedBox(height: 16),
                  if (!_isEditing) _buildMenuCard(isDarkMode),
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
          Stack(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                ),
                child: _profileImagePath != null
                    ? const Icon(Icons.person, size: 44, color: AppTheme.white)
                    : const Icon(Icons.person_outline, size: 44, color: AppTheme.white),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => setState(() => _profileImagePath = 'selected'),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(color: AppTheme.white, shape: BoxShape.circle),
                      child: Icon(Icons.camera_alt, color: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary, size: 14),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _nameController.text,
            style: const TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              !widget.isBuyer
                  ? AppLocalizations.of(context).translate('Seller')
                  : AppLocalizations.of(context).translate('Buyer'),
              style: const TextStyle(color: AppTheme.white, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _isEditing = !_isEditing),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
              decoration: BoxDecoration(
                color: _isEditing ? Colors.white : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isEditing ? Icons.check : Icons.edit_outlined,
                    size: 15,
                    color: _isEditing ? (isDarkMode ? AppTheme.darkBackground : AppTheme.primary) : AppTheme.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isEditing
                        ? AppLocalizations.of(context).translate('Save Changes')
                        : AppLocalizations.of(context).translate('Edit Profile'),
                    style: TextStyle(
                      fontSize: 13,
                      color: _isEditing ? (isDarkMode ? AppTheme.darkBackground : AppTheme.primary) : AppTheme.white,
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

  Widget _buildInfoCard(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.05), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _infoRow(
              Icons.person_outline,
              AppLocalizations.of(context).translate('Full Name'),
              _nameController.text,
              isDarkMode
          ),
          _divider(isDarkMode),
          _infoRow(
              Icons.phone_outlined,
              AppLocalizations.of(context).translate('Phone Number'),
              _phoneController.text,
              isDarkMode
          ),
          _divider(isDarkMode),
          _infoRow(
              Icons.location_on_outlined,
              AppLocalizations.of(context).translate('Governorate'),
              AppLocalizations.of(context).translate(_selectedGovernorate),
              isDarkMode
          ),
          _divider(isDarkMode),
          _infoRow(
            !widget.isBuyer ? Icons.store_outlined : Icons.shopping_bag_outlined,
            AppLocalizations.of(context).translate('Account Type'),
            !widget.isBuyer
                ? AppLocalizations.of(context).translate('Seller')
                : AppLocalizations.of(context).translate('Buyer'),
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
                Text(label, style: TextStyle(fontSize: 11, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight)),
                const SizedBox(height: 3),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark)),
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
            child: Icon(icon, size: 18, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDarkMode) => Divider(height: 1, color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border, indent: 16, endIndent: 16);

  Widget _buildEditForm(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.05), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('Edit Information'),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
          ),
          const SizedBox(height: 16),
          _editField(
              AppLocalizations.of(context).translate('Full Name'),
              Icons.person_outline,
              _nameController,
              isDarkMode
          ),
          const SizedBox(height: 14),
          _editField(
              AppLocalizations.of(context).translate('Phone Number'),
              Icons.phone_outlined,
              _phoneController,
              isDarkMode,
              keyboardType: TextInputType.phone
          ),
          const SizedBox(height: 14),
          _buildGovernorateDropdown(isDarkMode),
          const SizedBox(height: 14),
          _editPasswordField(isDarkMode),
        ],
      ),
    );
  }

  Widget _editField(String label, IconData icon, TextEditingController controller, bool isDarkMode, {TextInputType keyboardType = TextInputType.text}) {
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: activeColor, size: 18),
            filled: true,
            fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary)),
          ),
        ),
      ],
    );
  }

  Widget _editPasswordField(bool isDarkMode) {
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('New Password'),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 14),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).translate('Leave empty to keep current'),
            hintStyle: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary.withOpacity(0.5) : AppTheme.textLight),
            prefixIcon: Icon(Icons.lock_outline, color: activeColor, size: 18),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, size: 18),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildGovernorateDropdown(bool isDarkMode) {
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('Governorate'),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedGovernorate,
          dropdownColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.location_on_outlined, color: activeColor, size: 18),
            filled: true,
            fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary)),
          ),
          items: _governorates.map((gov) => DropdownMenuItem(
            value: gov,
            child: Text(
              AppLocalizations.of(context).translate(gov),
              style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 13),
            ),
          )).toList(),
          onChanged: (val) => setState(() => _selectedGovernorate = val!),
        ),
      ],
    );
  }

  Widget _buildMenuCard(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.05), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
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
            AppLocalizations.of(context).translate('Change Password'),
            Icons.lock_reset_outlined,
            isDarkMode,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
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
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    backgroundColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                    title: Text(
                      AppLocalizations.of(context).translate('Logout Confirm Title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                    ),
                    content: Text(
                      AppLocalizations.of(context).translate('Logout Confirm Message'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
                    ),
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.of(context).translate('No'),
                          style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, fontSize: 13),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        ),
                        child: Text(
                          AppLocalizations.of(context).translate('Yes'),
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
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

  Widget _menuItem(String label, IconData icon, bool isDarkMode, {Color? color, required VoidCallback onTap}) {
    final c = color ?? (isDarkMode ? AppTheme.textPrimary : AppTheme.textDark);
    final Color activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.chevron_left, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, size: 18),
            const Spacer(),
            Text(label, style: TextStyle(fontSize: 14, color: c, fontWeight: color != null ? FontWeight.w500 : FontWeight.normal)),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (color ?? activePrimary).withOpacity(0.08),
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