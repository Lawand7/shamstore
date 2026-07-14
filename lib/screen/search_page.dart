import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/products/controllers/product_controller.dart';
import 'package:shamstore/features/products/models/product_model.dart';
import 'package:shamstore/screen/category_products.dart';
import 'package:shamstore/screen/product_details_Page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final ProductController _productController;

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  String _searchQuery = '';
  double? _minPrice;
  double? _maxPrice;
  String _selectedGovernorate = 'الكل';
  int? _selectedFilterCategoryId;
  bool _isFilterMode = false;

  final List<String> _governorates = [
    'الكل',
    'Damascus',
    'Aleppo',
    'Homs',
    'Hama',
    'Lattakia',
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

  final List<Map<String, dynamic>> _allCategories = const [
    {
      'id': 1,
      'name': 'إلكترونيات',
      'translationKey': 'Electronics',
      'icon': Icons.devices_rounded,
      'color': Color(0xFF7C3AED),
    },
    {
      'id': 2,
      'name': 'ملابس',
      'translationKey': 'Clothes',
      'icon': Icons.checkroom_rounded,
      'color': Color(0xFF0F4C8A),
    },
    {
      'id': 3,
      'name': 'أحذية',
      'translationKey': 'Shoes',
      'icon': Icons.ice_skating_rounded,
      'color': Color(0xFFE11D48),
    },
    {
      'id': 4,
      'name': 'كتب',
      'translationKey': 'Books',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF059669),
    },
    {
      'id': 5,
      'name': 'رياضة',
      'translationKey': 'Sports',
      'icon': Icons.sports_basketball_rounded,
      'color': Color(0xFFD97706),
    },
    {
      'id': 6,
      'name': 'أثاث',
      'translationKey': 'Furniture',
      'icon': Icons.chair_rounded,
      'color': Color(0xFF4B5563),
    },
    {
      'id': 7,
      'name': 'مستلزمات مدرسية',
      'translationKey': 'School Supplies',
      'icon': Icons.school_rounded,
      'color': Color(0xFF2563EB),
    },
    {
      'id': 8,
      'name': 'مستحضرات\nتجميل',
      'translationKey': 'Cosmetics',
      'icon': Icons.face_retouching_natural_rounded,
      'color': Color(0xFFDB2777),
    },
    {
      'id': 9,
      'name': 'أدوات منزلية',
      'translationKey': 'Housewares',
      'icon': Icons.blender_rounded,
      'color': Color(0xFF0D9488),
    },
    {
      'id': 10,
      'name': 'ألعاب',
      'translationKey': 'Games',
      'icon': Icons.videogame_asset_rounded,
      'color': Color(0xFFEA580C),
    },
  ];

  @override
  void initState() {
    super.initState();

    _productController = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      if (value.trim().isNotEmpty) {
        _isFilterMode = false;
      }
    });

    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      final cleanedQuery = value.trim();

      if (cleanedQuery.isEmpty) {
        _productController.clearSearchProducts();
        return;
      }

      _productController.clearFilteredProducts();
      _productController.searchProductsByProductUrl(query: cleanedQuery);
    });
  }

  void _showFilterBottomSheet(bool isDarkMode) {
    final minController = TextEditingController(
      text: _minPrice?.toString() ?? '',
    );
    final maxController = TextEditingController(
      text: _maxPrice?.toString() ?? '',
    );

    int? tempCategoryId = _selectedFilterCategoryId;
    String tempGovernorate = _selectedGovernorate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppTheme.cardBackground : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppTheme.inputFieldBg
                              : AppTheme.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).translate('Filter Title'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppTheme.textPrimary
                            : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'التصنيف',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      value: tempCategoryId,
                      dropdownColor: isDarkMode
                          ? AppTheme.cardBackground
                          : Colors.white,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppTheme.textPrimary
                            : AppTheme.textDark,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDarkMode
                            ? AppTheme.inputFieldBg
                            : AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            AppLocalizations.of(context).translate('All Tab'),
                          ),
                        ),
                        ..._allCategories.map((category) {
                          final categoryId = int.tryParse(
                            category['id'].toString(),
                          );

                          return DropdownMenuItem<int?>(
                            value: categoryId,
                            child: Text(
                              _categoryDisplayName(
                                context,
                                category,
                              ).replaceAll('\n', ' '),
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          tempCategoryId = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).translate('Price Range Label'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _dialogField(
                            minController,
                            AppLocalizations.of(
                              context,
                            ).translate('Min Price Hint'),
                            isDarkMode,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dialogField(
                            maxController,
                            AppLocalizations.of(
                              context,
                            ).translate('Max Price Hint'),
                            isDarkMode,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context).translate('Governorate'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: tempGovernorate,
                      dropdownColor: isDarkMode
                          ? AppTheme.cardBackground
                          : Colors.white,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppTheme.textPrimary
                            : AppTheme.textDark,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDarkMode
                            ? AppTheme.inputFieldBg
                            : AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _governorates.map((governorate) {
                        return DropdownMenuItem(
                          value: governorate,
                          child: Text(
                            governorate == 'الكل'
                                ? AppLocalizations.of(
                                    context,
                                  ).translate('All Tab')
                                : AppLocalizations.of(
                                    context,
                                  ).translate(governorate),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setModalState(() {
                          tempGovernorate = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _minPrice = null;
                                _maxPrice = null;
                                _selectedGovernorate = 'الكل';
                                _selectedFilterCategoryId = null;
                                _isFilterMode = false;
                              });

                              _productController.clearFilteredProducts();

                              Navigator.pop(context);
                            },
                            child: Text(
                              AppLocalizations.of(
                                context,
                              ).translate('Reset Filter'),
                              style: const TextStyle(color: AppTheme.error),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final minPrice = double.tryParse(
                                minController.text.trim(),
                              );
                              final maxPrice = double.tryParse(
                                maxController.text.trim(),
                              );

                              final hasMin = minController.text
                                  .trim()
                                  .isNotEmpty;
                              final hasMax = maxController.text
                                  .trim()
                                  .isNotEmpty;

                              if (hasMin != hasMax) {
                                Get.snackbar(
                                  'تنبيه',
                                  'يرجى إدخال الحد الأدنى والأعلى للسعر معاً',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }

                              if (minPrice != null &&
                                  maxPrice != null &&
                                  minPrice > maxPrice) {
                                Get.snackbar(
                                  'تنبيه',
                                  'الحد الأدنى للسعر يجب أن يكون أقل من الحد الأعلى',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }

                              final hasFilter =
                                  tempCategoryId != null ||
                                  (minPrice != null && maxPrice != null) ||
                                  tempGovernorate != 'الكل';

                              setState(() {
                                _minPrice = minPrice;
                                _maxPrice = maxPrice;
                                _selectedGovernorate = tempGovernorate;
                                _selectedFilterCategoryId = tempCategoryId;
                                _isFilterMode = hasFilter;
                                _searchQuery = '';
                              });

                              _searchController.clear();
                              _productController.clearSearchProducts();

                              Navigator.pop(context);

                              if (!hasFilter) {
                                _productController.clearFilteredProducts();
                                return;
                              }

                              _productController.filterProducts(
                                categoryId: tempCategoryId,
                                minPrice: minPrice,
                                maxPrice: maxPrice,
                                governorate: tempGovernorate,
                                refresh: true,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? AppTheme.selectedBorder
                                  : AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              ).translate('Apply Filter'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String hint,
    bool isDarkMode,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDarkMode
              ? AppTheme.textSecondary.withOpacity(0.5)
              : AppTheme.textLight,
          fontSize: 12,
        ),
        filled: true,
        fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Map<String, dynamic> _productToMap(ProductModel product) {
    return {
      'id': product.id,
      'seller_id': product.sellerId,
      'category_id': product.categoryId,
      'name': product.title,
      'title': product.title,
      'description': product.description,
      'city': product.governorate,
      'governorate': product.governorate,
      'price': _formatPrice(product.price),
      'quantity': product.quantity,
      'product_image_url': product.productImageUrl,
      'imageUrl': product.fullImageUrl,
      'product_url': product.productUrl,
      'is_active': product.isActive,
      'created_at': product.createdAt,
      'updated_at': product.updatedAt,
      'icon': Icons.image_outlined,
      'fav': false,
      'rating': 0.0,
      'sold': 0,
      'sellerRating': 0.0,
      'sellerName': 'Seller #${product.sellerId}',
    };
  }

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  String _categoryDisplayName(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final translationKey = category['translationKey']?.toString() ?? '';
    final fallbackName = category['name']?.toString() ?? '';

    final translated = AppLocalizations.of(context).translate(translationKey);

    return translated.trim().isNotEmpty ? translated : fallbackName;
  }

  Widget _buildSearchResults(bool isDarkMode) {
    return Obx(() {
      if (_productController.isSearchLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_productController.searchErrorMessage.value.isNotEmpty) {
        return _buildMessageState(
          isDarkMode: isDarkMode,
          message: _productController.searchErrorMessage.value,
          icon: Icons.error_outline_rounded,
        );
      }

      if (_productController.searchProducts.isEmpty) {
        return _buildMessageState(
          isDarkMode: isDarkMode,
          message: 'لا توجد نتائج لهذا الرابط',
          icon: Icons.search_off_rounded,
        );
      }

      return _buildProductsGrid(
        products: _productController.searchProducts,
        isDarkMode: isDarkMode,
      );
    });
  }

  Widget _buildFilteredResults(bool isDarkMode) {
    return Obx(() {
      if (_productController.isFilterLoading.value &&
          _productController.filteredProducts.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_productController.filterErrorMessage.value.isNotEmpty &&
          _productController.filteredProducts.isEmpty) {
        return _buildMessageState(
          isDarkMode: isDarkMode,
          message: _productController.filterErrorMessage.value,
          icon: Icons.error_outline_rounded,
        );
      }

      if (_productController.filteredProducts.isEmpty) {
        return _buildMessageState(
          isDarkMode: isDarkMode,
          message: 'لا توجد منتجات مطابقة للفلترة',
          icon: Icons.filter_alt_off_rounded,
        );
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _minPrice = null;
                      _maxPrice = null;
                      _selectedGovernorate = 'الكل';
                      _selectedFilterCategoryId = null;
                      _isFilterMode = false;
                    });

                    _productController.clearFilteredProducts();
                  },
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('إلغاء الفلترة'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    padding: EdgeInsets.zero,
                  ),
                ),
                Text(
                  'النتائج: ${_productController.filterTotal.value}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppTheme.textPrimary
                        : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildProductsGrid(
              products: _productController.filteredProducts,
              isDarkMode: isDarkMode,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMessageState({
    required bool isDarkMode,
    required String message,
    required IconData icon,
  }) {
    final Color activePrimary = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: activePrimary, size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid({
    required List<ProductModel> products,
    required bool isDarkMode,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return _buildProductCard(product, isDarkMode);
      },
    );
  }

  Widget _buildProductCard(ProductModel product, bool isDarkMode) {
    final Color activePrimary = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: _productToMap(product)),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? AppTheme.inputFieldBg : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 95,
                width: double.infinity,
                color: isDarkMode
                    ? AppTheme.darkBackground
                    : AppTheme.background.withOpacity(0.5),
                child: product.fullImageUrl.isEmpty
                    ? Icon(Icons.image_outlined, size: 42, color: activePrimary)
                    : Image.network(
                        product.fullImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 95,
                        errorBuilder: (_, __, ___) {
                          return Icon(
                            Icons.broken_image_outlined,
                            size: 42,
                            color: activePrimary,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;

                          return Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: activePrimary,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title.isNotEmpty
                          ? product.title
                          : 'منتج بدون اسم',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? AppTheme.textPrimary
                            : AppTheme.textDark,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            product.governorate.isNotEmpty
                                ? product.governorate
                                : 'غير متوفر',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode
                                  ? AppTheme.textSecondary
                                  : AppTheme.textLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(Icons.location_on, size: 11, color: activePrimary),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context).translate('currency'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _formatPrice(product.price),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: activePrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isDarkMode, bool isArabic) {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: _allCategories.length,
      itemBuilder: (context, index) {
        final category = _allCategories[index];

        final displayCategoryName = _categoryDisplayName(context, category);

        final Color categoryColor = category['color'] as Color;
        final Color finalIconColor = isDarkMode
            ? Color.lerp(categoryColor, Colors.white, 0.3)!
            : categoryColor;

        return GestureDetector(
          onTap: () {
            final cleanedName = displayCategoryName.replaceAll('\n', ' ');
            final categoryId = int.tryParse(category['id'].toString()) ?? 0;

            if (categoryId <= 0) {
              Get.snackbar(
                'تنبيه',
                'رقم التصنيف غير صحيح',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryProductsPage(
                  categoryId: categoryId,
                  categoryName: cleanedName,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.cardBackground : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDarkMode ? Colors.transparent : AppTheme.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: isArabic
                  ? [
                      Expanded(
                        child: Text(
                          displayCategoryName,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: isDarkMode
                                ? AppTheme.textPrimary
                                : AppTheme.textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: finalIconColor.withOpacity(
                            isDarkMode ? 0.18 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: finalIconColor,
                          size: 22,
                        ),
                      ),
                    ]
                  : [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: finalIconColor.withOpacity(
                            isDarkMode ? 0.18 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: finalIconColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          displayCategoryName,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: isDarkMode
                                ? AppTheme.textPrimary
                                : AppTheme.textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final Color activePrimary = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    final bool hasSearchQuery = _searchQuery.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).translate('Browse Categories'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      color: isDarkMode
                          ? AppTheme.textPrimary
                          : AppTheme.textDark,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ابحث برابط المنتج',
                      hintStyle: TextStyle(
                        color: isDarkMode
                            ? AppTheme.textSecondary.withOpacity(0.5)
                            : AppTheme.textLight,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.search, color: activePrimary),
                      suffixIcon: hasSearchQuery
                          ? IconButton(
                              icon: Icon(
                                Icons.close,
                                color: isDarkMode
                                    ? AppTheme.textSecondary
                                    : AppTheme.textGrey,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDarkMode
                          ? AppTheme.inputFieldBg
                          : AppTheme.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? AppTheme.selectedBorder
                              : AppTheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showFilterBottomSheet(isDarkMode),
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: _isFilterMode
                          ? AppTheme.success
                          : isDarkMode
                          ? AppTheme.selectedBorder
                          : AppTheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: hasSearchQuery
                ? _buildSearchResults(isDarkMode)
                : _isFilterMode
                ? _buildFilteredResults(isDarkMode)
                : _buildCategoriesGrid(isDarkMode, isArabic),
          ),
        ],
      ),
    );
  }
}
