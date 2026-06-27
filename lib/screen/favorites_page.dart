import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/home_page.dart';

class FavoritesPage extends StatefulWidget {
  final List<Map<String, dynamic>> allProducts; // استقبال البيانات من الهوم بيج

  const FavoritesPage({super.key, required this.allProducts});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    // 💡 فحص حالة الدارك مود الحالية بالتطبيق ديناميكياً
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    // تصفية وعرض المنتجات المفضلة فقط التي تساوي true
    final favoriteProducts = widget.allProducts.where((p) => p['fav'] == true).toList();

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'المفضلة',
          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: favoriteProducts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 60, color: isDarkMode ? AppTheme.textSecondary.withOpacity(0.4) : AppTheme.textLight.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'قائمة المفضلة فارغة',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              'اضغط على زر القلب في الصفحة الرئيسية لإضافة المنتجات',
              style: TextStyle(fontSize: 11, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: favoriteProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            final product = favoriteProducts[index];
            return Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Container(
                          height: 110, width: double.infinity,
                          color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background.withOpacity(0.5),
                          child: Icon(product['icon'], size: 56, color: activeColor.withOpacity(0.6)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              product['name'],
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  product['city'],
                                  style: TextStyle(fontSize: 10, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                                ),
                                const SizedBox(width: 2),
                                Icon(Icons.location_on, size: 11, color: activeColor),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.add_shopping_cart, color: activeColor, size: 18),
                                Text(
                                  product['price'],
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: activeColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // عند الضغط على القلب الأحمر داخل المفضلة يتم إزالتها وتحديث الصفحة فوراً
                  Positioned(
                    top: 8, left: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          product['fav'] = false;
                        });
                      },
                      child: Container(
                        width: 30, height: 30,
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
                        child: const Icon(Icons.favorite, color: Colors.red, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}