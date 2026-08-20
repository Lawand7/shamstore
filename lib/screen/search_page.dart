import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/customer/controllers/customer_controller.dart';
import 'package:shamstore/features/products/controllers/product_controller.dart';
import 'package:shamstore/features/products/models/product_model.dart';
import 'package:shamstore/screen/category_products.dart';
import 'package:shamstore/screen/product_details_Page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/utils/localized_content.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final ProductController _productController;
  late final CustomerController _customerController;

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  String _searchQuery = '';
  double? _minPrice;
  double? _maxPrice;
  String _selectedGovernorate = 'all';
  int? _selectedFilterCategoryId;
  bool _isFilterMode = false;

  final List<String> _governorates = [
    'all',
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
      'name': 'مستلزمات مدرسية',
      'translationKey': 'School Supplies',
      'icon': Icons.school_rounded,
      'color': Color(0xFF2563EB),
    },
    {
      'id': 4,
      'name': 'أحذية',
      'translationKey': 'Shoes',
      'icon': Icons.ice_skating_rounded,
      'color': Color(0xFFE11D48),
    },
    {
      'id': 5,
      'name': 'كتب',
      'translationKey': 'Books',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF059669),
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
      'name': 'أدوات منزلية',
      'translationKey': 'Housewares',
      'icon': Icons.blender_rounded,
      'color': Color(0xFF0D9488),
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
      'name': 'رياضة',
      'translationKey': 'Sports',
      'icon': Icons.sports_basketball_rounded,
      'color': Color(0xFFD97706),
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

    _customerController = Get.isRegistered<CustomerController>()
        ? Get.find<CustomerController>()
        : Get.put(CustomerController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshCustomerData();
    });
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
                      initialValue: tempCategoryId,
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
                      initialValue: tempGovernorate,
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
                            LocalizedContent.value(context, governorate),
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
                                _selectedGovernorate = 'all';
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
                                AppFeedback.error(
                                  context,
                                  'يرجى إدخال الحد الأدنى والأعلى للسعر معاً',
                                );
                                return;
                              }

                              if (minPrice != null &&
                                  maxPrice != null &&
                                  minPrice > maxPrice) {
                                AppFeedback.error(
                                  context,
                                  'الحد الأدنى للسعر يجب أن يكون أقل من الحد الأعلى',
                                );
                                return;
                              }

                              final hasFilter =
                                  tempCategoryId != null ||
                                  (minPrice != null && maxPrice != null) ||
                                  tempGovernorate != 'all';

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
                                governorate: tempGovernorate == 'all'
                                    ? null
                                    : tempGovernorate,
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
              ? AppTheme.textSecondary.withValues(alpha: 0.5)
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

  List<ProductModel> _visibleProducts(Iterable<ProductModel> products) {
    return products
        .where(
          (ProductModel product) => product.isActive && product.quantity > 0,
        )
        .toList();
  }

  bool _isProductAvailable(ProductModel product) {
    return product.isActive && product.quantity > 0;
  }

  Future<void> _refreshCustomerData() async {
    await Future.wait<bool>([
      _customerController.fetchFavoriteProducts(refresh: true),
      _customerController.fetchCart(),
    ]);
  }

  Future<void> _refreshCurrentResults() async {
    final String cleanedQuery = _searchQuery.trim();

    if (cleanedQuery.isNotEmpty) {
      await _productController.searchProductsByProductUrl(query: cleanedQuery);
    } else if (_isFilterMode) {
      await _productController.filterProducts(
        categoryId: _selectedFilterCategoryId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        governorate: _selectedGovernorate == 'all'
            ? null
            : _selectedGovernorate,
        refresh: true,
      );
    }

    await _refreshCustomerData();
  }

  Future<void> _openProductDetails(ProductModel product) async {
    if (!_isProductAvailable(product)) {
      _showSnackBar(
        title: 'المنتج غير متاح',
        message: product.quantity <= 0
            ? 'نفدت كمية هذا المنتج'
            : 'أوقف البائع عرض هذا المنتج',
        isError: true,
      );

      await _refreshCurrentResults();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsPage(product: _productToMap(product)),
      ),
    );

    if (!mounted) return;

    await _refreshCurrentResults();
  }

  Future<void> _toggleFavorite(ProductModel product) async {
    if (!_isProductAvailable(product)) {
      _showSnackBar(
        title: 'المنتج غير متاح',
        message: 'لا يمكن تعديل المفضلة لمنتج غير متوفر',
        isError: true,
      );
      await _refreshCurrentResults();
      return;
    }

    final bool wasFavorite = _customerController.isFavorite(product.id);

    final bool success = await _customerController.toggleFavorite(
      product: product,
    );

    if (!mounted) return;

    if (!success) {
      _showSnackBar(
        title: 'فشل العملية',
        message: _customerController.favoriteActionErrorMessage.value.isNotEmpty
            ? _customerController.favoriteActionErrorMessage.value
            : 'تعذر تعديل المفضلة',
        isError: true,
      );
      return;
    }

    _showSnackBar(
      title: 'نجاح',
      message: wasFavorite
          ? 'تم حذف المنتج من المفضلة'
          : 'تمت إضافة المنتج إلى المفضلة',
      isError: false,
    );
  }

  Future<void> _addProductToCart(ProductModel product) async {
    if (!_isProductAvailable(product)) {
      _showSnackBar(
        title: 'المنتج غير متاح',
        message: product.quantity <= 0
            ? 'نفدت كمية هذا المنتج'
            : 'أوقف البائع عرض هذا المنتج',
        isError: true,
      );
      await _refreshCurrentResults();
      return;
    }

    final existingItem = _customerController.findCartItemByProductId(
      product.id,
    );

    if (existingItem != null && existingItem.quantity >= product.quantity) {
      _showSnackBar(
        title: 'الكمية غير متاحة',
        message: 'لديك في السلة كامل الكمية المتوفرة: ${product.quantity}',
        isError: true,
      );
      return;
    }

    final bool success = await _customerController.addCartItem(
      productId: product.id,
      quantity: 1,
    );

    if (!mounted) return;

    if (!success) {
      _showSnackBar(
        title: 'فشل الإضافة',
        message: _customerController.addCartItemErrorMessage.value.isNotEmpty
            ? _customerController.addCartItemErrorMessage.value
            : 'تعذر إضافة المنتج إلى السلة',
        isError: true,
      );
      return;
    }

    _showSnackBar(
      title: 'تمت الإضافة',
      message: 'تمت إضافة المنتج إلى السلة',
      isError: false,
    );
  }

  void _showSnackBar({
    required String title,
    required String message,
    required bool isError,
  }) {
    if (isError) {
      AppFeedback.error(context, message);
    } else {
      AppFeedback.success(context, message);
    }
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
      'fav': _customerController.isFavorite(product.id),
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
      final List<ProductModel> visibleProducts = _visibleProducts(
        _productController.searchProducts,
      );

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

      if (visibleProducts.isEmpty) {
        final bool hiddenByAvailability =
            _productController.searchProducts.isNotEmpty;

        return RefreshIndicator(
          onRefresh: _refreshCurrentResults,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.55,
                child: _buildMessageState(
                  isDarkMode: isDarkMode,
                  message: hiddenByAvailability
                      ? 'تم العثور على المنتج، لكنه نافد أو غير متاح للبيع'
                      : 'لا توجد نتائج لهذا الرابط',
                  icon: hiddenByAvailability
                      ? Icons.inventory_2_outlined
                      : Icons.search_off_rounded,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'النتائج المتاحة: ${visibleProducts.length}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshCurrentResults,
              child: _buildProductsGrid(
                products: visibleProducts,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFilteredResults(bool isDarkMode) {
    return Obx(() {
      final List<ProductModel> visibleProducts = _visibleProducts(
        _productController.filteredProducts,
      );

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
                      _selectedGovernorate = 'all';
                      _selectedFilterCategoryId = null;
                      _isFilterMode = false;
                    });

                    _productController.clearFilteredProducts();
                  },
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: Text(
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? 'إلغاء الفلترة'
                        : 'Clear filters',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    padding: EdgeInsets.zero,
                  ),
                ),
                Text(
                  'النتائج المتاحة: ${visibleProducts.length}',
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
            child: visibleProducts.isEmpty
                ? RefreshIndicator(
                    onRefresh: _refreshCurrentResults,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: _buildMessageState(
                            isDarkMode: isDarkMode,
                            message:
                                _productController.filteredProducts.isNotEmpty
                                ? 'المنتجات المطابقة نافدة أو غير متاحة للبيع'
                                : 'لا توجد منتجات مطابقة للفلترة',
                            icon: _productController.filteredProducts.isNotEmpty
                                ? Icons.inventory_2_outlined
                                : Icons.filter_alt_off_rounded,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshCurrentResults,
                    child: _buildProductsGrid(
                      products: visibleProducts,
                      isDarkMode: isDarkMode,
                    ),
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
      physics: const AlwaysScrollableScrollPhysics(),
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
    final bool isFavorite = _customerController.isFavorite(product.id);

    final bool isChangingFavorite =
        _customerController.isChangingFavorite.value &&
        _customerController.changingFavoriteProductId.value == product.id;

    final bool isAddingToCart =
        _customerController.isAddingCartItem.value &&
        _customerController.addingCartProductId.value == product.id;

    return GestureDetector(
      onTap: () => _openProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode
                ? AppTheme.inputFieldBg.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: _isArabic()
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
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
                        : AppTheme.background.withValues(alpha: 0.5),
                    child: _buildProductImage(
                      product,
                      isDarkMode,
                      activePrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: _isArabic()
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.title.isNotEmpty
                              ? product.title
                              : 'منتج بدون اسم',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? AppTheme.textPrimary
                                : AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: _isArabic()
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!_isArabic())
                              Icon(
                                Icons.location_on,
                                size: 11,
                                color: activePrimary,
                              ),
                            Expanded(
                              child: Text(
                                product.governorate.isNotEmpty
                                    ? LocalizedContent.value(
                                        context,
                                        product.governorate,
                                      )
                                    : AppLocalizations.of(
                                        context,
                                      ).translate('not_available'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDarkMode
                                      ? AppTheme.textSecondary
                                      : AppTheme.textLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: _isArabic()
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                            if (_isArabic())
                              Icon(
                                Icons.location_on,
                                size: 11,
                                color: activePrimary,
                              ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: _isArabic()
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!_isArabic())
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 11,
                                color: Colors.orange,
                              ),
                            if (!_isArabic()) const SizedBox(width: 3),
                            Text(
                              product.quantity.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'الكمية المتوفرة',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDarkMode
                                      ? AppTheme.textSecondary
                                      : AppTheme.textLight,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: _isArabic()
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                            if (_isArabic()) const SizedBox(width: 3),
                            if (_isArabic())
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 11,
                                color: Colors.orange,
                              ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: isAddingToCart
                                  ? null
                                  : () => _addProductToCart(product),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? AppTheme.selectedBorder
                                      : AppTheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: isAddingToCart
                                    ? Padding(
                                        padding: const EdgeInsets.all(7),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: isDarkMode
                                              ? AppTheme.darkBackground
                                              : Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        Icons.add_shopping_cart,
                                        color: isDarkMode
                                            ? AppTheme.darkBackground
                                            : Colors.white,
                                        size: 14,
                                      ),
                              ),
                            ),
                            Row(
                              children: [
                                if (!_isArabic())
                                  Text(
                                    _formatPrice(product.price),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: activePrimary,
                                    ),
                                  ),
                                Text(
                                  ' ${AppLocalizations.of(context).translate('currency')} ',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_isArabic())
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: isChangingFavorite
                    ? null
                    : () => _toggleFavorite(product),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppTheme.inputFieldBg : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: isChangingFavorite
                      ? const Padding(
                          padding: EdgeInsets.all(7),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        )
                      : Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 14,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(
    ProductModel product,
    bool isDarkMode,
    Color activePrimary,
  ) {
    if (product.fullImageUrl.isEmpty) {
      return Icon(
        Icons.image_outlined,
        size: 48,
        color: activePrimary.withValues(alpha: isDarkMode ? 0.85 : 0.6),
      );
    }

    return Image.network(
      product.fullImageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 95,
      errorBuilder: (_, __, ___) {
        return Icon(
          Icons.broken_image_outlined,
          size: 44,
          color: activePrimary.withValues(alpha: isDarkMode ? 0.85 : 0.6),
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
              AppFeedback.error(context, 'رقم التصنيف غير صحيح');
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
                  color: Colors.black.withValues(
                    alpha: isDarkMode ? 0.15 : 0.02,
                  ),
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
                          color: finalIconColor.withValues(
                            alpha: isDarkMode ? 0.18 : 0.1,
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
                          color: finalIconColor.withValues(
                            alpha: isDarkMode ? 0.18 : 0.1,
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
                            ? AppTheme.textSecondary.withValues(alpha: 0.5)
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

  bool _isArabic() => Localizations.localeOf(context).languageCode == 'ar';
}
