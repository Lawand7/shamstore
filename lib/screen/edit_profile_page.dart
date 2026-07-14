import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shamstore/features/auth/controllers/update_profile_controller.dart';
import 'package:shamstore/them/app_theme.dart';

class EditProfilePage extends StatefulWidget {
  final String initialFirstName;
  final String initialLastName;
  final String initialGovernorate;
  final String initialDateOfBirth;
  final String? initialProfileImagePath;

  const EditProfilePage({
    super.key,
    required this.initialFirstName,
    required this.initialLastName,
    required this.initialGovernorate,
    required this.initialDateOfBirth,
    this.initialProfileImagePath,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final UpdateProfileController _updateProfileController;

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _dateOfBirthController;

  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedProfileImagePath;
  late String _selectedGovernorate;

  final List<String> _governorates = const [
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

    _updateProfileController = Get.isRegistered<UpdateProfileController>()
        ? Get.find<UpdateProfileController>()
        : Get.put(UpdateProfileController());

    _firstNameController = TextEditingController(
      text: widget.initialFirstName.trim(),
    );
    _lastNameController = TextEditingController(
      text: widget.initialLastName.trim(),
    );
    _dateOfBirthController = TextEditingController(
      text: widget.initialDateOfBirth.trim(),
    );

    _selectedGovernorate = _governorates.contains(widget.initialGovernorate)
        ? widget.initialGovernorate
        : 'Daraa';

    _selectedProfileImagePath = widget.initialProfileImagePath;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedImage == null) return;

    setState(() {
      _selectedProfileImagePath = pickedImage.path;
    });
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    DateTime initialDate = DateTime(2000, 1, 1);

    final currentText = _dateOfBirthController.text.trim();
    if (currentText.isNotEmpty) {
      final parsedDate = DateTime.tryParse(currentText);
      if (parsedDate != null) {
        initialDate = parsedDate;
      }
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime(now.year - 10, now.month, now.day),
    );

    if (selectedDate == null) return;

    final year = selectedDate.year.toString().padLeft(4, '0');
    final month = selectedDate.month.toString().padLeft(2, '0');
    final day = selectedDate.day.toString().padLeft(2, '0');

    setState(() {
      _dateOfBirthController.text = '$year-$month-$day';
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

  Future<void> _submitUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final dateOfBirth = _dateOfBirthController.text.trim();
    final governorate = _selectedGovernorate.trim();

    final imagePathToUpload = _isLocalImagePath(_selectedProfileImagePath)
        ? _selectedProfileImagePath
        : null;

    final result = await _updateProfileController.updateProfile(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      governorate: governorate,
      profileImagePath: imagePathToUpload,
    );

    if (!mounted) return;

    if (result == null) {
      Get.snackbar(
        'فشل تحديث الملف الشخصي',
        _updateProfileController.errorMessage.value.isNotEmpty
            ? _updateProfileController.errorMessage.value
            : 'حدث خطأ أثناء تحديث الملف الشخصي',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final profile = result['profile'];

    Get.snackbar(
      'نجاح',
      result['message']?.toString() ?? 'تم تحديث الملف الشخصي بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );

    Navigator.pop(context, {
      'first_name': profile is Map && profile['first_name'] != null
          ? profile['first_name'].toString()
          : firstName,
      'last_name': profile is Map && profile['last_name'] != null
          ? profile['last_name'].toString()
          : lastName,
      'date_of_birth': profile is Map && profile['date_of_birth'] != null
          ? profile['date_of_birth'].toString()
          : dateOfBirth,
      'governorate': profile is Map && profile['governorate'] != null
          ? profile['governorate'].toString()
          : governorate,
      'profile_image_path': _selectedProfileImagePath,
      'profile_image_url': result['profile_image_url']?.toString(),
    });
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
        title: const Text(
          'تعديل الملف الشخصي',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            isArabic
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildProfileImagePicker(isDarkMode, activePrimary),
                const SizedBox(height: 24),

                _buildTextField(
                  controller: _firstNameController,
                  label: 'الاسم الأول',
                  hint: 'أدخل الاسم الأول',
                  icon: Icons.person_outline,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'الاسم الأول مطلوب';
                    if (text.length > 255) return 'الاسم الأول طويل جداً';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _lastNameController,
                  label: 'الاسم الأخير',
                  hint: 'أدخل الاسم الأخير',
                  icon: Icons.person_outline,
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'الاسم الأخير مطلوب';
                    if (text.length > 255) return 'الاسم الأخير طويل جداً';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildDateField(
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                ),

                const SizedBox(height: 16),

                _buildGovernorateDropdown(
                  isDarkMode: isDarkMode,
                  activePrimary: activePrimary,
                ),

                const SizedBox(height: 30),

                Obx(() {
                  final isLoading = _updateProfileController.isLoading.value;

                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitUpdateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activePrimary,
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
                          : const Text(
                              'حفظ التغييرات',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _buildProfileImagePicker(bool isDarkMode, Color activePrimary) {
    final imagePath = _selectedProfileImagePath;

    return Column(
      children: [
        GestureDetector(
          onTap: _pickProfileImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activePrimary.withOpacity(0.12),
                  border: Border.all(
                    color: activePrimary.withOpacity(0.35),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: _isLocalImagePath(imagePath)
                      ? Image.file(
                          File(imagePath!),
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Icon(
                              Icons.person_outline,
                              size: 52,
                              color: activePrimary,
                            );
                          },
                        )
                      : Icon(
                          Icons.person_outline,
                          size: 52,
                          color: activePrimary,
                        ),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: activePrimary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode
                        ? AppTheme.darkBackground
                        : AppTheme.background,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'اضغط لاختيار صورة من المعرض',
          style: TextStyle(
            color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    required Color activePrimary,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, isDarkMode),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          textInputAction: TextInputAction.next,
          style: TextStyle(
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            fontSize: 14,
          ),
          decoration: _inputDecoration(
            hint: hint,
            icon: icon,
            isDarkMode: isDarkMode,
            activePrimary: activePrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required bool isDarkMode,
    required Color activePrimary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('تاريخ الميلاد', isDarkMode),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateOfBirthController,
          readOnly: true,
          onTap: _selectDateOfBirth,
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return 'تاريخ الميلاد مطلوب';
            if (DateTime.tryParse(text) == null) {
              return 'صيغة تاريخ الميلاد غير صحيحة';
            }
            return null;
          },
          style: TextStyle(
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            fontSize: 14,
          ),
          decoration: _inputDecoration(
            hint: 'اختر تاريخ الميلاد',
            icon: Icons.calendar_today_outlined,
            isDarkMode: isDarkMode,
            activePrimary: activePrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildGovernorateDropdown({
    required bool isDarkMode,
    required Color activePrimary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('المحافظة', isDarkMode),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGovernorate,
          dropdownColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'المحافظة مطلوبة';
            }
            return null;
          },
          style: TextStyle(
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            fontSize: 14,
          ),
          decoration: _inputDecoration(
            hint: 'اختر المحافظة',
            icon: Icons.location_on_outlined,
            isDarkMode: isDarkMode,
            activePrimary: activePrimary,
          ),
          items: _governorates.map((governorate) {
            return DropdownMenuItem<String>(
              value: governorate,
              child: Text(governorate),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedGovernorate = value;
            });
          },
        ),
      ],
    );
  }

  Widget _fieldLabel(String text, bool isDarkMode) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? AppTheme.textSecondary : AppTheme.textDark,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    required Color activePrimary,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDarkMode
            ? AppTheme.textSecondary.withOpacity(0.45)
            : AppTheme.textLight,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: activePrimary, size: 20),
      filled: true,
      fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
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
    );
  }
}
