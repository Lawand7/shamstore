import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/customer/controllers/customer_controller.dart';
import 'package:shamstore/features/products/controllers/product_controller.dart';
import 'package:shamstore/features/products/models/product_model.dart';
import 'package:shamstore/screen/product_details_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/utils/localized_content.dart';

class CategoryProductsPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  late final ProductController _productController;
  late final CustomerController _customerController;

  final ScrollController _scrollController = ScrollController();

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
      _loadInitialData();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 250) {
      _productController.loadMoreCategoryProducts();
    }
  }

  Future<void> _loadInitialData() async {
    await _refreshAll();
  }

  Future<void> _refreshProducts() async {
    await _productController.fetchProductsByCategory(
      categoryId: widget.categoryId,
      refresh: true,
    );
  }

  Future<void> _refreshAll() async {
    await _refreshProducts();

    await Future.wait<bool>([
      _customerController.fetchFavoriteProducts(refresh: true),
      _customerController.fetchCart(),
    ]);
  }

  List<ProductModel> get _visibleProducts {
    return _productController.categoryProducts
        .where(
          (ProductModel product) => product.isActive && product.quantity > 0,
        )
        .toList();
  }

  bool _isProductAvailable(ProductModel product) {
    return product.isActive && product.quantity > 0;
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

  Future<void> _openProductDetails(ProductModel product) async {
    if (!_isProductAvailable(product)) {
      _showSnackBar(
        title: AppLocalizations.of(
          context,
        ).translate('product_unavailable_title'),
        message: product.quantity <= 0
            ? AppLocalizations.of(context).translate('product_out_of_stock')
            : AppLocalizations.of(
                context,
              ).translate('product_hidden_by_seller'),
        isError: true,
      );

      await _refreshProducts();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsPage(product: _productToMap(product)),
      ),
    );

    if (!mounted) return;

    await _refreshAll();
  }

  Future<void> _toggleFavorite(ProductModel product) async {
    if (!_isProductAvailable(product)) {
      _showSnackBar(
        title: AppLocalizations.of(
          context,
        ).translate('product_unavailable_title'),
        message: AppLocalizations.of(
          context,
        ).translate('error_edit_unavailable_favorite'),
        isError: true,
      );
      await _refreshProducts();
      return;
    }

    final bool wasFavorite = _customerController.isFavorite(product.id);

    final bool success = await _customerController.toggleFavorite(
      product: product,
    );

    if (!mounted) return;

    if (!success) {
      _showSnackBar(
        title: AppLocalizations.of(context).translate('action_failed_title'),
        message: _customerController.favoriteActionErrorMessage.value.isNotEmpty
            ? _customerController.favoriteActionErrorMessage.value
            : AppLocalizations.of(context).translate('error_edit_favorite'),
        isError: true,
      );
      return;
    }

    _showSnackBar(
      title: AppLocalizations.of(context).translate('success_title'),
      message: wasFavorite
          ? AppLocalizations.of(context).translate('success_removed_favorite')
          : AppLocalizations.of(context).translate('success_added_favorite'),
      isError: false,
    );
  }

  Future<void> _addProductToCart(ProductModel product) async {
    if (!_isProductAvailable(product)) {
      _showSnackBar(
        title: AppLocalizations.of(
          context,
        ).translate('product_unavailable_title'),
        message: product.quantity <= 0
            ? AppLocalizations.of(context).translate('product_out_of_stock')
            : AppLocalizations.of(
                context,
              ).translate('product_hidden_by_seller'),
        isError: true,
      );
      await _refreshProducts();
      return;
    }

    final existingItem = _customerController.findCartItemByProductId(
      product.id,
    );

    if (existingItem != null && existingItem.quantity >= product.quantity) {
      _showSnackBar(
        title: AppLocalizations.of(
          context,
        ).translate('quantity_unavailable_title'),
        message:
            '${AppLocalizations.of(context).translate('cart_has_full_quantity')}: ${product.quantity}',
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
        title: AppLocalizations.of(context).translate('add_failed_title'),
        message: _customerController.addCartItemErrorMessage.value.isNotEmpty
            ? _customerController.addCartItemErrorMessage.value
            : AppLocalizations.of(context).translate('error_add_to_cart'),
        isError: true,
      );
      return;
    }

    _showSnackBar(
      title: AppLocalizations.of(context).translate('added_success_title'),
      message: AppLocalizations.of(context).translate('success_added_to_cart'),
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

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDarkMode),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshAll,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildInfoBar(isDarkMode)),
                    _buildProductsSliver(isDarkMode),
                    SliverToBoxAdapter(child: _buildLoadMoreIndicator()),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isArabic()
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_new_rounded,
                color: AppTheme.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.categoryName,
              textAlign: _isArabic() ? TextAlign.end : TextAlign.start,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar(bool isDarkMode) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _refreshAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
              child: Text(
                AppLocalizations.of(context).translate('refresh_btn'),
                style: TextStyle(
                  color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              '${AppLocalizations.of(context).translate('available_products_count')} ${_visibleProducts.length}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProductsSliver(bool isDarkMode) {
    return Obx(() {
      final List<ProductModel> visibleProducts = _visibleProducts;

      if (_productController.isCategoryLoading.value &&
          _productController.categoryProducts.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (_productController.categoryErrorMessage.value.isNotEmpty &&
          _productController.categoryProducts.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: _buildErrorState(isDarkMode),
          ),
        );
      }

      if (visibleProducts.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: _buildEmptyState(
              isDarkMode,
              allProductsUnavailable:
                  _productController.categoryProducts.isNotEmpty,
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            final ProductModel product = visibleProducts[index];

            return _buildProductCard(product, isDarkMode);
          }, childCount: visibleProducts.length),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
        ),
      );
    });
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (!_productController.isCategoryLoadingMore.value) {
        return const SizedBox.shrink();
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
    final Color activePrimary = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 36),
          const SizedBox(height: 10),
          Text(
            _productController.categoryErrorMessage.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _refreshProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: activePrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).translate('retry'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDarkMode, {
    required bool allProductsUnavailable,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            allProductsUnavailable
                ? AppLocalizations.of(
                    context,
                  ).translate('no_available_products')
                : AppLocalizations.of(
                    context,
                  ).translate('no_products_in_category'),
            style: TextStyle(
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            allProductsUnavailable
                ? AppLocalizations.of(
                    context,
                  ).translate('products_out_of_stock_hidden')
                : AppLocalizations.of(
                    context,
                  ).translate('swipe_down_to_refresh'),
            style: TextStyle(
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
                              : AppLocalizations.of(
                                  context,
                                ).translate('unnamed_product'),
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
                                AppLocalizations.of(
                                  context,
                                ).translate('available_quantity_label'),
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

  bool _isArabic() => Localizations.localeOf(context).languageCode == 'ar';
}
