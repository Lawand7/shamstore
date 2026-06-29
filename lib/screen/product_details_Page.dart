import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final Color activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;
    final Color activeTextDark = isDarkMode ? AppTheme.textPrimary : AppTheme.textDark;

    final String sellerName = product['sellerName'] ??
        (product['name'].toString().contains('حذاء') ? 'لاوند سبانوتي' : 'أغيد الخطيب');

    final double sellerRating = product['sellerRating'] ??
        (product['name'].toString().contains('حذاء') ? 4.8 : 4.9);

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('Product Details'),
          style: const TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_back_ios_rounded : Icons.arrow_back_ios_new_rounded,
            color: AppTheme.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: isDarkMode ? AppTheme.darkBackground : AppTheme.white,
              child: Center(
                child: Icon(
                  product['icon'],
                  size: 110,
                  color: activePrimary.withOpacity(isDarkMode ? 0.85 : 0.7),
                ),
              ),
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: Border.all(color: isDarkMode ? AppTheme.inputFieldBg.withOpacity(0.5) : Colors.transparent),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: activeTextDark),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: isArabic
                      ? [
                    Text(AppLocalizations.of(context).translate('SP'), style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 4),
                    Text(product['price'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: activePrimary)),
                  ]
                      : [
                    Text(product['price'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: activePrimary)),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context).translate('SP'), style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),

                Divider(color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: isArabic
                      ? [
                    Row(
                      children: [
                        Text(
                            sellerName,
                            style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w500)
                        ),
                        const SizedBox(width: 6),
                        Text(
                            sellerRating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange)
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                      ],
                    ),
                    Row(
                      children: [
                        Text(product['city'], style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey, fontSize: 13)),
                        const SizedBox(width: 4),
                        Icon(Icons.location_on, color: activePrimary, size: 16),
                      ],
                    ),
                  ]
                      : [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: activePrimary, size: 16),
                        const SizedBox(width: 4),
                        Text(product['city'], style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey, fontSize: 13)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                            sellerRating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange)
                        ),
                        const SizedBox(width: 6),
                        Text(
                            sellerName,
                            style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w500)
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context).translate('Description Title'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: activeTextDark),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context).translate('Product Description Body'),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey, height: 1.5),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      String successMsg = AppLocalizations.of(context).translate('Added to cart successfully message');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('${product['name']} $successMsg', textAlign: isArabic ? TextAlign.right : TextAlign.left),
                            backgroundColor: Colors.green
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 18),
                    label: Text(
                      AppLocalizations.of(context).translate('Add to Cart Button'),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}