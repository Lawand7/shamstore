import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/utils/app_localizations.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;

  // 🔽 إضافة متغيرات الفلترة المستقبلة من واجهة البحث
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final String? governorate;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.governorate,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  // 📦 بيانات تجريبية للمنتجات تحتوي على الأقسام، الأسعار والمحافظات لاختبار الفلترة
  final List<Map<String, dynamic>> _demoProducts = [
    {
      'name': 'منتج مميز ملابس',
      'category': 'ملابس',
      'price': 150000.0,
      'gov': 'Damascus',
    },
    {
      'name': 'جاكيت شتوي فاخر',
      'category': 'ملابس',
      'price': 250000.0,
      'gov': 'Aleppo',
    },
    {
      'name': 'سماعات ذكية بريميوم',
      'category': 'إلكترونيات',
      'price': 450000.0,
      'gov': 'Damascus',
    },
    {
      'name': 'حذاء رياضي مريح',
      'category': 'أحذية',
      'price': 180000.0,
      'gov': 'Homs',
    },
    {
      'name': 'رواية مشوقة',
      'category': 'كتب',
      'price': 35000.0,
      'gov': 'Latakia',
    },
  ];

  // ⚙️ دالة معالجة وتطبيق الفلاتر ديناميكياً
  List<Map<String, dynamic>> get _filteredProducts {
    return _demoProducts.where((product) {
      // 1. الفرز حسب القسم الحالي
      final matchesCategory = product['category'] == widget.categoryName;

      // 2. الفرز حسب كلمة البحث إن وجدت
      final matchesSearch =
          widget.searchQuery == null ||
          widget.searchQuery!.isEmpty ||
          product['name'].toString().toLowerCase().contains(
            widget.searchQuery!.toLowerCase(),
          );

      // 3. الفرز حسب نطاق السعر (الحد الأدنى والأعلى)
      final matchesMinPrice =
          widget.minPrice == null || product['price'] >= widget.minPrice!;
      final matchesMaxPrice =
          widget.maxPrice == null || product['price'] <= widget.maxPrice!;

      // 4. الفرز حسب المحافظة
      final matchesGov =
          widget.governorate == 'الكل' ||
          widget.governorate == null ||
          product['gov'] == widget.governorate;

      return matchesCategory &&
          matchesSearch &&
          matchesMinPrice &&
          matchesMaxPrice &&
          matchesGov;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;
    final products = _filteredProducts; // جلب المنتجات المفلترة

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate(widget.categoryName),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  AppLocalizations.of(context).translate(widget.categoryName),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? AppTheme.textPrimary
                        : AppTheme.textDark,
                  ),
                ),
                Text(
                  AppLocalizations.of(
                    context,
                  ).translate('Available products in section'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? AppTheme.textPrimary
                        : AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // عرض المنتجات المفلترة أو رسالة فارغة في حال لم يطابق الفلتر أي منتج
            products.isEmpty
                ? Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).translate('No products found'),
                        style: TextStyle(
                          color: isDarkMode
                              ? AppTheme.textSecondary
                              : AppTheme.textGrey,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final item = products[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppTheme.cardBackground
                                : AppTheme.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.transparent
                                  : AppTheme.border,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDarkMode ? 0.15 : 0.04,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? AppTheme.inputFieldBg
                                      : AppTheme.background,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getCategoryIcon(widget.categoryName),
                                  size: 60,
                                  color: activeColor.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    ' )',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? AppTheme.textPrimary
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                  Text(
                                    item['name'],
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? AppTheme.textPrimary
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                  Text(
                                    ' ( ',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? AppTheme.textPrimary
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    ).translate('Featured Demo Product'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? AppTheme.textPrimary
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // عرض المحافظة الخاصة بالمنتج
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 12,
                                    color: isDarkMode
                                        ? AppTheme.textSecondary
                                        : AppTheme.textGrey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    ).translate(item['gov']),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDarkMode
                                          ? AppTheme.textSecondary
                                          : AppTheme.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppLocalizations.of(context).translate(
                                  'This product is currently available for demo display inside the section at a competitive price',
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDarkMode
                                      ? AppTheme.textSecondary
                                      : AppTheme.textGrey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    ).translate('SYP'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: activeColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['price']
                                        .toStringAsFixed(0)
                                        .replaceAllMapped(
                                          RegExp(
                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                          ),
                                          (Match m) => '${m[1]},',
                                        ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: activeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

            Center(
              child: Text(
                AppLocalizations.of(
                  context,
                ).translate('More products will be listed soon...'),
                style: TextStyle(
                  color: isDarkMode
                      ? AppTheme.textSecondary
                      : AppTheme.textLight,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name) {
      case 'ملابس':
        return Icons.checkroom_rounded;
      case 'أحذية':
        return Icons.ice_skating_rounded;
      case 'كتب':
        return Icons.menu_book_rounded;
      case 'إلكترونيات':
        return Icons.devices_rounded;
      case 'رياضة':
        return Icons.sports_basketball_rounded;
      case 'أثاث':
        return Icons.chair_rounded;
      case 'مستلزمات مدرسية':
        return Icons.school_rounded;
      case 'مستحضرات تجميل':
        return Icons.face_retouching_natural_rounded;
      case 'أدوات منزلية':
        return Icons.blender_rounded;
      case 'ألعاب':
        return Icons.videogame_asset_rounded;
      default:
        return Icons.shopping_bag_outlined;
    }
  }
}
