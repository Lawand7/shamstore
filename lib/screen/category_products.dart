import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/notifications_page.dart';
import 'package:shamstore/utils/app_localizations.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryProductsScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate(categoryName),
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.white),
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
                  AppLocalizations.of(context).translate(categoryName),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                ),
                Text(
                  AppLocalizations.of(context).translate('Available products in section'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCategoryIcon(categoryName),
                            size: 60,
                            color: activeColor.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ')',
                              style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                            ),
                            Text(
                              AppLocalizations.of(context).translate(categoryName),
                              style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                            ),
                            Text(
                              ' ( ',
                              style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                            ),
                            Text(
                              AppLocalizations.of(context).translate('Featured Demo Product'),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.of(context).translate('This product is currently available for demo display inside the section at a competitive price'),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context).translate('SYP'),
                              style: TextStyle(fontSize: 12, color: activeColor, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '150,000',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: activeColor),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),
            Center(
              child: Text(
                AppLocalizations.of(context).translate('More products will be listed soon...'),
                style: TextStyle(
                  color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name) {
      case 'ملابس': return Icons.checkroom_rounded;
      case 'أحذية': return Icons.ice_skating_rounded;
      case 'كتب': return Icons.menu_book_rounded;
      case 'إلكترونيات': return Icons.devices_rounded;
      case 'رياضة': return Icons.sports_basketball_rounded;
      case 'أثاث': return Icons.chair_rounded;
      case 'مستلزمات مدرسية': return Icons.school_rounded;
      case 'مستحضرات تجميل': return Icons.face_retouching_natural_rounded;
      case 'أدوات منزلية': return Icons.blender_rounded;
      case 'ألعاب': return Icons.videogame_asset_rounded;
      default: return Icons.shopping_bag_outlined;
    }
  }
}