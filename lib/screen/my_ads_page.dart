import 'package:flutter/material.dart';
import 'package:shamstore/screen/add_ad_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class MyAdsPage extends StatefulWidget {
  const MyAdsPage({super.key});

  @override
  State<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> {
  final List<Map<String, dynamic>> _myAds = [
    {
      'title': 'Professional Photographer',
      'desc': 'Events & Weddings Photography',
      'city': 'Damascus',
      'icon': Icons.camera_alt_outlined,
      'color': const Color(0xFF0F4C8A),
      'date': '12 مايو 2026',
      'views': 142
    },
    {
      'title': 'Private Tutor',
      'desc': 'Math & Physics for high school students',
      'city': 'Aleppo',
      'icon': Icons.school_outlined,
      'color': const Color(0xFF059669),
      'date': '10 مايو 2026',
      'views': 95
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('my_ads'),
          style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            _isArabic() ? Icons.arrow_forward : Icons.arrow_back,
            color: AppTheme.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.white, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAdPage()),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: _myAds.isEmpty
          ? _buildEmptyState(context, isDarkMode)
          : _buildAdsList(isDarkMode, activePrimary),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined, size: 70, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('no_ads_found'),
            style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAdsList(bool isDarkMode, Color activePrimary) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myAds.length,
      itemBuilder: (context, index) {
        final ad = _myAds[index];
        final Color originalColor = ad['color'] as Color;
        final Color adColor = isDarkMode ? Color.lerp(originalColor, Colors.white, 0.35)! : originalColor;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDarkMode ? AppTheme.inputFieldBg.withOpacity(0.5) : Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: adColor.withOpacity(isDarkMode ? 0.18 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(ad['icon'], color: adColor, size: 24),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: _isArabic() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          ad['title'],
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ad['desc'],
                          style: TextStyle(fontSize: 11, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: _isArabic() ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, size: 12, color: adColor),
                            const SizedBox(width: 2),
                            Text(ad['city'], style: TextStyle(fontSize: 10, color: adColor, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 12),
                            Icon(Icons.visibility_outlined, size: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                            const SizedBox(width: 2),
                            Text('${ad['views']}', style: TextStyle(fontSize: 10, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionBtn(
                    AppLocalizations.of(context).translate('delete_action'),
                    Icons.delete_outline,
                    isDarkMode ? const Color(0xFFF87171) : const Color(0xFFEF4444),
                        () {
                      setState(() {
                        _myAds.removeAt(index);
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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