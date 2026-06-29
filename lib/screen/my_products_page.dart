import 'package:flutter/material.dart';
import 'package:shamstore/screen/add_product_page.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class MyProductsPage extends StatefulWidget {
  final dynamic product;

  const MyProductsPage({super.key, required this.product});
  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  String _selectedTab = 'الكل';

  final List<String> _tabs = ['الكل', 'منشور', 'غير منشور'];

  final List<Map<String, dynamic>> _products = [
    {'name': 'جاكيت رجالي أنيق', 'price': '349', 'icon': Icons.checkroom, 'status': 'منشور', 'date': '12 مايو 2026', 'sold': 8},
    {'name': 'سماعات لاسلكية', 'price': '199', 'icon': Icons.headphones, 'status': 'منشور', 'date': '11 مايو 2026', 'sold': 15},
    {'name': 'حذاء جري رياضي', 'price': '299', 'icon': Icons.directions_run, 'status': 'غير منشور', 'date': '10 مايو 2026', 'sold': 0},
    {'name': 'فستان نسائي ناعم', 'price': '450', 'icon': Icons.dry_cleaning, 'status': 'غير منشور', 'date': '9 مايو 2026', 'sold': 0},
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedTab == 'الكل') return _products;
    return _products.where((p) => p['status'] == _selectedTab).toList();
  }

  int get _publishedCount => _products.where((p) => p['status'] == 'منشور').length;
  int get _unpublishedCount => _products.where((p) => p['status'] == 'غير منشور').length;
  int get _soldCount => _products.fold(0, (sum, p) => sum + (p['sold'] as int));

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('My Products'),
          style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductPage()),
            ),
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
      body: Column(
        children: [
          _buildStats(context, isDarkMode),
          _buildTabs(context, isDarkMode),
          Expanded(child: _buildProductsList(context, isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _statCard('$_publishedCount', AppLocalizations.of(context).translate('Published Stat'), isDarkMode),
          const SizedBox(width: 8),
          _statCard('$_unpublishedCount', AppLocalizations.of(context).translate('Unpublished Stat'), isDarkMode),
          const SizedBox(width: 8),
          _statCard('$_soldCount', AppLocalizations.of(context).translate('Sold Stat'), isDarkMode),
        ],
      ),
    );
  }

  Widget _statCard(String num, String label, bool isDarkMode) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(
              num,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
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
          final isSelected = tab == _selectedTab;

          String displayLabel = '';
          if (tab == 'الكل') displayLabel = AppLocalizations.of(context).translate('All Tab');
          if (tab == 'منشور') displayLabel = AppLocalizations.of(context).translate('Published Tab');
          if (tab == 'غير منشور') displayLabel = AppLocalizations.of(context).translate('Unpublished Tab');

          // ضبط خلفية التبويبات حسب حالة التحديد والثيم الداكن للفصل بين العناصر بصرياً
          final Color activeTabBg = isDarkMode ? AppTheme.selectedBorder : AppTheme.primary;
          final Color inactiveTabBg = isDarkMode ? AppTheme.darkBackground : AppTheme.background;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
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
                        ? (isDarkMode ? AppTheme.darkBackground : AppTheme.white)
                        : (isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).translate('No products found'),
              style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(context, products[index], isDarkMode),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product, bool isDarkMode) {
    final isPublished = product['status'] == 'منشور';
    final Color activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    final Color greenColor = isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669);
    final Color redColor = isDarkMode ? const Color(0xFFF87171) : const Color(0xFFEF4444);
    final Color hideColor = isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(product['icon'], size: 30, color: activePrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: _isArabic() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product['date'],
                      style: TextStyle(fontSize: 10, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${product['price']} ${AppLocalizations.of(context).translate('SP')}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: activePrimary),
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
                          ? AppLocalizations.of(context).translate('Published Badge')
                          : AppLocalizations.of(context).translate('Unpublished Badge'),
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: isPublished ? greenColor : redColor),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      isPublished ? Icons.check_circle_outline : Icons.access_time,
                      size: 11,
                      color: isPublished ? greenColor : redColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionBtn(
                AppLocalizations.of(context).translate('Delete Action'),
                Icons.delete_outline,
                redColor,
                    () {},
              ),
              const SizedBox(width: 8),
              _actionBtn(
                AppLocalizations.of(context).translate('Edit Action'),
                Icons.edit_outlined,
                activePrimary,
                    () {},
              ),
              const SizedBox(width: 8),
              _actionBtn(
                isPublished
                    ? AppLocalizations.of(context).translate('Hide Action')
                    : AppLocalizations.of(context).translate('Publish Action'),
                isPublished ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                isPublished ? hideColor : greenColor,
                    () {
                  setState(() {
                    product['status'] = isPublished ? 'غير منشور' : 'منشور';
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
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
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(icon, size: 13, color: color),
          ],
        ),
      ),
    );
  }

  bool _isArabic() => Localizations.localeOf(context).languageCode == 'ar';
}