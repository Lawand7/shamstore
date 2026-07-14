import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/features/seller/controllers/seller_product_controller.dart';
import 'package:shamstore/screen/add_product_page.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/screen/update_product_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class MyProductsPage extends StatefulWidget {
  final dynamic product;

  const MyProductsPage({super.key, this.product});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  late final SellerProductController _sellerProductController;

  String _selectedTab = 'الكل';

  final List<String> _tabs = ['الكل', 'منشور', 'غير منشور'];

  @override
  void initState() {
    super.initState();

    _sellerProductController = Get.isRegistered<SellerProductController>()
        ? Get.find<SellerProductController>()
        : Get.put(SellerProductController());

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadProducts();
    await _loadCounts();
  }

  Future<void> _loadProducts() async {
    await _sellerProductController.fetchAllMyProducts();
  }

  Future<void> _loadActiveProducts() async {
    await _sellerProductController.fetchMyActiveProducts();
  }

  Future<void> _loadInactiveProducts() async {
    await _sellerProductController.fetchMyInactiveProducts();
  }

  Future<void> _loadCounts() async {
    await _sellerProductController.fetchMyProductCounts();
  }

  Future<void> _loadCurrentTab() async {
    if (_selectedTab == 'منشور') {
      await _loadActiveProducts();
      await _loadCounts();
      return;
    }

    if (_selectedTab == 'غير منشور') {
      await _loadInactiveProducts();
      await _loadCounts();
      return;
    }

    await _loadProducts();
    await _loadCounts();
  }

  Future<void> _reloadAfterDataChange() async {
    await _loadProducts();
    await _loadCounts();

    if (_selectedTab == 'منشور') {
      await _loadActiveProducts();
    }

    if (_selectedTab == 'غير منشور') {
      await _loadInactiveProducts();
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedTab == 'الكل') {
      return _sellerProductController.myProducts.toList();
    }

    if (_selectedTab == 'منشور') {
      return _sellerProductController.myActiveProducts.toList();
    }

    return _sellerProductController.myInactiveProducts.toList();
  }

  int get _publishedCount => _sellerProductController.activeProductsCount;

  int get _unpublishedCount => _sellerProductController.inactiveProductsCount;

  int get _soldCount => 0;

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
          AppLocalizations.of(context).translate('My Products'),
          style: const TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductPage()),
              );

              if (!mounted) return;

              if (result == true) {
                await _reloadAfterDataChange();
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: AppTheme.white, size: 25),
            ),
          ),
        ],
        leading: IconButton(
          icon: Icon(
            _isArabic() ? Icons.arrow_forward : Icons.arrow_back,
            color: AppTheme.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        final bool isLoading =
            _sellerProductController.isLoadingMyProducts.value ||
            _sellerProductController.isLoadingProductCounts.value ||
            (_selectedTab == 'منشور' &&
                _sellerProductController.isLoadingActiveProducts.value) ||
            (_selectedTab == 'غير منشور' &&
                _sellerProductController.isLoadingInactiveProducts.value);

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_selectedTab == 'منشور' &&
            _sellerProductController
                .activeProductsErrorMessage
                .value
                .isNotEmpty) {
          return _buildErrorState(isDarkMode);
        }

        if (_selectedTab == 'غير منشور' &&
            _sellerProductController
                .inactiveProductsErrorMessage
                .value
                .isNotEmpty) {
          return _buildErrorState(isDarkMode);
        }

        if (_selectedTab == 'الكل' &&
            _sellerProductController.myProductsErrorMessage.value.isNotEmpty) {
          return _buildErrorState(isDarkMode);
        }

        return Column(
          children: [
            _buildStats(context, isDarkMode),
            _buildTabs(context, isDarkMode),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadCurrentTab,
                child: _buildProductsList(context, isDarkMode),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildErrorState(bool isDarkMode) {
    String errorMessage = _sellerProductController.myProductsErrorMessage.value;

    if (_selectedTab == 'منشور') {
      errorMessage = _sellerProductController.activeProductsErrorMessage.value;
    }

    if (_selectedTab == 'غير منشور') {
      errorMessage =
          _sellerProductController.inactiveProductsErrorMessage.value;
    }

    if (errorMessage.trim().isEmpty &&
        _sellerProductController.productCountsErrorMessage.value.isNotEmpty) {
      errorMessage = _sellerProductController.productCountsErrorMessage.value;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage.isEmpty
                  ? 'حدث خطأ أثناء تحميل المنتجات'
                  : errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCurrentTab,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _statCard(
            '$_publishedCount',
            AppLocalizations.of(context).translate('Published Stat'),
            isDarkMode,
          ),
          const SizedBox(width: 8),
          _statCard(
            '$_unpublishedCount',
            AppLocalizations.of(context).translate('Unpublished Stat'),
            isDarkMode,
          ),
          const SizedBox(width: 8),
          _statCard(
            '$_soldCount',
            AppLocalizations.of(context).translate('Sold Stat'),
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _statCard(String number, String label, bool isDarkMode) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.transparent : AppTheme.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, bool isDarkMode) {
    return Container(
      color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: _tabs.map((tab) {
          final bool isSelected = tab == _selectedTab;

          String displayLabel = '';

          if (tab == 'الكل') {
            displayLabel = AppLocalizations.of(context).translate('All Tab');
          }

          if (tab == 'منشور') {
            displayLabel = AppLocalizations.of(
              context,
            ).translate('Published Tab');
          }

          if (tab == 'غير منشور') {
            displayLabel = AppLocalizations.of(
              context,
            ).translate('Unpublished Tab');
          }

          final Color activeTabBg = isDarkMode
              ? AppTheme.selectedBorder
              : AppTheme.primary;
          final Color inactiveTabBg = isDarkMode
              ? AppTheme.darkBackground
              : AppTheme.background;

          return Expanded(
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  _selectedTab = tab;
                });

                if (tab == 'الكل') {
                  await _loadProducts();
                  await _loadCounts();
                  return;
                }

                if (tab == 'منشور') {
                  await _loadActiveProducts();
                  await _loadCounts();
                  return;
                }

                if (tab == 'غير منشور') {
                  await _loadInactiveProducts();
                  await _loadCounts();
                  return;
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? activeTabBg : inactiveTabBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  displayLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? (isDarkMode
                              ? AppTheme.darkBackground
                              : AppTheme.white)
                        : (isDarkMode
                              ? AppTheme.textSecondary
                              : AppTheme.textGrey),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, bool isDarkMode) {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 140),
          Icon(
            Icons.inventory_2_outlined,
            size: 60,
            color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).translate('No products found'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(context, products[index], isDarkMode);
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Map<String, dynamic> product,
    bool isDarkMode,
  ) {
    final bool isPublished = _toInt(product['is_active']) == 1;
    final int productId = _toInt(product['id']);

    final Color activePrimary = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;
    final Color greenColor = isDarkMode
        ? const Color(0xFF10B981)
        : const Color(0xFF059669);
    final Color redColor = isDarkMode
        ? const Color(0xFFF87171)
        : const Color(0xFFEF4444);
    final Color hideColor = isDarkMode
        ? AppTheme.textSecondary
        : AppTheme.textGrey;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildProductImage(product, isDarkMode, activePrimary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: _isArabic()
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['title']?.toString() ?? '',
                      textAlign: _isArabic() ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? AppTheme.textPrimary
                            : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(
                        product['created_at'],
                        updatedAt: product['updated_at'],
                      ),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_formatPrice(product['price'])} ${AppLocalizations.of(context).translate('SP')}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: activePrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'الكمية المتوفرة: ${product['quantity'] ?? 0}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPublished
                      ? greenColor.withOpacity(isDarkMode ? 0.15 : 0.1)
                      : redColor.withOpacity(isDarkMode ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isPublished
                          ? AppLocalizations.of(
                              context,
                            ).translate('Published Badge')
                          : AppLocalizations.of(
                              context,
                            ).translate('Unpublished Badge'),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: isPublished ? greenColor : redColor,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      isPublished
                          ? Icons.check_circle_outline
                          : Icons.access_time,
                      size: 11,
                      color: isPublished ? greenColor : redColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            height: 1,
            color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() {
                final bool isThisProductDeleting =
                    _sellerProductController.isDeletingProduct.value &&
                    _sellerProductController.deletingProductId.value ==
                        productId;

                return _actionBtn(
                  isThisProductDeleting
                      ? '...'
                      : AppLocalizations.of(context).translate('Delete Action'),
                  Icons.delete_outline,
                  redColor,
                  isThisProductDeleting
                      ? () {}
                      : () {
                          _confirmDeleteProduct(
                            productId: productId,
                            title: product['title']?.toString() ?? '',
                          );
                        },
                );
              }),
              const SizedBox(width: 8),
              _actionBtn(
                AppLocalizations.of(context).translate('Edit Action'),
                Icons.edit_outlined,
                activePrimary,
                () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateProductPage(product: product),
                    ),
                  );

                  if (!mounted) return;

                  if (result is Map && result['updated'] == true) {
                    await _reloadAfterDataChange();
                  }
                },
              ),
              const SizedBox(width: 8),
              Obx(() {
                final bool isThisProductChanging =
                    _sellerProductController
                        .isChangingProductVisibility
                        .value &&
                    _sellerProductController
                            .changingVisibilityProductId
                            .value ==
                        productId;

                return _actionBtn(
                  isThisProductChanging
                      ? '...'
                      : isPublished
                      ? AppLocalizations.of(context).translate('Hide Action')
                      : AppLocalizations.of(
                          context,
                        ).translate('Publish Action'),
                  isPublished
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  isPublished ? hideColor : greenColor,
                  isThisProductChanging
                      ? () {}
                      : () async {
                          await _toggleProductVisibility(
                            productId: productId,
                            isPublished: isPublished,
                          );
                        },
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteProduct({
    required int productId,
    required String title,
  }) async {
    if (productId <= 0) {
      Get.snackbar(
        'خطأ',
        'معرّف المنتج غير صالح',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final bool isDarkMode =
            Theme.of(dialogContext).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDarkMode
              ? AppTheme.cardBackground
              : AppTheme.white,
          title: Text(
            'تأكيد الحذف',
            style: TextStyle(
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            title.trim().isEmpty
                ? 'هل أنت متأكد من حذف هذا المنتج؟'
                : 'هل أنت متأكد من حذف المنتج "$title"؟',
            style: TextStyle(
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteProduct(productId: productId);
    }
  }

  Future<void> _deleteProduct({required int productId}) async {
    final bool success = await _sellerProductController.deleteProduct(
      productId: productId,
    );

    if (!mounted) return;

    if (!success) {
      Get.snackbar(
        'فشل الحذف',
        _sellerProductController.deleteProductErrorMessage.value.isNotEmpty
            ? _sellerProductController.deleteProductErrorMessage.value
            : 'حدث خطأ أثناء حذف المنتج',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'نجاح',
      'تم حذف المنتج بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );

    await _reloadAfterDataChange();
  }

  Future<void> _toggleProductVisibility({
    required int productId,
    required bool isPublished,
  }) async {
    if (productId <= 0) {
      Get.snackbar(
        'خطأ',
        'معرّف المنتج غير صالح',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final bool success = isPublished
        ? await _sellerProductController.hideProduct(productId: productId)
        : await _sellerProductController.activeProduct(productId: productId);

    if (!mounted) return;

    if (!success) {
      Get.snackbar(
        'فشل العملية',
        _sellerProductController.productVisibilityErrorMessage.value.isNotEmpty
            ? _sellerProductController.productVisibilityErrorMessage.value
            : 'حدث خطأ أثناء تغيير حالة المنتج',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'نجاح',
      isPublished ? 'تم إخفاء المنتج بنجاح' : 'تم نشر المنتج بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );

    await _reloadAfterDataChange();
  }

  Widget _buildProductImage(
    Map<String, dynamic> product,
    bool isDarkMode,
    Color activePrimary,
  ) {
    final imageUrl = _resolveProductImageUrl(product['product_image_url']);

    if (imageUrl == null) {
      return _imagePlaceholder(isDarkMode, activePrimary);
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imagePlaceholder(isDarkMode, activePrimary);
        },
      ),
    );
  }

  Widget _imagePlaceholder(bool isDarkMode, Color activePrimary) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.inventory_2_outlined, size: 30, color: activePrimary),
    );
  }

  String? _resolveProductImageUrl(dynamic value) {
    if (value == null) return null;

    final path = value.toString().trim();

    if (path.isEmpty) return null;

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final serverBaseUrl = ApiConstants.baseUrl.replaceFirst(
      RegExp(r'/api/?$'),
      '',
    );

    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    if (normalizedPath.startsWith('storage/')) {
      return '$serverBaseUrl/$normalizedPath';
    }

    if (normalizedPath.startsWith('products/')) {
      return '$serverBaseUrl/storage/$normalizedPath';
    }

    return '$serverBaseUrl/$normalizedPath';
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 13, color: color),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic createdAt, {dynamic updatedAt}) {
    final rawDate = createdAt ?? updatedAt;

    if (rawDate == null) return '';

    final parsedDate = DateTime.tryParse(rawDate.toString());

    if (parsedDate == null) {
      return rawDate.toString();
    }

    final localDate = parsedDate.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();

    return '$day/$month/$year';
  }

  String _formatPrice(dynamic value) {
    if (value == null) return '0';

    final number = double.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    if (number == number.roundToDouble()) {
      return number.toStringAsFixed(0);
    }

    return number.toStringAsFixed(2);
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  bool _isArabic() {
    return Localizations.localeOf(context).languageCode == 'ar';
  }
}
