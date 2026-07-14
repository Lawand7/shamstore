import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class AllAdsPage extends StatelessWidget {
  const AllAdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> dummyAds = [
      {
        'title': 'صيانة غسالات وبرادات فورية',
        'gov': 'دمشق',
        'phone': '0912345678',
        'desc': 'خدمة صيانة منزلية سريعة لكافة أنواع الغسالات والبرادات بأيدي خبراء.'
      },
      {
        'title': 'دروس خصوصية رياضيات وفيزياء',
        'gov': 'حلب',
        'phone': '0987654321',
        'desc': 'مدرس خبرة 10 سنوات لطلاب الشهادتين الإعدادية والثانوية.'
      },
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('All Ads Title'),
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
      body: dummyAds.isEmpty
          ? Center(
        child: Text(
          AppLocalizations.of(context).translate('No ads available'),
          style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dummyAds.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ad = dummyAds[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
              boxShadow: isDarkMode ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ] : [],
            ),
            child: Column(
              crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  ad['title'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ad['desc'],
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: isArabic
                      ? [
                    Row(
                      children: [
                        Icon(Icons.phone, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          ad['phone'],
                          style: TextStyle(fontSize: 11, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context).translate(ad['gov']),
                          style: TextStyle(fontSize: 11, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.location_on, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, size: 14),
                      ],
                    ),
                  ]
                      : [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context).translate(ad['gov']),
                          style: TextStyle(fontSize: 11, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.phone, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          ad['phone'],
                          style: TextStyle(fontSize: 11, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}