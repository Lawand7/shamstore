import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/core/storage/token_storage.dart';
import 'package:shamstore/features/customer/controllers/customer_controller.dart';
import 'package:shamstore/features/notifications/controllers/notifications_controller.dart';
import 'package:shamstore/features/products/controllers/product_controller.dart';
import 'package:shamstore/features/products/models/product_model.dart';
import 'package:shamstore/screen/cart_page.dart';
import 'package:shamstore/screen/category_products.dart';
import 'package:shamstore/screen/enter_pin_screen.dart';
import 'package:shamstore/screen/favorites_page.dart';
import 'package:shamstore/screen/my_balanc_page.dart';
import 'package:shamstore/screen/my_products_page.dart';
import 'package:shamstore/screen/myorder_page.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/screen/product_details_Page.dart';
import 'package:shamstore/screen/profile_page.dart';
import 'package:shamstore/screen/search_page.dart';
import 'package:shamstore/screen/seller_orders_page.dart';
import 'package:shamstore/screen/widgets/home_ads_section.dart';
import 'package:shamstore/screen/widgets/exit_confirmation_scope.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class HomePage extends StatefulWidget {
  final bool isBuyer;

  const HomePage({super.key, this.isBuyer = true});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final ProductController _productController;
  late final CustomerController _customerController;
  late final NotificationsController _notificationsController;

  final ScrollController _scrollController = ScrollController();

  bool get _isBuyer {
    final role = TokenStorage.getUserRole()?.trim().toLowerCase();

    if (role == 'seller') {
      return false;
    }

    if (role == 'customer' || role == 'buyer') {
      return true;
    }

    return widget.isBuyer;
  }

  bool get _isSeller => !_isBuyer;

  final List<String> _categoryKeys = [
    'cat_electronics',
    'cat_clothing',
    'cat_shoes',
    'cat_books',
    'cat_furniture',
    'cat_sports',
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

    _notificationsController = Get.isRegistered<NotificationsController>()
        ? Get.find<NotificationsController>()
        : Get.put(NotificationsController());

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

  Future<void> _loadInitialData() async {
    await _refreshNotifications();
    await _refreshProducts();

    if (_isBuyer) {
      await _refreshFavorites();
      await _refreshCart();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 250) {
      _productController.loadMoreProducts();
    }
  }

  Future<void> _refreshProducts() async {
    await _productController.fetchProducts(refresh: true);
  }

  Future<void> _refreshFavorites() async {
    if (!_isBuyer) return;

    await _customerController.fetchFavoriteProducts(refresh: true);
  }

  Future<void> _refreshCart() async {
    if (!_isBuyer) return;

    await _customerController.fetchCart();
  }

  Future<void> _refreshHomeData() async {
    await _refreshNotifications();
    await _refreshProducts();

    if (_isBuyer) {
      await _refreshFavorites();
      await _refreshCart();
    }
  }

  Future<void> _refreshNotifications() async {
    await _notificationsController.refreshNotifications();

    /*
     * لا يوجد في الباك Endpoint مستقل لعدد غير المقروء.
     * لذلك نحمّل الصفحات المتبقية حتى يكون رقم الجرس دقيقاً،
     * وليس محسوباً من أول 20 إشعاراً فقط.
     */
    while (_notificationsController.hasMore) {
      final loaded = await _notificationsController.fetchNotifications(
        refresh: false,
      );

      if (!loaded) {
        break;
      }
    }
  }

  Future<void> _openNotificationsPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );

    if (!mounted) return;

    await _refreshNotifications();
  }

  Future<void> _openProfilePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfilePage(isBuyer: _isBuyer)),
    );

    if (!mounted) return;

    setState(() {
      // إعادة قراءة الاسم والصورة من TokenStorage بعد تعديل الملف الشخصي.
    });
  }

  String get _displayName => TokenStorage.getDisplayName();

  String get _profileImageUrl {
    final raw = TokenStorage.getProfileImageUrl()?.trim() ?? '';

    if (raw.isEmpty) {
      return '';
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    final serverBase = ApiConstants.baseUrl
        .replaceFirst(RegExp(r'/api/?$'), '')
        .replaceAll(RegExp(r'/$'), '');

    final cleanPath = raw
        .replaceAll(r'\', '/')
        .replaceFirst(RegExp(r'^/+'), '')
        .replaceFirst(RegExp(r'^public/storage/'), '')
        .replaceFirst(RegExp(r'^storage/'), '');

    return '$serverBase/storage/$cleanPath';
  }

  Future<void> _openMyProductsPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyProductsPage(product: _legacyProducts),
      ),
    );

    if (!mounted) return;

    await _refreshHomeData();
  }

  List<Map<String, dynamic>> get _legacyProducts {
    return _productController.products
        .map((product) => _productToMap(product))
        .toList();
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
      'fav': _isBuyer && _customerController.isFavorite(product.id),
      'rating': 0.0,
      'sold': 0,
      'sellerRating': 0.0,
      'sellerName': 'Seller #${product.sellerId}',
    };
  }

  Future<void> _toggleFavorite(ProductModel product) async {
    if (!_isBuyer) return;

    if (product.id <= 0) {
      _showSnackBar(
        title: 'خطأ',
        message: 'معرّف المنتج غير صالح',
        isError: true,
      );
      return;
    }

    final wasFavorite = _customerController.isFavorite(product.id);

    final success = await _customerController.toggleFavorite(product: product);

    if (!mounted) return;

    if (!success) {
      _showSnackBar(
        title: 'فشل العملية',
        message: _customerController.favoriteActionErrorMessage.value.isNotEmpty
            ? _customerController.favoriteActionErrorMessage.value
            : 'حدث خطأ أثناء تعديل المفضلة',
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
    if (!_isBuyer) return;

    if (product.id <= 0) {
      _showSnackBar(
        title: 'خطأ',
        message: 'معرّف المنتج غير صالح',
        isError: true,
      );
      return;
    }

    final success = await _customerController.addCartItem(
      productId: product.id,
      quantity: 1,
    );

    if (!mounted) return;

    if (!success) {
      _showSnackBar(
        title: 'فشل الإضافة',
        message: _customerController.addCartItemErrorMessage.value.isNotEmpty
            ? _customerController.addCartItemErrorMessage.value
            : 'حدث خطأ أثناء إضافة المنتج إلى السلة',
        isError: true,
      );
      return;
    }

    _showSnackBar(
      title: 'نجاح',
      message: 'تمت إضافة المنتج إلى السلة',
      isError: false,
    );
  }

  void _showSnackBar({
    required String title,
    required String message,
    required bool isError,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ExitConfirmationScope(
      child: Scaffold(
        backgroundColor: isDarkMode
            ? AppTheme.darkBackground
            : AppTheme.background,
        body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: RefreshIndicator(
            onRefresh: _refreshHomeData,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildTopBar(isDarkMode)),
                SliverToBoxAdapter(child: _buildSearchBar(isDarkMode)),
                const SliverToBoxAdapter(child: HomeAdsSection()),
                SliverToBoxAdapter(child: _buildCategories(isDarkMode)),
                SliverToBoxAdapter(child: _buildSectionHeader(isDarkMode)),
                _buildProductsSliver(isDarkMode),
                SliverToBoxAdapter(child: _buildLoadMoreIndicator()),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(isDarkMode),
      ),
    );
  }

  Widget _buildTopBar(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Row(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _openNotificationsPage,
                child: Obx(() {
                  final count = _notificationsController.unreadCount;

                  return _iconButton(
                    Icons.notifications_none_outlined,
                    badge: count <= 0
                        ? null
                        : (count > 99 ? '99+' : count.toString()),
                  );
                }),
              ),
              const SizedBox(width: 8),
              if (_isBuyer)
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );

                    if (!mounted) return;

                    await _refreshCart();
                    await _refreshProducts();
                  },
                  child: Obx(() {
                    final count = _customerController.cartItemsCount;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  count > 99 ? '99+' : '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              if (_isBuyer) const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EnterPinScreen(isBuyer: _isBuyer),
                    ),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.credit_card_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _isSeller
                    ? AppLocalizations.of(context).translate('seller_dashboard')
                    : AppLocalizations.of(context).translate('hello'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 170),
                child: Text(
                  _displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _openProfilePage,
            child: Container(
              width: 38,
              height: 38,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: _buildProfileAvatar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final imageUrl = _profileImageUrl;

    if (imageUrl.isEmpty) {
      return const Icon(Icons.person, color: Colors.white, size: 20);
    }

    return Image.network(
      imageUrl,
      key: ValueKey<String>(imageUrl),
      width: 38,
      height: 38,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return const Icon(Icons.person, color: Colors.white, size: 20);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const Padding(
          padding: EdgeInsets.all(10),
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        );
      },
    );
  }

  Widget _iconButton(IconData icon, {String? badge}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        if (badge != null)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Center(
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDarkMode ? Colors.transparent : AppTheme.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
                size: 22,
              ),
              const Spacer(),
              Text(
                AppLocalizations.of(context).translate('search_hint'),
                style: TextStyle(
                  color: isDarkMode
                      ? AppTheme.textSecondary.withValues(alpha: 0.6)
                      : AppTheme.textLight,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          reverse: _isArabic(),
          itemCount: _categoryKeys.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final categoryId = index + 1;
            final categoryName = AppLocalizations.of(
              context,
            ).translate(_categoryKeys[index]);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryProductsPage(
                      categoryId: categoryId,
                      categoryName: categoryName,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode ? Colors.transparent : AppTheme.border,
                  ),
                ),
                child: Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppTheme.textSecondary
                        : AppTheme.textGrey,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _refreshHomeData,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: Text(
              AppLocalizations.of(context).translate('view_all'),
              style: TextStyle(
                color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            AppLocalizations.of(context).translate('featured_products'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSliver(bool isDarkMode) {
    return Obx(() {
      if (_productController.isLoading.value &&
          _productController.products.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (_productController.errorMessage.value.isNotEmpty &&
          _productController.products.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: _buildErrorState(isDarkMode),
          ),
        );
      }

      if (_productController.products.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: _buildEmptyState(isDarkMode),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = _productController.products[index];
            return _buildProductCard(product, isDarkMode);
          }, childCount: _productController.products.length),
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
      if (!_productController.isLoadingMore.value) {
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
            _productController.errorMessage.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _refreshHomeData,
            style: ElevatedButton.styleFrom(
              backgroundColor: activePrimary,
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
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
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
            'لا توجد منتجات حالياً',
            style: TextStyle(
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'اسحب للأسفل لتحديث القائمة',
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
                            if (_isBuyer)
                              Obx(() {
                                final bool isAddingThisProduct =
                                    _customerController
                                        .isAddingCartItem
                                        .value &&
                                    _customerController
                                            .addingCartProductId
                                            .value ==
                                        product.id;

                                return GestureDetector(
                                  onTap: isAddingThisProduct
                                      ? null
                                      : () async {
                                          await _addProductToCart(product);
                                        },
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? AppTheme.selectedBorder
                                          : AppTheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: isAddingThisProduct
                                        ? const Padding(
                                            padding: EdgeInsets.all(7),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
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
                                );
                              })
                            else
                              const SizedBox(width: 28, height: 28),
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
            if (_isBuyer)
              Positioned(
                top: 8,
                left: 8,
                child: Obx(() {
                  final bool isFavorite = _customerController.isFavorite(
                    product.id,
                  );

                  final bool isChangingThisFavorite =
                      _customerController.isChangingFavorite.value &&
                      _customerController.changingFavoriteProductId.value ==
                          product.id;

                  return GestureDetector(
                    onTap: isChangingThisFavorite
                        ? null
                        : () async {
                            await _toggleFavorite(product);
                          },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppTheme.inputFieldBg
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: isChangingThisFavorite
                          ? const Padding(
                              padding: EdgeInsets.all(7),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                              size: 14,
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

  Widget _buildBottomNav(bool isDarkMode) {
    final List<Map<String, dynamic>> buyerItems = [
      {
        'icon': Icons.store_outlined,
        'activeIcon': Icons.store,
        'labelKey': 'nav_store',
      },
      {
        'icon': Icons.favorite_border,
        'activeIcon': Icons.favorite,
        'labelKey': 'nav_favorites',
      },
      {
        'icon': Icons.receipt_long_outlined,
        'activeIcon': Icons.receipt_long,
        'labelKey': 'nav_orders',
      },
      {
        'icon': Icons.settings_outlined,
        'activeIcon': Icons.settings,
        'labelKey': 'nav_profile',
      },
    ];

    final List<Map<String, dynamic>> sellerItems = [
      {
        'icon': Icons.store_outlined,
        'activeIcon': Icons.store,
        'labelKey': 'nav_store',
      },
      {
        'icon': Icons.inventory_2_outlined,
        'activeIcon': Icons.inventory_2,
        'labelKey': 'nav_products',
      },
      {
        'icon': Icons.receipt_long_outlined,
        'activeIcon': Icons.receipt_long,
        'labelKey': 'nav_orders',
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'activeIcon': Icons.account_balance_wallet,
        'labelKey': 'nav_balance',
      },
      {
        'icon': Icons.settings_outlined,
        'activeIcon': Icons.settings,
        'labelKey': 'nav_profile',
      },
    ];

    final items = _isBuyer ? buyerItems : sellerItems;
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.topBottomBar : AppTheme.white,
        border: Border.all(
          color: isDarkMode
              ? AppTheme.inputFieldBg.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(items.length, (index) {
          final isActive = _currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () async {
                if (_isSeller) {
                  if (index == 0) {
                    setState(() => _currentIndex = index);
                    await _refreshHomeData();
                  } else if (index == 1) {
                    await _openMyProductsPage();
                  } else if (index == 2) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SellerOrdersPage(),
                      ),
                    );

                    if (!mounted) return;

                    await _refreshHomeData();
                  } else if (index == 3) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyBalancePage()),
                    );

                    if (!mounted) return;

                    await _refreshHomeData();
                  } else if (index == 4) {
                    await _openProfilePage();

                    if (!mounted) return;

                    await _refreshHomeData();
                  }
                } else {
                  if (index == 0) {
                    setState(() => _currentIndex = index);
                    await _refreshHomeData();
                  } else if (index == 1) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FavoritesPage(allProducts: _legacyProducts),
                      ),
                    );

                    if (!mounted) return;

                    await _refreshFavorites();
                  } else if (index == 2) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyOrdersPage()),
                    );
                  } else if (index == 3) {
                    await _openProfilePage();

                    if (!mounted) return;

                    await _refreshHomeData();
                  }
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 5 : 0,
                    height: isActive ? 5 : 0,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Icon(
                    isActive
                        ? items[index]['activeIcon'] as IconData
                        : items[index]['icon'] as IconData,
                    color: isActive
                        ? activeColor
                        : isDarkMode
                        ? AppTheme.textSecondary
                        : AppTheme.textLight,
                    size: 24,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).translate(items[index]['labelKey'].toString()),
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive
                          ? activeColor
                          : isDarkMode
                          ? AppTheme.textSecondary
                          : AppTheme.textLight,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  bool _isArabic() {
    return Localizations.localeOf(context).languageCode == 'ar';
  }
}
