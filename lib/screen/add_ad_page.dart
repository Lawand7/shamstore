import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/screen/home_page.dart';

class AddAdPage extends StatefulWidget {
  const AddAdPage({super.key});

  @override
  State<AddAdPage> createState() => _AddAdPageState();
}

class _AddAdPageState extends State<AddAdPage> {
  final _formKey = GlobalKey<FormState>();

  final _adTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedGovernorate;
  bool _isPaid = false;
  final List<String> _governorates = [
    'دمشق', 'ريف دمشق', 'حلب', 'حمص', 'حماة', 'اللاذقية',
    'طرطوس', 'إدلب', 'دير الزور', 'الرقة', 'الحسكة', 'درعا', 'السويداء', 'القنيطرة'
  ];

  @override
  void dispose() {
    _adTitleController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitAd() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('Ad published successfully'),
            textAlign: _isArabic() ? TextAlign.right : TextAlign.left,
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = _isArabic();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('Add Ad Title'),
          style: const TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_back_ios_rounded : Icons.arrow_back_ios_new_rounded,
            color: AppTheme.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildLabel(AppLocalizations.of(context).translate('Ad Title Label'), isDarkMode),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _adTitleController,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                  decoration: _inputDecoration(AppLocalizations.of(context).translate('Ad Title Hint'), isDarkMode),
                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context).translate('Required Field') : null,
                ),
                const SizedBox(height: 20),

                _buildLabel(AppLocalizations.of(context).translate('Governorate Label'), isDarkMode),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedGovernorate,
                  alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                  dropdownColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                  hint: Text(
                    AppLocalizations.of(context).translate('Select Governorate Hint'),
                    style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, fontSize: 13),
                  ),
                  decoration: _inputDecoration('', isDarkMode),
                  icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary),
                  items: _governorates.map((gov) {
                    return DropdownMenuItem<String>(
                      value: gov,
                      child: Text(
                        AppLocalizations.of(context).translate(gov),
                        style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedGovernorate = value),
                  validator: (val) => val == null ? AppLocalizations.of(context).translate('Required Field') : null,
                ),
                const SizedBox(height: 20),

                _buildLabel(AppLocalizations.of(context).translate('Phone Number Label'), isDarkMode),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                  decoration: _inputDecoration('09xxxxxxxx', isDarkMode).copyWith(
                    prefixIcon: Icon(Icons.phone_android_rounded, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, size: 18),
                  ),
                  validator: (val) {
                    if (val!.isEmpty) return AppLocalizations.of(context).translate('Required Field');
                    if (val.length < 10) return AppLocalizations.of(context).translate('Invalid Phone');
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel(AppLocalizations.of(context).translate('Ad Description Label'), isDarkMode),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                  decoration: _inputDecoration(AppLocalizations.of(context).translate('Ad Description Hint'), isDarkMode),
                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context).translate('Required Field') : null,
                ),
                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: _isPaid
                          ? Colors.green.withOpacity(0.08)
                          : (isDarkMode ? AppTheme.accentBlue.withOpacity(0.08) : AppTheme.primary.withOpacity(0.08)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isPaid
                            ? Colors.green.withOpacity(0.3)
                            : (isDarkMode ? AppTheme.accentBlue.withOpacity(0.3) : AppTheme.primary.withOpacity(0.2)),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: isArabic
                          ? [
                        _buildPayButton(isDarkMode),
                        Row(
                          children: [
                            Text(
                              '${AppLocalizations.of(context).translate("Ad Fee Required")} 100 ليرة سورية',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _isPaid ? Icons.check_circle_rounded : Icons.payments_outlined,
                              color: _isPaid ? Colors.green : (isDarkMode ? AppTheme.accentBlue : AppTheme.primary),
                              size: 20,
                            ),
                          ],
                        ),
                      ]
                          : [
                        Row(
                          children: [
                            Icon(
                              _isPaid ? Icons.check_circle_rounded : Icons.payments_outlined,
                              color: _isPaid ? Colors.green : (isDarkMode ? AppTheme.accentBlue : AppTheme.primary),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${AppLocalizations.of(context).translate("Ad Fee Required")} 100 SYP',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                            ),
                          ],
                        ),
                        _buildPayButton(isDarkMode),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isPaid ? _submitAd : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? AppTheme.selectedBorder : Colors.blue,
                      disabledBackgroundColor: (isDarkMode ? AppTheme.selectedBorder : Colors.blue).withOpacity(0.3),
                      disabledForegroundColor: Colors.white.withOpacity(0.6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: _isPaid ? 2 : 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context).translate('Publish Ad Button'),
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPayButton(bool isDarkMode) {
    return InkWell(
      onTap: _isPaid
          ? null
          : () {
        setState(() {
          _isPaid = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت عملية الدفع بنجاح! يمكنك الآن نشر الإعلان.', textAlign: TextAlign.center),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isPaid ? Colors.green : (isDarkMode ? AppTheme.selectedBorder : AppTheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _isPaid ? 'تم الدفع ✓' : 'دفع',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDarkMode) {
    return Text(
      text,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDarkMode) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, fontSize: 13),
      filled: true,
      fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
    );
  }

  bool _isArabic() => Localizations.localeOf(context).languageCode == 'ar';
}