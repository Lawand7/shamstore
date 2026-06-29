import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/category_products.dart';
import 'package:shamstore/utils/app_localizations.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  final List<Map<String, dynamic>> _allCategories = const [
    {'name': 'ملابس', 'icon': Icons.checkroom_rounded, 'color': Color(0xFF0F4C8A)},
    {'name': 'أحذية', 'icon': Icons.ice_skating_rounded, 'color': Color(0xFFE11D48)},
    {'name': 'كتب', 'icon': Icons.menu_book_rounded, 'color': Color(0xFF059669)},
    {'name': 'إلكترونيات', 'icon': Icons.devices_rounded, 'color': Color(0xFF7C3AED)},
    {'name': 'رياضة', 'icon': Icons.sports_basketball_rounded, 'color': Color(0xFFD97706)},
    {'name': 'أثاث', 'icon': Icons.chair_rounded, 'color': Color(0xFF4B5563)},
    {'name': 'مستلزمات مدرسية', 'icon': Icons.school_rounded, 'color': Color(0xFF2563EB)},
    {'name': 'مستحضرات\nتجميل', 'icon': Icons.face_retouching_natural_rounded, 'color': Color(0xFFDB2777)},
    {'name': 'أدوات منزلية', 'icon': Icons.blender_rounded, 'color': Color(0xFF0D9488)},
    {'name': 'ألعاب', 'icon': Icons.videogame_asset_rounded, 'color': Color(0xFFEA580C)},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final Color activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).translate('Browse Categories'),
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_back_ios_rounded : Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('Search hint text'),
                hintStyle: TextStyle(color: isDarkMode ? AppTheme.textSecondary.withOpacity(0.5) : AppTheme.textLight, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: activePrimary),
                filled: true,
                fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, width: 1.5),
                ),
              ),
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
              ),
              itemCount: _allCategories.length,
              itemBuilder: (context, index) {
                final category = _allCategories[index];

                String displayCategoryName = category['name'];
                if (category['name'] == 'ملابس') displayCategoryName = AppLocalizations.of(context).translate('Clothes');
                if (category['name'] == 'أحذية') displayCategoryName = AppLocalizations.of(context).translate('Shoes');
                if (category['name'] == 'كتب') displayCategoryName = AppLocalizations.of(context).translate('Books');
                if (category['name'] == 'إلكترونيات') displayCategoryName = AppLocalizations.of(context).translate('Electronics');
                if (category['name'] == 'رياضة') displayCategoryName = AppLocalizations.of(context).translate('Sports');
                if (category['name'] == 'أثاث') displayCategoryName = AppLocalizations.of(context).translate('Furniture');
                if (category['name'] == 'مستلزمات مدرسية') displayCategoryName = AppLocalizations.of(context).translate('School Supplies');
                if (category['name'] == 'مستحضرات\nتجميل') displayCategoryName = AppLocalizations.of(context).translate('Cosmetics');
                if (category['name'] == 'أدوات منزلية') displayCategoryName = AppLocalizations.of(context).translate('Housewares');
                if (category['name'] == 'ألعاب') displayCategoryName = AppLocalizations.of(context).translate('Games');

                final Color categoryColor = category['color'] as Color;
                final Color finalIconColor = isDarkMode ? Color.lerp(categoryColor, Colors.white, 0.3)! : categoryColor;

                return GestureDetector(
                  onTap: () {
                    final cleanedName = displayCategoryName.replaceAll('\n', ' ');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryProductsScreen(categoryName: cleanedName),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: isArabic
                          ? [
                        Expanded(
                          child: Text(
                            displayCategoryName,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: finalIconColor.withOpacity(isDarkMode ? 0.18 : 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            category['icon'],
                            color: finalIconColor,
                            size: 22,
                          ),
                        ),
                      ]
                          : [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: finalIconColor.withOpacity(isDarkMode ? 0.18 : 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            category['icon'],
                            color: finalIconColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            displayCategoryName,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}