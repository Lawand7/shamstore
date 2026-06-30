import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/category_products.dart';
import 'package:shamstore/utils/app_localizations.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // متغيرات الفلترة والبحث
  String _searchQuery = '';
  double? _minPrice;
  double? _maxPrice;
  String _selectedGovernorate = 'الكل';

  final List<String> _governorates = [
    'الكل', 'Damascus', 'Aleppo', 'Homs', 'Hama', 'Latakia',
    'Tartus', 'Deir ez-Zor', 'Al-Hasakah', 'Raqqa',
    'Daraa', 'Sweida', 'Quneitra', 'Idlib',
  ];

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

  // دالة لفتح نافذة الفلترة المنبثقة (BottomSheet)
  void _showFilterBottomSheet(bool isDarkMode) {
    final minController = TextEditingController(text: _minPrice?.toString() ?? '');
    final maxController = TextEditingController(text: _maxPrice?.toString() ?? '');
    String tempGov = _selectedGovernorate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppTheme.cardBackground : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20, left: 20, right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).translate('Filter Title'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                  ),
                  const SizedBox(height: 20),

                  // فلتر السعر (تقريبي حد أدنى وأعلى)
                  Text(
                    AppLocalizations.of(context).translate('Price Range Label'),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _dialogField(minController, AppLocalizations.of(context).translate('Min Price Hint'), isDarkMode),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dialogField(maxController, AppLocalizations.of(context).translate('Max Price Hint'), isDarkMode),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // فلتر المحافظة
                  Text(
                    AppLocalizations.of(context).translate('Governorate'),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempGov,
                    dropdownColor: isDarkMode ? AppTheme.cardBackground : Colors.white,
                    style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: _governorates.map((gov) => DropdownMenuItem(
                      value: gov,
                      child: Text(gov == 'الكل' ? AppLocalizations.of(context).translate('All Tab') : AppLocalizations.of(context).translate(gov)),
                    )).toList(),
                    onChanged: (val) => setModalState(() => tempGov = val!),
                  ),
                  const SizedBox(height: 24),

                  // أزرار التحكم بالفلتر
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _minPrice = null;
                              _maxPrice = null;
                              _selectedGovernorate = 'الكل';
                            });
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context).translate('Reset Filter'), style: const TextStyle(color: AppTheme.error)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _minPrice = double.tryParse(minController.text);
                              _maxPrice = double.tryParse(maxController.text);
                              _selectedGovernorate = tempGov;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocalizations.of(context).translate('Apply Filter'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _dialogField(TextEditingController controller, String hint, bool isDarkMode) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDarkMode ? AppTheme.textSecondary.withOpacity(0.5) : AppTheme.textLight, fontSize: 12),
        filled: true,
        fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

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
          // 🔍 شريط البحث + أيقونة الفلترة المتقدمة بجانبه
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
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
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showFilterBottomSheet(isDarkMode),
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
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

                // تصفية التصنيفات بناءً على نص البحث المكتوب إن وُجد
                if (_searchQuery.isNotEmpty && !displayCategoryName.toLowerCase().contains(_searchQuery.toLowerCase())) {
                  return const SizedBox.shrink();
                }

                final Color categoryColor = category['color'] as Color;
                final Color finalIconColor = isDarkMode ? Color.lerp(categoryColor, Colors.white, 0.3)! : categoryColor;

                return GestureDetector(
                  onTap: () {
                    final cleanedName = displayCategoryName.replaceAll('\n', ' ');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryProductsScreen(
                          categoryName: cleanedName,
                          searchQuery: _searchQuery,
                          minPrice: _minPrice,
                          maxPrice: _maxPrice,
                          governorate: _selectedGovernorate,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppTheme.cardBackground : Colors.white,
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