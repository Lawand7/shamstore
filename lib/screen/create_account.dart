import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shamstore/features/auth/controllers/register_controller.dart';
import 'package:shamstore/screen/otp_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  late final RegisterController _registerController;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String _selectedRole = 'buyer';
  String? _selectedGovernorate;

  XFile? _profileImage;
  XFile? _identityImage;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _dobController = TextEditingController();
  final _walletPinController = TextEditingController();

  final List<String> _governorates = [
    'Damascus',
    'Aleppo',
    'Homs',
    'Hama',
    'Latakia',
    'Tartous',
    'Idlib',
    'Deir el-Zor',
    'Raqqa',
    'Hasakah',
    'Suwayda',
    'Daraa',
    'Quneitra',
    'Rif Dimashq',
  ];

  @override
  void initState() {
    super.initState();

    _registerController = Get.isRegistered<RegisterController>()
        ? Get.find<RegisterController>()
        : Get.put(RegisterController());
  }

  Future<void> _pickProfileImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _profileImage = picked;
      });
    }
  }

  Future<void> _pickIdentityImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _identityImage = picked;
      });
    }
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
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _dobController.dispose();
    _walletPinController.dispose();
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfilePicker(isDarkMode),
                  const SizedBox(height: 16),
                  _buildRoleSelector(isDarkMode),
                  if (_selectedRole == 'seller') ...[
                    const SizedBox(height: 16),
                    _buildIdentityPicker(isDarkMode),
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
                    color: isDarkMode
                        ? AppTheme.inputFieldBg
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppTheme.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            Text(
              AppLocalizations.of(context).translate('Create Account'),
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicker(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('Profile Picture'),
            style: _labelStyle(isDarkMode),
          ),
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: _pickProfileImage,
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppTheme.inputFieldBg
                          : AppTheme.background,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.transparent
                            : AppTheme.border,
                        width: 1.5,
                      ),
                    ),
                    child: _profileImage != null
                        ? ClipOval(
                            child: Image.file(
                              File(_profileImage!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person_outline,
                            size: 44,
                            color: isDarkMode
                                ? AppTheme.iconUnselected
                                : AppTheme.textLight,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppTheme.selectedBorder
                            : AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppTheme.white,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              _profileImage != null
                  ? AppLocalizations.of(
                      context,
                    ).translate('Tap to change photo')
                  : AppLocalizations.of(
                      context,
                    ).translate('Tap to upload photo'),
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('I want to join as'),
            style: _labelStyle(isDarkMode),
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

  Widget _buildRoleCard(
    String role,
    IconData icon,
    String title,
    String subtitle,
    bool isDarkMode,
  ) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;

          if (_selectedRole == 'buyer') {
            _identityImage = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode
                    ? AppTheme.selectedBorder.withOpacity(0.2)
                    : AppTheme.primaryLight)
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
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? (isDarkMode ? AppTheme.accentBlue : AppTheme.primary)
                  : (isDarkMode ? AppTheme.iconUnselected : AppTheme.textLight),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? (isDarkMode ? AppTheme.textPrimary : AppTheme.primary)
                    : (isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? (isDarkMode
                          ? AppTheme.textSecondary
                          : AppTheme.primarySoft)
                    : (isDarkMode
                          ? AppTheme.iconUnselected
                          : AppTheme.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityPicker(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('Identity Card Image'),
            style: _labelStyle(isDarkMode),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickIdentityImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _identityImage != null
                      ? Colors.green.withOpacity(0.5)
                      : (isDarkMode ? Colors.transparent : AppTheme.border),
                  width: 1.5,
                ),
              ),
              child: _identityImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(_identityImage!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: isDarkMode
                              ? AppTheme.accentBlue
                              : AppTheme.primary,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).translate('Tap to upload National ID card'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode
                                ? AppTheme.textSecondary
                                : AppTheme.textGrey,
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
      decoration: _cardDecoration(isDarkMode),
      child: Column(
        children: [
          _buildField(
            label: AppLocalizations.of(context).translate('First Name'),
            hint: AppLocalizations.of(
              context,
            ).translate('Enter your first name'),
            icon: Icons.person_outline,
            controller: _firstNameController,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: AppLocalizations.of(context).translate('Last Name'),
            hint: AppLocalizations.of(
              context,
            ).translate('Enter your last name'),
            icon: Icons.person_outline,
            controller: _lastNameController,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: AppLocalizations.of(context).translate('Email Address'),
            hint: AppLocalizations.of(context).translate('Enter your email'),
            icon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          _buildDateField(isDarkMode),
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
            onToggle: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: AppLocalizations.of(context).translate('Confirm Password'),
            hint: AppLocalizations.of(
              context,
            ).translate('Repeat your password'),
            icon: Icons.lock_outline,
            controller: _confirmController,
            isPassword: true,
            obscure: _obscureConfirm,
            onToggle: () {
              setState(() => _obscureConfirm = !_obscureConfirm);
            },
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          _buildWalletPinField(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildDateField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('Date of Birth'),
          style: _labelStyle(isDarkMode),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _dobController,
          readOnly: true,
          onTap: () => _selectDate(context),
          style: TextStyle(
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
          ),
          decoration: _inputDecoration(
            hint: AppLocalizations.of(
              context,
            ).translate('Select your birth date'),
            icon: Icons.calendar_today_outlined,
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletPinField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('Wallet PIN (4 Digits)'),
          style: _labelStyle(isDarkMode),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _walletPinController,
          obscureText: true,
          obscuringCharacter: '●',
          keyboardType: TextInputType.number,
          maxLength: 4,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
          ),
          decoration: _inputDecoration(
            hint: AppLocalizations.of(
              context,
            ).translate('Set 4-digit PIN for wallet safety'),
            icon: Icons.wallet_membership_outlined,
            isDarkMode: isDarkMode,
          ).copyWith(counterText: ''),
        ),
      ],
    );
  }

  Widget _buildGovernorateDropdown(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('Governorate'),
          style: _labelStyle(isDarkMode),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGovernorate,
          dropdownColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          hint: Text(
            AppLocalizations.of(context).translate('Select your governorate'),
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
            ),
          ),
          style: TextStyle(
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
          ),
          decoration: _inputDecoration(
            hint: '',
            icon: Icons.location_on_outlined,
            isDarkMode: isDarkMode,
          ),
          items: _governorates.map((gov) {
            return DropdownMenuItem(
              value: gov,
              child: Text(
                AppLocalizations.of(context).translate(gov),
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _selectedGovernorate = val);
          },
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
        Text(label, style: _labelStyle(isDarkMode)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? obscure : false,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
          ),
          decoration: _inputDecoration(
            hint: hint,
            icon: icon,
            isDarkMode: isDarkMode,
            isPassword: isPassword,
            obscure: obscure,
            onToggle: onToggle,
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(bool isDarkMode) {
    return Obx(() {
      final isLoading = _registerController.isLoading.value;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : _submitRegister,
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
                  AppLocalizations.of(context).translate('Create Account'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      );
    });
  }

  Future<void> _submitRegister() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmController.text.trim();
    final dateOfBirth = _dobController.text.trim();
    final governorate = _selectedGovernorate;
    final walletPin = _walletPinController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        dateOfBirth.isEmpty ||
        governorate == null ||
        walletPin.isEmpty) {
      AppFeedback.error(context, 'يرجى تعبئة جميع الحقول المطلوبة');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      AppFeedback.error(context, 'يرجى إدخال بريد إلكتروني صحيح');
      return;
    }

    if (_profileImage == null) {
      AppFeedback.error(context, 'يرجى اختيار صورة الملف الشخصي');
      return;
    }

    if (_selectedRole == 'seller' && _identityImage == null) {
      AppFeedback.error(context, 'يرجى اختيار صورة الهوية للبائع');
      return;
    }

    if (password != confirmPassword) {
      AppFeedback.error(context, 'كلمة المرور وتأكيد كلمة المرور غير متطابقين');
      return;
    }

    if (walletPin.length != 4) {
      AppFeedback.error(context, 'رمز المحفظة يجب أن يكون 4 أرقام');
      return;
    }

    final apiRole = _selectedRole == 'buyer' ? 'customer' : 'seller';

    final success = await _registerController.register(
      email: email,
      password: password,
      passwordConfirmation: confirmPassword,
      role: apiRole,
      dateOfBirth: dateOfBirth,
      firstName: firstName,
      lastName: lastName,
      governorate: governorate,
      walletPin: walletPin,
      profileImagePath: _profileImage!.path,
      identityImagePath: _identityImage?.path,
    );

    if (!mounted) return;

    if (!success) {
      AppFeedback.error(
        context,
        _registerController.errorMessage.value.isNotEmpty
            ? _registerController.errorMessage.value
            : 'حدث خطأ أثناء إنشاء الحساب',
      );
      return;
    }

    AppFeedback.success(
      context,
      'يرجى إدخال الرمز المرسل إلى البريد الإلكتروني',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phoneNumber: email,
          pendingRegistrationData: PendingRegistrationData(
            email: email,
            role: apiRole,
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            governorate: governorate,
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.05),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  TextStyle _labelStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
        size: 18,
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: isDarkMode
                    ? AppTheme.iconUnselected
                    : AppTheme.textLight,
                size: 18,
              ),
              onPressed: onToggle,
            )
          : null,
      filled: true,
      fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
        ),
      ),
    );
  }
}
