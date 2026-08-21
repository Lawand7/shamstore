import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/customer/controllers/customer_controller.dart';
import 'package:shamstore/features/products/models/product_model.dart';
import 'package:shamstore/screen/product_details_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/utils/localized_content.dart';

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

  List<ProductModel> get _visibleFavoriteProducts {
    return _customerController.favoriteProducts
        .where(
          (ProductModel product) => product.isActive && product.quantity > 0,
        )
        .toList();
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
    await Future.wait<bool>([
      _customerController.fetchFavoriteProducts(refresh: true),
      _customerController.fetchCart(),
    ]);
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

  bool _isProductAvailable(ProductModel product) {
    return product.isActive && product.quantity > 0;
  }

  Future<void> _removeFromFavorites(ProductModel product) async {
    final bool success = await _customerController.removeFromFavorites(
      productId: product.id,
    );

    if (!mounted) return;

    if (!success) {
      _showSnackBar(
        title: AppLocalizations.of(context).translate('action_failed_title'),
        message: _customerController.favoriteActionErrorMessage.value.isNotEmpty
            ? _customerController.favoriteActionErrorMessage.value
            : AppLocalizations.of(context).translate('error_remove_favorite'),
        isError: true,
      );
      return;
    }

    _customerController.favoriteProducts.removeWhere(
      (ProductModel item) => item.id == product.id,
    );

    _showSnackBar(
      title: AppLocalizations.of(context).translate('success_title'),
      message: AppLocalizations.of(
        context,
      ).translate('success_removed_favorite'),
      isError: false,
    );
  }

  Future<void> _openProductDetails(ProductModel product) async {
    if (!_isProductAvailable(product)) {
      _showUnavailableProductMessage(product);
      await _loadFavorites();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsPage(product: _productToMap(product)),
      ),
    );

    if (!mounted) return;
    await _loadFavorites();
  }

  Future<void> _addProductToCart(ProductModel product) async {
    if (!_isProductAvailable(product)) {
      _showUnavailableProductMessage(product);
      await _loadFavorites();
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

  void _showUnavailableProductMessage(ProductModel product) {
    _showSnackBar(
      title: AppLocalizations.of(
        context,
      ).translate('product_unavailable_title'),
      message: product.quantity <= 0
          ? AppLocalizations.of(context).translate('product_out_of_stock')
          : AppLocalizations.of(context).translate('product_hidden_by_seller'),
      isError: true,
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
      'price': _formatProductPrice(product.price),
      'quantity': product.quantity,
      'product_image_url': product.productImageUrl,
      'imageUrl': product.fullImageUrl,
      'product_url': product.productUrl,
      'is_active': product.isActive,
      'created_at': product.createdAt,
      'updated_at': product.updatedAt,
      'fav': true,
      'rating': 0.0,
      'sold': 0,
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
        title: Text(
          AppLocalizations.of(context).translate('nav_favorites'),
          style: const TextStyle(
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
        final List<ProductModel> visibleProducts = _visibleFavoriteProducts;
        final bool hasStoredFavorites =
            _customerController.favoriteProducts.isNotEmpty;

        if (_customerController.isLoadingFavorites.value &&
            !hasStoredFavorites) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_customerController.favoriteProductsErrorMessage.value.isNotEmpty &&
            !hasStoredFavorites) {
          return _buildErrorState(isDarkMode);
        }

        if (visibleProducts.isEmpty) {
          return RefreshIndicator(
            onRefresh: _loadFavorites,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.65,
                  child: _buildEmptyState(
                    isDarkMode,
                    hasUnavailableFavorites: hasStoredFavorites,
                  ),
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
              SliverToBoxAdapter(
                child: _buildFavoritesInfo(
                  isDarkMode: isDarkMode,
                  visibleCount: visibleProducts.length,
                  hiddenCount:
                      _customerController.favoriteProducts.length -
                      visibleProducts.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = visibleProducts[index];

                    return _buildFavoriteCard(
                      product: product,
                      isDarkMode: isDarkMode,
                    );
                  }, childCount: visibleProducts.length),
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

  Widget _buildFavoritesInfo({
    required bool isDarkMode,
    required int visibleCount,
    required int hiddenCount,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (hiddenCount > 0)
            Text(
              '${AppLocalizations.of(context).translate('hidden_unavailable_count')} $hiddenCount',
              style: TextStyle(
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
                fontSize: 11,
              ),
            )
          else
            const SizedBox.shrink(),
          Text(
            '${AppLocalizations.of(context).translate('available_products_count')} $visibleCount',
            style: TextStyle(
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 58,
                      color: isDarkMode
                          ? AppTheme.textSecondary
                          : AppTheme.textGrey,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _customerController.favoriteProductsErrorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textGrey,
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
                      child: Text(
                        AppLocalizations.of(context).translate('retry'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDarkMode, {
    required bool hasUnavailableFavorites,
  }) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasUnavailableFavorites
                  ? Icons.inventory_2_outlined
                  : Icons.favorite_border_rounded,
              size: 60,
              color: hasUnavailableFavorites
                  ? activeColor.withValues(alpha: 0.7)
                  : isDarkMode
                  ? AppTheme.textSecondary.withValues(alpha: 0.4)
                  : AppTheme.textLight.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              hasUnavailableFavorites
                  ? AppLocalizations.of(
                      context,
                    ).translate('favorites_unavailable_title')
                  : AppLocalizations.of(
                      context,
                    ).translate('favorites_empty_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasUnavailableFavorites
                  ? AppLocalizations.of(
                      context,
                    ).translate('favorites_unavailable_desc')
                  : AppLocalizations.of(
                      context,
                    ).translate('favorites_empty_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
              ),
            ),
          ],
        ),
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

    final bool isThisProductChanging =
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
            color: isDarkMode ? Colors.transparent : AppTheme.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.04),
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
                    height: 100,
                    width: double.infinity,
                    color: isDarkMode
                        ? AppTheme.inputFieldBg
                        : AppTheme.background.withValues(alpha: 0.5),
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
                          textAlign: _isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                        _buildLocationRow(
                          product: product,
                          isDarkMode: isDarkMode,
                          activeColor: activeColor,
                        ),
                        _buildQuantityRow(
                          product: product,
                          isDarkMode: isDarkMode,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: isAddingToCart
                                  ? null
                                  : () => _addProductToCart(product),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? AppTheme.selectedBorder
                                      : AppTheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: isAddingToCart
                                    ? const Padding(
                                        padding: EdgeInsets.all(7),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.add_shopping_cart,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                              ),
                            ),
                            _buildPrice(product, activeColor),
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
                onTap: isThisProductChanging
                    ? null
                    : () => _removeFromFavorites(product),
                child: Container(
                  width: 30,
                  height: 30,
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
                  child: isThisProductChanging
                      ? const Padding(
                          padding: EdgeInsets.all(7),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.favorite, color: Colors.red, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required ProductModel product,
    required bool isDarkMode,
    required Color activeColor,
  }) {
    return Row(
      mainAxisAlignment: _isArabic
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!_isArabic) Icon(Icons.location_on, size: 11, color: activeColor),
        if (!_isArabic) const SizedBox(width: 3),
        Expanded(
          child: Text(
            product.governorate.isNotEmpty
                ? LocalizedContent.value(context, product.governorate)
                : AppLocalizations.of(context).translate('not_available'),
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: _isArabic ? TextAlign.right : TextAlign.left,
          ),
        ),
        if (_isArabic) const SizedBox(width: 3),
        if (_isArabic) Icon(Icons.location_on, size: 11, color: activeColor),
      ],
    );
  }

  Widget _buildQuantityRow({
    required ProductModel product,
    required bool isDarkMode,
  }) {
    return Row(
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
            AppLocalizations.of(context).translate('available_quantity_label'),
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: _isArabic ? TextAlign.right : TextAlign.left,
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
    );
  }

  Widget _buildPrice(ProductModel product, Color activeColor) {
    return Row(
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
        Text(
          AppLocalizations.of(context).translate('currency_sp'),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
        color: activeColor.withValues(alpha: isDarkMode ? 0.8 : 0.6),
      );
    }

    return Image.network(
      product.fullImageUrl,
      width: double.infinity,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Icon(
          Icons.broken_image_outlined,
          size: 52,
          color: activeColor.withValues(alpha: isDarkMode ? 0.8 : 0.6),
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
