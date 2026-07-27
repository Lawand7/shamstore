import 'package:flutter/material.dart';

import 'package:shamstore/screen/add_ad_page.dart';
import 'package:shamstore/screen/all_ads_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class HomeAdsSection extends StatelessWidget {
  const HomeAdsSection({super.key});

  static const List<Map<String, dynamic>> _ads = [
    {
      'title': 'Professional Photographer',
      'desc': 'Events & Weddings Photography',
      'city': 'Damascus',
      'icon': Icons.camera_alt_outlined,
      'color': Color(0xFF0F4C8A),
    },
    {
      'title': 'Private Tutor',
      'desc': 'Math & Physics',
      'city': 'Aleppo',
      'icon': Icons.school_outlined,
      'color': Color(0xFF059669),
    },
    {
      'title': 'Home Electrician',
      'desc': 'Maintenance & Installation',
      'city': 'Homs',
      'icon': Icons.electrical_services_outlined,
      'color': Color(0xFFF59E0B),
    },
    {
      'title': 'Furniture Moving',
      'desc': 'Affordable Prices',
      'city': 'Damascus',
      'icon': Icons.local_shipping_outlined,
      'color': Color(0xFF7C3AED),
    },
  ];

  bool _isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isArabic = _isArabic(context);
    final Color activePrimary = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AllAdsPage()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: Text(
                  AppLocalizations.of(context).translate('view_all'),
                  style: TextStyle(color: activePrimary, fontSize: 12),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: activePrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: activePrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: activePrimary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context).translate('add'),
                        style: TextStyle(
                          color: activePrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                AppLocalizations.of(context).translate('service_ads'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            reverse: isArabic,
            itemCount: _ads.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final ad = _ads[index];
              final Color originalAdColor = ad['color'] as Color;
              final Color adFinalColor = isDarkMode
                  ? Color.lerp(originalAdColor, Colors.white, 0.35)!
                  : originalAdColor;

              return Container(
                width: 190,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDarkMode ? Colors.transparent : AppTheme.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDarkMode ? 0.15 : 0.05,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isArabic
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ad['title'].toString(),
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
                          const SizedBox(height: 4),
                          Text(
                            ad['desc'].toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode
                                  ? AppTheme.textSecondary
                                  : AppTheme.textGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: isArabic
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!isArabic)
                                Icon(
                                  Icons.location_on,
                                  size: 11,
                                  color: adFinalColor,
                                ),
                              Text(
                                ad['city'].toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: adFinalColor,
                                ),
                              ),
                              if (isArabic)
                                Icon(
                                  Icons.location_on,
                                  size: 11,
                                  color: adFinalColor,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: adFinalColor.withValues(
                          alpha: isDarkMode ? 0.18 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        ad['icon'] as IconData,
                        color: adFinalColor,
                        size: 22,
                      ),
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
}
