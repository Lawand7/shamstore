import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/my_products_page.dart';
import 'package:shamstore/utils/app_localizations.dart'; // استدعاء ملف الترجمة الخاص بك

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCategory;
  String? _selectedGovernorate;
  bool _imageSelected = false;

  // الإبقاء على القيم بالإنجليزية كمفاتيح ثابتة للكود وقواعد البيانات
  final List<String> _categories = ['Clothing', 'Shoes', 'Electronics', 'Books', 'Furniture', 'Sports', 'Supplies', 'Household', 'Toys'];
  final List<String> _governorates = ['Damascus', 'Aleppo', 'Homs', 'Hama', 'Latakia', 'Tartus', 'Deir ez-Zor', 'Al-Hasakah', 'Raqqa', 'Daraa', 'Sweida', 'Quneitra', 'Idlib'];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 فحص حالة الدارك مود الحالية بالتطبيق ديناميكياً
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('Add Product'),
          style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildImagePicker(isDarkMode),
                const SizedBox(height: 14),
                _buildFormCard(isDarkMode),
                const SizedBox(height: 14),
                _buildAddButton(isDarkMode),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isDarkMode) {
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return GestureDetector(
      onTap: () => setState(() => _imageSelected = true),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: _imageSelected
              ? activeColor.withOpacity(0.08)
              : (isDarkMode ? AppTheme.cardBackground : AppTheme.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _imageSelected ? activeColor : (isDarkMode ? Colors.transparent : AppTheme.border),
            width: _imageSelected ? 1.5 : 0.5,
          ),
        ),
        child: _imageSelected
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: activeColor, size: 36),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).translate('Image Selected'), style: TextStyle(color: activeColor, fontSize: 13, fontWeight: FontWeight.w500)),
            Text(AppLocalizations.of(context).translate('Tap to change'), style: TextStyle(color: activeColor.withOpacity(0.6), fontSize: 11)),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: activeColor.withOpacity(0.6), size: 36),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).translate('Upload product image'), style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey, fontSize: 13)),
            Text(AppLocalizations.of(context).translate('Tap to select'), style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildField(AppLocalizations.of(context).translate('Product Name'), AppLocalizations.of(context).translate('Enter product name'), Icons.inventory_2_outlined, _nameController, isDarkMode),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildField(AppLocalizations.of(context).translate('Price (SP)'), '0', Icons.attach_money, _priceController, isDarkMode, keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: _buildField(AppLocalizations.of(context).translate('Quantity'), '1', Icons.layers_outlined, _qtyController, isDarkMode, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 12),
          _buildDropdown(AppLocalizations.of(context).translate('Category'), Icons.category_outlined, _categories, _selectedCategory, (val) => setState(() => _selectedCategory = val), isDarkMode),
          const SizedBox(height: 12),
          _buildDropdown(AppLocalizations.of(context).translate('Governorate'), Icons.location_on_outlined, _governorates, _selectedGovernorate, (val) => setState(() => _selectedGovernorate = val), isDarkMode),
          const SizedBox(height: 12),
          _buildDescField(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, IconData icon, TextEditingController controller, bool isDarkMode, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: TextAlign.right,
          style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, fontSize: 12),
            prefixIcon: Icon(icon, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, size: 18),
            filled: true,
            fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, IconData icon, List<String> items, String? value, Function(String?) onChanged, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          hint: Text('${AppLocalizations.of(context).translate('Select')} $label', style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight)),
          style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 12),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, size: 18),
            filled: true,
            fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, width: 1.5)),
          ),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(
              AppLocalizations.of(context).translate(item),
              style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
            ),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDescField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(AppLocalizations.of(context).translate('Description'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark)),
        const SizedBox(height: 6),
        TextField(
          controller: _descController,
          maxLines: 3,
          textAlign: TextAlign.right,
          style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 13),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).translate('Write a description for the product...'),
            hintStyle: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, fontSize: 12),
            filled: true,
            fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          AppLocalizations.of(context).translate('Add Product Button'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}