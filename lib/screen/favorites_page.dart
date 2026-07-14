import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/customer/controllers/customer_controller.dart';
import 'package:shamstore/features/products/models/product_model.dart';
import 'package:shamstore/screen/product_details_Page.dart';
import 'package:shamstore/them/app_theme.dart';

class FavoritesPage extends StatefulWidget {
  final List<Map<String, dynamic>> allProducts;

  const FavoritesPage({super.key, required this.allProducts});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final CustomerController _customerController;
  final ScrollController _scrollController = ScrollController();

  bool _isLoadMoreScheduled = false;

  bool get _isArabic {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  @override
  void initState() {
    super.initState();

    _customerController = Get.isRegistered<CustomerController>()
        ? Get.find<CustomerController>()
        : Get.put(CustomerController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadFavorites();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    await _customerController.fetchFavoriteProducts(refresh: true);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 220 && !_isLoadMoreScheduled) {
      _isLoadMoreScheduled = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          _isLoadMoreScheduled = false;
          return;
        }

        await _customerController.loadMoreFavoriteProducts();
        _isLoadMoreScheduled = false;
      });
    }
  }

  Future<void> _removeFromFavorites(ProductModel product) async {
    final bool success = await _customerController.removeFromFavorites(
      productId: product.id,
    );

    if (!mounted) return;

    if (!success) {
      Get.snackbar(
        'فشل العملية',
        _customerController.favoriteActionErrorMessage.value.isNotEmpty
            ? _customerController.favoriteActionErrorMessage.value
            : 'حدث خطأ أثناء حذف المنتج من المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'نجاح',
      'تم حذف المنتج من المفضلة',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _openProductDetails(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsPage(product: _productToMap(product)),
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
      'price': _formatProductPrice(product.price),
      'quantity': product.quantity,
      'product_image_url': product.productImageUrl,
      'imageUrl': product.fullImageUrl,
      'product_url': product.productUrl,
      'is_active': product.isActive,
      'created_at': product.createdAt,
      'updated_at': product.updatedAt,
      'sellerRating': 0.0,
      'sellerName': 'Seller #${product.sellerId}',
    };
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
        title: const Text(
          'المفضلة',
          style: TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            _isArabic
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: AppTheme.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        if (_customerController.isLoadingFavorites.value &&
            _customerController.favoriteProducts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_customerController.favoriteProductsErrorMessage.value.isNotEmpty &&
            _customerController.favoriteProducts.isEmpty) {
          return _buildErrorState(isDarkMode);
        }

        if (_customerController.favoriteProducts.isEmpty) {
          return RefreshIndicator(
            onRefresh: _loadFavorites,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: _buildEmptyState(isDarkMode),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadFavorites,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = _customerController.favoriteProducts[index];

                    return _buildFavoriteCard(
                      product: product,
                      isDarkMode: isDarkMode,
                    );
                  }, childCount: _customerController.favoriteProducts.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildLoadMoreIndicator()),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (!_customerController.isLoadingMoreFavorites.value) {
        return const SizedBox(height: 16);
      }

      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    });
  }

  Widget _buildErrorState(bool isDarkMode) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 58,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
            ),
            const SizedBox(height: 14),
            Text(
              _customerController.favoriteProductsErrorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _loadFavorites,
              style: ElevatedButton.styleFrom(
                backgroundColor: activeColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 60,
            color: isDarkMode
                ? AppTheme.textSecondary.withOpacity(0.4)
                : AppTheme.textLight.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'قائمة المفضلة فارغة',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'اضغط على زر القلب في الصفحة الرئيسية لإضافة المنتجات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard({
    required ProductModel product,
    required bool isDarkMode,
  }) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return GestureDetector(
      onTap: () => _openProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.transparent : AppTheme.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: _isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    color: isDarkMode
                        ? AppTheme.inputFieldBg
                        : AppTheme.background.withOpacity(0.5),
                    child: _buildProductImage(
                      product: product,
                      isDarkMode: isDarkMode,
                      activeColor: activeColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: _isArabic
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
                          textAlign: _isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                        Row(
                          mainAxisAlignment: _isArabic
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!_isArabic)
                              Icon(
                                Icons.location_on,
                                size: 11,
                                color: activeColor,
                              ),
                            Expanded(
                              child: Text(
                                product.governorate.isNotEmpty
                                    ? product.governorate
                                    : 'غير متوفر',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDarkMode
                                      ? AppTheme.textSecondary
                                      : AppTheme.textLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: _isArabic
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                            if (_isArabic)
                              Icon(
                                Icons.location_on,
                                size: 11,
                                color: activeColor,
                              ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: _isArabic
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!_isArabic)
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 11,
                                color: Colors.orange,
                              ),
                            if (!_isArabic) const SizedBox(width: 3),
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
                                textAlign: _isArabic
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                            if (_isArabic) const SizedBox(width: 3),
                            if (_isArabic)
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
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('إضافة السلة سنربطها لاحقاً'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.add_shopping_cart,
                                color: activeColor,
                                size: 18,
                              ),
                            ),
                            Row(
                              children: [
                                if (!_isArabic)
                                  Text(
                                    _formatProductPrice(product.price),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: activeColor,
                                    ),
                                  ),
                                const SizedBox(width: 3),
                                const Text(
                                  'ل.س',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                if (_isArabic)
                                  Text(
                                    _formatProductPrice(product.price),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: activeColor,
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
              child: Obx(() {
                final bool isThisProductChanging =
                    _customerController.isChangingFavorite.value &&
                    _customerController.changingFavoriteProductId.value ==
                        product.id;

                return GestureDetector(
                  onTap: isThisProductChanging
                      ? null
                      : () async {
                          await _removeFromFavorites(product);
                        },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppTheme.inputFieldBg : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: isThisProductChanging
                        ? const Padding(
                            padding: EdgeInsets.all(7),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 16,
                          ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage({
    required ProductModel product,
    required bool isDarkMode,
    required Color activeColor,
  }) {
    if (product.fullImageUrl.isEmpty) {
      return Icon(
        Icons.image_outlined,
        size: 56,
        color: activeColor.withOpacity(isDarkMode ? 0.8 : 0.6),
      );
    }

    return Image.network(
      product.fullImageUrl,
      width: double.infinity,
      height: 110,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Icon(
          Icons.broken_image_outlined,
          size: 52,
          color: activeColor.withOpacity(isDarkMode ? 0.8 : 0.6),
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
              color: activeColor,
            ),
          ),
        );
      },
    );
  }

  String _formatProductPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }
}
