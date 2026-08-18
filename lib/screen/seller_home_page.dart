import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/core/constants/api_constants.dart';
import 'package:shamstore/core/storage/token_storage.dart';
import 'package:shamstore/features/notifications/controllers/notifications_controller.dart';
import 'package:shamstore/features/products/models/product_model.dart';
import 'package:shamstore/features/seller/controllers/seller_product_controller.dart';
import 'package:shamstore/screen/enter_pin_screen.dart';
import 'package:shamstore/screen/my_products_page.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/screen/profile_page.dart';
import 'package:shamstore/screen/seller_orders_page.dart';
import 'package:shamstore/screen/widgets/exit_confirmation_scope.dart';
import 'package:shamstore/screen/widgets/home_ads_section.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  int _currentIndex = 0;

  late final SellerProductController _sellerProductController;
  late final NotificationsController _notificationsController;

  final ScrollController _scrollController = ScrollController();

  bool _isArabic() {
    return Localizations.localeOf(context).languageCode == 'ar';
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

  List<ProductModel> get _publishedProducts {
    return _sellerProductController.myActiveProducts
        .map(ProductModel.fromJson)
        .where((product) => product.isActive)
        .toList();
  }

  @override
  void initState() {
    super.initState();

    _sellerProductController = Get.isRegistered<SellerProductController>()
        ? Get.find<SellerProductController>()
        : Get.put(SellerProductController());
    _notificationsController = Get.isRegistered<NotificationsController>()
        ? Get.find<NotificationsController>()
        : Get.put(NotificationsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _sellerProductController.fetchMyActiveProducts(),
      _notificationsController.refreshNotifications(),
    ]);
  }

  Future<void> _openManageProducts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyProductsPage()),
    );

    if (mounted) {
      await _refreshData();
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );

    if (mounted) {
      await _notificationsController.refreshNotifications();
    }
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage(isBuyer: false)),
    );

    if (mounted) {
      setState(() {});
    }
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
            onRefresh: _refreshData,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildTopBar(isDarkMode)),
                const SliverToBoxAdapter(child: HomeAdsSection()),
                SliverToBoxAdapter(child: _buildProductsHeader(isDarkMode)),
                _buildProductsSliver(isDarkMode),
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
          GestureDetector(
            onTap: _openNotifications,
            child: Obx(() {
              final int unreadCount = _notificationsController.unreadCount;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  _iconButton(Icons.notifications_none_outlined),
                  if (unreadCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
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
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EnterPinScreen(isBuyer: false),
                ),
              );
            },
            child: _iconButton(Icons.credit_card_outlined),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.of(context).translate('seller_dashboard'),
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
            onTap: _openProfile,
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

  Widget _iconButton(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildProfileAvatar() {
    final imageUrl = _profileImageUrl;

    if (imageUrl.isEmpty) {
      return const Icon(Icons.person, color: Colors.white, size: 20);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return const Icon(Icons.person, color: Colors.white, size: 20);
      },
    );
  }

  Widget _buildProductsHeader(bool isDarkMode) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _openManageProducts,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: Text(
              AppLocalizations.of(context).translate('manage_products'),
              style: TextStyle(color: activeColor, fontSize: 12),
            ),
          ),
          Text(
            AppLocalizations.of(context).translate('published_products'),
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
      final controller = _sellerProductController;

      if (controller.isLoadingActiveProducts.value &&
          controller.myActiveProducts.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (controller.activeProductsErrorMessage.value.isNotEmpty &&
          controller.myActiveProducts.isEmpty) {
        return SliverToBoxAdapter(
          child: _buildMessageState(
            isDarkMode,
            icon: Icons.error_outline_rounded,
            message: controller.activeProductsErrorMessage.value,
            actionLabel: AppLocalizations.of(context).translate('retry'),
            onAction: _refreshData,
          ),
        );
      }

      final products = _publishedProducts;

      if (products.isEmpty) {
        return SliverToBoxAdapter(
          child: _buildMessageState(
            isDarkMode,
            icon: Icons.inventory_2_outlined,
            message: AppLocalizations.of(
              context,
            ).translate('no_published_products'),
            actionLabel: AppLocalizations.of(
              context,
            ).translate('manage_products'),
            onAction: _openManageProducts,
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildProductCard(products[index], isDarkMode),
            childCount: products.length,
          ),
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

  Widget _buildMessageState(
    bool isDarkMode, {
    required IconData icon,
    required String message,
    required String actionLabel,
    required Future<void> Function() onAction,
  }) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
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
            Icon(icon, color: activeColor, size: 38),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: activeColor,
                elevation: 0,
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, bool isDarkMode) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;
    final bool isArabic = _isArabic();

    return GestureDetector(
      onTap: _openManageProducts,
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
        child: Column(
          crossAxisAlignment: isArabic
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
                child: _buildProductImage(product),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: isArabic
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? AppTheme.textPrimary
                            : AppTheme.textDark,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: isArabic
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isArabic)
                          Icon(Icons.location_on, size: 11, color: activeColor),
                        Expanded(
                          child: Text(
                            product.governorate.isNotEmpty
                                ? product.governorate
                                : AppLocalizations.of(
                                    context,
                                  ).translate('not_available'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: isArabic
                                ? TextAlign.right
                                : TextAlign.left,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode
                                  ? AppTheme.textSecondary
                                  : AppTheme.textLight,
                            ),
                          ),
                        ),
                        if (isArabic)
                          Icon(Icons.location_on, size: 11, color: activeColor),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.quantity} ${AppLocalizations.of(context).translate('available_quantity')}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_formatPrice(product.price)} ${AppLocalizations.of(context).translate('currency')}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: activeColor,
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

  Widget _buildProductImage(ProductModel product) {
    if (product.fullImageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.image_outlined, color: AppTheme.textLight, size: 34),
      );
    }

    return Image.network(
      product.fullImageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return const Center(
          child: Icon(Icons.broken_image_outlined, color: AppTheme.textLight),
        );
      },
    );
  }

  Widget _buildBottomNav(bool isDarkMode) {
    final items = [
      (Icons.store_outlined, Icons.store, 'nav_store'),
      (Icons.inventory_2_outlined, Icons.inventory_2, 'manage_products'),
      (Icons.receipt_long_outlined, Icons.receipt_long, 'nav_orders'),
      (Icons.settings_outlined, Icons.settings, 'nav_profile'),
    ];
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;
    final Color inactiveColor = isDarkMode
        ? AppTheme.textSecondary
        : AppTheme.textLight;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.topBottomBar : AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool isActive = _currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () async {
                if (index == 0) {
                  await _refreshData();
                } else if (index == 1) {
                  await _openManageProducts();
                } else if (index == 2) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SellerOrdersPage()),
                  );
                  if (mounted) await _refreshData();
                } else {
                  await _openProfile();
                  if (mounted) await _refreshData();
                }

                if (mounted && _currentIndex != 0) {
                  setState(() => _currentIndex = 0);
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
                    isActive ? item.$2 : item.$1,
                    color: isActive ? activeColor : inactiveColor,
                    size: 23,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).translate(item.$3),
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? activeColor : inactiveColor,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}
