import 'package:flutter/material.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/screen/profile_page.dart';
import 'package:shamstore/screen/myorder_page.dart';
import 'package:shamstore/screen/favorites_page.dart';
import 'package:shamstore/screen/search_page.dart';
import 'package:shamstore/screen/my_products_page.dart';
import 'package:shamstore/screen/my_balanc_page.dart';
import 'package:shamstore/screen/cart_page.dart';
import 'package:shamstore/screen/wallet_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/product_details_Page.dart';
import 'package:shamstore/screen/enter_pin_screen.dart';
import 'package:shamstore/screen/add_ad_page.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/screen/all_ads_page.dart';

class HomePage extends StatefulWidget {
  final bool isBuyer;
  const HomePage({super.key, this.isBuyer = true });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<String> _categoryKeys = [
    'cat_electronics', 'cat_clothing', 'cat_shoes', 'cat_books', 'cat_furniture', 'cat_sports'
  ];

  // البيانات التجريبية بقيت كما هي ويُفضل مستقبلاً جلبها من الـ API لتكون مترجمة تلقائياً
  final List<Map<String, dynamic>> _ads = [
    {'title': 'Professional Photographer', 'desc': 'Events & Weddings Photography', 'city': 'Damascus', 'icon': Icons.camera_alt_outlined, 'color': const Color(0xFF0F4C8A)},
    {'title': 'Private Tutor', 'desc': 'Math & Physics', 'city': 'Aleppo', 'icon': Icons.school_outlined, 'color': const Color(0xFF059669)},
    { 'title': 'Home Electrician', 'desc': 'Maintenance & Installation', 'city': 'Homs', 'icon': Icons.electrical_services_outlined, 'color': const Color(0xFFF59E0B)},
    {'title': 'Furniture Moving', 'desc': 'Affordable Prices', 'city': 'Damascus', 'icon': Icons.local_shipping_outlined, 'color': const Color(0xFF7C3AED)},
  ];

  final List<Map<String, dynamic>> _products = [
    {'name': 'Sports Running Shoes', 'city': 'Damascus', 'price': '299', 'icon': Icons.directions_run, 'fav': false, 'rating': 4.5, 'sold': 120},
    {'name': 'Elegant Men Jacket', 'city': 'Damascus', 'price': '349', 'icon': Icons.checkroom, 'fav': true, 'rating': 4.8, 'sold': 85},
    {'name': 'Soft Women Dress', 'city': 'Aleppo', 'price': '450', 'icon': Icons.dry_cleaning, 'fav': false, 'rating': 4.2, 'sold': 60},
    {'name': 'Wireless Headphones', 'city': 'Homs', 'price': '199', 'icon': Icons.headphones, 'fav': false, 'rating': 4.7, 'sold': 200},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildTopBar(isDarkMode)),
                SliverToBoxAdapter(child: _buildSearchBar(isDarkMode)),
                SliverToBoxAdapter(child: _buildAdsSection(isDarkMode)),
                SliverToBoxAdapter(child: _buildCategories(isDarkMode)),
                SliverToBoxAdapter(child: _buildSectionHeader(isDarkMode)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildProductCard(index, isDarkMode),
                      childCount: _products.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDarkMode),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsPage()),
                  );
                },
                child: _iconButton(Icons.notifications_none_outlined, badge: '3'),
              ),
              const SizedBox(width: 8),
              widget.isBuyer
                  ? GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                    ),
                    Positioned(
                      top: -4, right: -4,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                        child: const Center(child: Text('2', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink(),

              widget.isBuyer ? const SizedBox(width: 8) : const SizedBox.shrink(),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EnterPinScreen(isBuyer: widget.isBuyer),
                    ),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.credit_card_outlined, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                !widget.isBuyer
                    ? AppLocalizations.of(context).translate('seller_dashboard')
                    : AppLocalizations.of(context).translate('hello'),
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
              ),
              Text(
                  AppLocalizations.of(context).translate('user_name'),
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)
              ),
            ],
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfilePage(isBuyer: widget.isBuyer)),
            ),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, {String? badge}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        if (badge != null)
          Positioned(
            top: -4, right: -4,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              child: Center(child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, size: 22),
              const Spacer(),
              Text(
                AppLocalizations.of(context).translate('search_hint'),
                style: TextStyle(color: isDarkMode ? AppTheme.textSecondary.withOpacity(0.6) : AppTheme.textLight, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdsSection(bool isDarkMode) {
    final Color activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AllAdsPage()),
                  );
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: Text(
                    AppLocalizations.of(context).translate('view_all'),
                    style: TextStyle(color: activePrimary, fontSize: 12)
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddAdPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: activePrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: activePrimary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: activePrimary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context).translate('add'),
                        style: TextStyle(color: activePrimary, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                AppLocalizations.of(context).translate('service_ads'),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            reverse: _isArabic(),
            itemCount: _ads.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final ad = _ads[index];
              final Color originalAdColor = ad['color'] as Color;
              final Color adFinalColor = isDarkMode ? Color.lerp(originalAdColor, Colors.white, 0.35)! : originalAdColor;

              return Container(
                width: 190,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.05), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: _isArabic() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ad['title'],
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ad['desc'],
                            style: TextStyle(fontSize: 10, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: _isArabic() ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              if (!_isArabic()) Icon(Icons.location_on, size: 11, color: adFinalColor),
                              Text(ad['city'], style: TextStyle(fontSize: 10, color: adFinalColor)),
                              if (_isArabic()) Icon(Icons.location_on, size: 11, color: adFinalColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: adFinalColor.withOpacity(isDarkMode ? 0.18 : 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(ad['icon'], color: adFinalColor, size: 22),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
                ),
                child: Text(
                  AppLocalizations.of(context).translate(_categoryKeys[index]),
                  style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
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
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
            child: Text(
                AppLocalizations.of(context).translate('view_all'),
                style: TextStyle(color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, fontSize: 12)
            ),
          ),
          Text(
            AppLocalizations.of(context).translate('featured_products'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(int index, bool isDarkMode) {
    final product = _products[index];
    final Color activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductDetailsPage(product: product)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDarkMode ? AppTheme.inputFieldBg.withOpacity(0.5) : Colors.transparent),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.06), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: _isArabic() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      height: 95,
                      width: double.infinity,
                      color: isDarkMode ? AppTheme.darkBackground : AppTheme.background.withOpacity(0.5),
                      child: Icon(product['icon'], size: 48, color: activePrimary.withOpacity(isDarkMode ? 0.85 : 0.6)),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      child: Column(
                        crossAxisAlignment: _isArabic() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product['name'],
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          Row(
                            mainAxisAlignment: _isArabic() ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              if (!_isArabic()) Icon(Icons.location_on, size: 11, color: activePrimary),
                              Expanded(
                                child: Text(
                                  product['city'],
                                  style: TextStyle(fontSize: 10, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: _isArabic() ? TextAlign.right : TextAlign.left,
                                ),
                              ),
                              if (_isArabic()) Icon(Icons.location_on, size: 11, color: activePrimary),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: _isArabic() ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              if (!_isArabic()) const Icon(Icons.star, size: 11, color: Colors.orange),
                              if (!_isArabic()) const SizedBox(width: 3),

                              Text(
                                  product['sellerRating'].toString(),
                                  style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w600)
                              ),
                              const SizedBox(width: 5),

                              Expanded(
                                child: Text(
                                  product['sellerName'] ?? '',
                                  style: TextStyle(fontSize: 10, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: _isArabic() ? TextAlign.right : TextAlign.left,
                                ),
                              ),

                              if (_isArabic()) const SizedBox(width: 3),
                              if (_isArabic()) const Icon(Icons.star, size: 11, color: Colors.orange),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.add_shopping_cart,
                                    color: isDarkMode ? AppTheme.darkBackground : Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  if (!_isArabic()) Text(product['price'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: activePrimary)),
                                  Text(' ${AppLocalizations.of(context).translate('currency')} ', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  if (_isArabic()) Text(product['price'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: activePrimary)),
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
                top: 8, left: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _products[index]['fav'] = !_products[index]['fav']),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppTheme.inputFieldBg : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                    ),
                    child: Icon(product['fav'] ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 14),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildBottomNav(bool isDarkMode) {
    final List<Map<String, dynamic>> buyerItems = [
      {'icon': Icons.store_outlined, 'activeIcon': Icons.store, 'labelKey': 'nav_store'},
      {'icon': Icons.favorite_border, 'activeIcon': Icons.favorite, 'labelKey': 'nav_favorites'},
      {'icon': Icons.receipt_long_outlined, 'activeIcon': Icons.receipt_long, 'labelKey': 'nav_orders'},
      {'icon': Icons.settings_outlined, 'activeIcon': Icons.settings, 'labelKey': 'nav_profile'},
    ];

    final List<Map<String, dynamic>> sellerItems = [
      {'icon': Icons.store_outlined, 'activeIcon': Icons.store, 'labelKey': 'nav_store'},
      {'icon': Icons.inventory_2_outlined, 'activeIcon': Icons.inventory_2, 'labelKey': 'nav_products'},
      {'icon': Icons.account_balance_wallet_outlined, 'activeIcon': Icons.account_balance_wallet, 'labelKey': 'nav_balance'},
      {'icon': Icons.settings_outlined, 'activeIcon': Icons.settings, 'labelKey': 'nav_profile'},
    ];

    final items = widget.isBuyer ? buyerItems : sellerItems;
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.topBottomBar : AppTheme.white,
        border: Border.all(color: isDarkMode ? AppTheme.inputFieldBg.withOpacity(0.5) : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(items.length, (index) {
          final isActive = _currentIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!widget.isBuyer) {
                  if (index == 0) {
                    setState(() => _currentIndex = index);
                  } else if (index == 1) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MyProductsPage(product: _products)));
                  } else if (index == 2) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBalancePage()));
                  } else if (index == 3) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(isBuyer: widget.isBuyer)));
                  }
                } else {
                  if (index == 0) {
                    setState(() => _currentIndex = index);
                  } else if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FavoritesPage(allProducts: _products)),
                    ).then((_) => setState(() {}));
                  } else if (index == 2) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersPage()));
                  } else if (index == 3) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(isBuyer: widget.isBuyer)));
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
                    decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(height: 3),
                  Icon(
                    isActive ? items[index]['activeIcon'] : items[index]['icon'],
                    color: isActive ? activeColor : (isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                    size: 24,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppLocalizations.of(context).translate(items[index]['labelKey']),
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? activeColor : (isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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

  bool _isArabic() => Localizations.localeOf(context).languageCode == 'ar';
}