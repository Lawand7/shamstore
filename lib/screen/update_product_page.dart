import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shamstore/features/seller/controllers/seller_product_controller.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';

class UpdateProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const UpdateProductPage({super.key, required this.product});

  @override
  State<UpdateProductPage> createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  late final SellerProductController _sellerProductController;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImageFile;
  int? _selectedCategoryId;
  String? _selectedGovernorate;

  final List<Map<String, dynamic>> _categories = const [
    {'id': 1, 'name': 'Electronics'},
    {'id': 2, 'name': 'Clothing'},
    {'id': 3, 'name': 'School Supplies'},
    {'id': 4, 'name': 'Shoes'},
    {'id': 5, 'name': 'Books'},
    {'id': 6, 'name': 'Furniture'},
    {'id': 7, 'name': 'Housewares'},
    {'id': 8, 'name': 'Cosmetics'},
    {'id': 9, 'name': 'Sports'},
    {'id': 10, 'name': 'Games'},
  ];

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

  int get _productId {
    final value = widget.product['id'];
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();

    _sellerProductController = Get.isRegistered<SellerProductController>()
        ? Get.find<SellerProductController>()
        : Get.put(SellerProductController());

    _sellerProductController.clearUpdateProductState();

    _fillInitialData();
  }

  void _fillInitialData() {
    _nameController.text = _readText(['title', 'name']);
    _priceController.text = _readText(['price']);
    _qtyController.text = _readText(['quantity', 'qty']);
    _descController.text = _readText(['description']);

    final categoryValue =
        widget.product['category_id'] ??
        widget.product['categoryId'] ??
        widget.product['category'];

    final parsedCategory = int.tryParse(categoryValue?.toString() ?? '');

    if (parsedCategory != null &&
        _categories.any((category) => category['id'] == parsedCategory)) {
      _selectedCategoryId = parsedCategory;
    }

    final governorateValue = widget.product['governorate']?.toString();

    if (governorateValue != null && _governorates.contains(governorateValue)) {
      _selectedGovernorate = governorateValue;
    }
  }

  String _readText(List<String> keys) {
    for (final key in keys) {
      final value = widget.product[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedImage == null) return;

      setState(() {
        _selectedImageFile = File(pickedImage.path);
      });
    } catch (_) {
      if (!mounted) return;
      AppFeedback.error(context, 'تعذر اختيار الصورة');
    }
  }

  Future<void> _submitUpdate() async {
    if (_productId <= 0) {
      AppFeedback.error(context, 'معرّف المنتج غير صالح');
      return;
    }

    final title = _nameController.text.trim();
    final description = _descController.text.trim();
    final priceText = _priceController.text.trim();
    final quantityText = _qtyController.text.trim();

    if (title.isEmpty) {
      AppFeedback.error(context, 'يرجى إدخال اسم المنتج');
      return;
    }

    double? price;
    int? quantity;

    if (priceText.isNotEmpty) {
      price = double.tryParse(priceText);

      if (price == null || price < 0) {
        AppFeedback.error(context, 'السعر غير صالح');
        return;
      }
    }

    if (quantityText.isNotEmpty) {
      quantity = int.tryParse(quantityText);

      if (quantity == null || quantity < 0) {
        AppFeedback.error(context, 'الكمية غير صالحة');
        return;
      }
    }

    final success = await _sellerProductController.updateProduct(
      productId: _productId,
      title: title,
      description: description.isEmpty ? null : description,
      price: price,
      quantity: quantity,
      governorate: _selectedGovernorate,
      categoryId: _selectedCategoryId,
      productImageFile: _selectedImageFile,
    );

    if (!mounted) return;

    if (!success) {
      AppFeedback.error(
        context,
        _sellerProductController.updateProductErrorMessage.value.isNotEmpty
            ? _sellerProductController.updateProductErrorMessage.value
            : 'حدث خطأ أثناء تعديل المنتج',
      );
      return;
    }

    AppFeedback.success(context, 'تم تعديل المنتج بنجاح');

    Navigator.pop(context, {
      'updated': true,
      'title': title,
      'name': title,
      'price': priceText,
      'quantity': quantityText,
      'description': description,
      'category_id': _selectedCategoryId,
      'governorate': _selectedGovernorate,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('Update Product'),
          style: const TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
          ),
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
                _buildUpdateButton(isDarkMode),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isDarkMode) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: _selectedImageFile != null
              ? activeColor.withOpacity(0.08)
              : (isDarkMode ? AppTheme.cardBackground : AppTheme.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedImageFile != null
                ? activeColor
                : (isDarkMode ? Colors.transparent : AppTheme.border),
            width: _selectedImageFile != null ? 1.5 : 0.5,
          ),
        ),
        child: _selectedImageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(_selectedImageFile!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: activeColor.withOpacity(0.6),
                    size: 38,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).translate('Upload product image'),
                    style: TextStyle(
                      color: isDarkMode
                          ? AppTheme.textSecondary
                          : AppTheme.textGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'اختياري: اختر صورة جديدة فقط إذا أردت تغييرها',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 11),
                  ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildField(
            label: AppLocalizations.of(context).translate('Product Name'),
            hint: AppLocalizations.of(context).translate('Enter product name'),
            icon: Icons.inventory_2_outlined,
            controller: _nameController,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: AppLocalizations.of(context).translate('Price (SP)'),
                  hint: '0',
                  icon: Icons.attach_money,
                  controller: _priceController,
                  isDarkMode: isDarkMode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildField(
                  label: AppLocalizations.of(context).translate('Quantity'),
                  hint: '1',
                  icon: Icons.layers_outlined,
                  controller: _qtyController,
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCategoryDropdown(isDarkMode),
          const SizedBox(height: 12),
          _buildGovernorateDropdown(isDarkMode),
          const SizedBox(height: 12),
          _buildDescField(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool isDarkMode,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            fontSize: 13,
          ),
          decoration: _inputDecoration(
            hint: hint,
            icon: icon,
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          AppLocalizations.of(context).translate('Category'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          value: _selectedCategoryId,
          dropdownColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          hint: Text(
            '${AppLocalizations.of(context).translate('Select')} ${AppLocalizations.of(context).translate('Category')}',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
            ),
          ),
          style: TextStyle(
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            fontSize: 12,
          ),
          decoration: _inputDecoration(
            hint: '',
            icon: Icons.category_outlined,
            isDarkMode: isDarkMode,
          ),
          items: _categories.map((category) {
            final int id = int.tryParse(category['id'].toString()) ?? 0;
            final String name = category['name'].toString();

            return DropdownMenuItem<int>(
              value: id,
              child: Text(
                AppLocalizations.of(context).translate(name),
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildGovernorateDropdown(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          AppLocalizations.of(context).translate('Governorate'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedGovernorate,
          dropdownColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          hint: Text(
            '${AppLocalizations.of(context).translate('Select')} ${AppLocalizations.of(context).translate('Governorate')}',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
            ),
          ),
          style: TextStyle(
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            fontSize: 12,
          ),
          decoration: _inputDecoration(
            hint: '',
            icon: Icons.location_on_outlined,
            isDarkMode: isDarkMode,
          ),
          items: _governorates.map((governorate) {
            return DropdownMenuItem<String>(
              value: governorate,
              child: Text(
                AppLocalizations.of(context).translate(governorate),
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGovernorate = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDescField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          AppLocalizations.of(context).translate('Description'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _descController,
          maxLines: 3,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(
              context,
            ).translate('Write a description for the product...'),
            hintStyle: TextStyle(
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
              fontSize: 12,
            ),
            filled: true,
            fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: isDarkMode
                  ? BorderSide.none
                  : const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: isDarkMode
                  ? BorderSide.none
                  : const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
        fontSize: 12,
      ),
      prefixIcon: Icon(
        icon,
        color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
        size: 18,
      ),
      filled: true,
      fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: isDarkMode
            ? BorderSide.none
            : const BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: isDarkMode
            ? BorderSide.none
            : const BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildUpdateButton(bool isDarkMode) {
    return Obx(() {
      final bool isLoading = _sellerProductController.isUpdatingProduct.value;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : _submitUpdate,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode
                ? AppTheme.selectedBorder
                : AppTheme.primary,
            foregroundColor: AppTheme.white,
            disabledBackgroundColor: isDarkMode
                ? AppTheme.inputFieldBg
                : AppTheme.textLight,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
                  AppLocalizations.of(context).translate('Update Product'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      );
    });
  }
}
