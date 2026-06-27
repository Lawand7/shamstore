import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shamstore/screen/otp_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _selectedRole = 'buyer';
  String? _selectedGovernorate;
  String? _profileImagePath;

  // 💡 متغيرات إضافية لحالة البائع
  String? _idCardImagePath;
  bool _isLocationSelected = false;

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _dobController = TextEditingController();
  final _walletPinController = TextEditingController();

  final List<String> _governorates = [
    'Damascus', 'Aleppo', 'Homs', 'Hama', 'Latakia',
    'Tartus', 'Deir ez-Zor', 'Al-Hasakah', 'Raqqa',
    'Daraa', 'Sweida', 'Quneitra', 'Idlib',
  ];

  void _pickImage() {
    setState(() => _profileImagePath = 'selected');
  }

  // 💡 دالة رفع صورة الهوية الخاصة بالبائع
  void _pickIdCardImage() {
    setState(() => _idCardImagePath = 'id_selected');
  }

  // 💡 دالة محاكاة اختيار الموقع من الخريطة المصغرة
  void _openMiniMap() {
    setState(() => _isLocationSelected = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate('Location selected successfully')),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              surface: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
            ),
            dialogBackgroundColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _dobController.dispose();
    _walletPinController.dispose();
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfilePicker(isDarkMode),
                  const SizedBox(height: 16),
                  _buildRoleSelector(isDarkMode),

                  // 💡 الحقول الشرطية: تظهر فقط عند اختيار دور البائع (seller)
                  if (_selectedRole == 'seller') ...[
                    const SizedBox(height: 16),
                    _buildIdCardPicker(isDarkMode),
                  ],

                  const SizedBox(height: 16),
                  _buildForm(isDarkMode),
                  const SizedBox(height: 16),
                  _buildCreateButton(isDarkMode),
                  const SizedBox(height: 32),
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
                  child: const Icon(Icons.arrow_back, color: AppTheme.white, size: 18),
                ),
              ),
            ),
            Text(
              AppLocalizations.of(context).translate('Create Account'),
              style: const TextStyle(color: AppTheme.white, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicker(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.05), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('Profile Picture'),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
          ),
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border, width: 1.5),
                    ),
                    child: _profileImagePath != null
                        ? Icon(Icons.person, size: 44, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary)
                        : Icon(Icons.person_outline, size: 44, color: isDarkMode ? AppTheme.iconUnselected : AppTheme.textLight),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: AppTheme.white, size: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              _profileImagePath != null
                  ? AppLocalizations.of(context).translate('Tap to change photo')
                  : AppLocalizations.of(context).translate('Tap to upload photo'),
              style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.05), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('I want to join as'),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRoleCard(
                  'buyer',
                  Icons.shopping_bag_outlined,
                  AppLocalizations.of(context).translate('Buyer'),
                  AppLocalizations.of(context).translate('Browse & buy'),
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRoleCard(
                  'seller',
                  Icons.store_outlined,
                  AppLocalizations.of(context).translate('Seller'),
                  AppLocalizations.of(context).translate('List & sell'),
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(String role, IconData icon, String title, String subtitle, bool isDarkMode) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? AppTheme.selectedBorder.withOpacity(0.2) : AppTheme.primaryLight)
              : (isDarkMode ? AppTheme.inputFieldBg : AppTheme.background),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? (isDarkMode ? AppTheme.selectedBorder : AppTheme.primary)
                : (isDarkMode ? Colors.transparent : AppTheme.border),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: isSelected ? (isDarkMode ? AppTheme.accentBlue : AppTheme.primary) : (isDarkMode ? AppTheme.iconUnselected : AppTheme.textLight)),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? (isDarkMode ? AppTheme.textPrimary : AppTheme.primary) : (isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey))),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11, color: isSelected ? (isDarkMode ? AppTheme.textSecondary : AppTheme.primarySoft) : (isDarkMode ? AppTheme.iconUnselected : AppTheme.textLight))),
          ],
        ),
      ),
    );
  }

  Widget _buildIdCardPicker(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.05), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('Identity Card Image'),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickIdCardImage,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _idCardImagePath != null ? Colors.green.withOpacity(0.5) : (isDarkMode ? Colors.transparent : AppTheme.border), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _idCardImagePath != null ? Icons.assignment_turned_in_outlined : Icons.add_photo_alternate_outlined,
                    color: _idCardImagePath != null ? Colors.green : (isDarkMode ? AppTheme.accentBlue : AppTheme.primary),
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _idCardImagePath != null
                        ? AppLocalizations.of(context).translate('ID Card Uploaded')
                        : AppLocalizations.of(context).translate('Tap to upload National ID card'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _idCardImagePath != null ? Colors.green : (isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
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

  Widget _buildForm(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.05), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildField(
            label: AppLocalizations.of(context).translate('First Name'),
            hint: AppLocalizations.of(context).translate('Enter your first name'),
            icon: Icons.person_outline,
            controller: _nameController,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: AppLocalizations.of(context).translate('Last Name'),
            hint: AppLocalizations.of(context).translate('Enter your last name'),
            icon: Icons.person_outline,
            controller: _lastNameController,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('Dark Mode' != null ? 'Date of Birth' : ''),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dobController,
                readOnly: true,
                onTap: () => _selectDate(context),
                style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('Select your birth date'),
                  hintStyle: TextStyle(fontSize: 13, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, size: 18),
                  filled: true,
                  fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildField(
            label: AppLocalizations.of(context).translate('Phone Number'),
            hint: AppLocalizations.of(context).translate('Enter your phone number'),
            icon: Icons.phone_outlined,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          _buildGovernorateDropdown(isDarkMode),
          const SizedBox(height: 14),
          _buildField(
            label: AppLocalizations.of(context).translate('Password'),
            hint: AppLocalizations.of(context).translate('Create a password'),
            icon: Icons.lock_outline,
            controller: _passwordController,
            isPassword: true,
            obscure: _obscurePassword,
            onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: AppLocalizations.of(context).translate('Confirm Password'),
            hint: AppLocalizations.of(context).translate('Repeat your password'),
            icon: Icons.lock_outline,
            controller: _confirmController,
            isPassword: true,
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('Wallet PIN (4 Digits)'),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _walletPinController,
                obscureText: true,
                obscuringCharacter: '●',
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('Set 4-digit PIN for wallet safety'),
                  hintStyle: TextStyle(fontSize: 13, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                  counterText: '',
                  prefixIcon: Icon(Icons.wallet_membership_outlined, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, size: 18),
                  filled: true,
                  fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGovernorateDropdown(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('Governorate'),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGovernorate,
          dropdownColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          hint: Text(
            AppLocalizations.of(context).translate('Select your governorate'),
            style: TextStyle(fontSize: 13, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
          ),
          style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.location_on_outlined, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, size: 18),
            filled: true,
            fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary)),
          ),
          items: _governorates.map((gov) => DropdownMenuItem(
            value: gov,
            child: Text(
              AppLocalizations.of(context).translate(gov),
              style: TextStyle(fontSize: 13, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
            ),
          )).toList(),
          onChanged: (val) => setState(() => _selectedGovernorate = val),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool isDarkMode,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? obscure : false,
          keyboardType: keyboardType,
          style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, fontSize: 13),
            prefixIcon: Icon(icon, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, size: 18),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: isDarkMode ? AppTheme.iconUnselected : AppTheme.textLight, size: 18),
              onPressed: onToggle,
            )
                : null,
            filled: true,
            fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(phoneNumber: _phoneController.text))),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          AppLocalizations.of(context).translate('Create Account'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}