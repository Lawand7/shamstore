import 'package:flutter/material.dart';

import 'package:shamstore/features/ads/repositories/advertisement_repository.dart';
import 'package:shamstore/screen/add_ad_page.dart';
import 'package:shamstore/screen/all_ads_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class HomeAdsSection extends StatefulWidget {
  const HomeAdsSection({super.key});

  @override
  State<HomeAdsSection> createState() => _HomeAdsSectionState();
}

class _HomeAdsSectionState extends State<HomeAdsSection> {
  static const List<Color> _cardColors = [
    Color(0xFF0F4C8A),
    Color(0xFF059669),
    Color(0xFFF59E0B),
    Color(0xFF7C3AED),
  ];

  final AdvertisementRepository _repository = AdvertisementRepository();
  final PageController _pageController = PageController(
    initialPage: 10000,
    viewportFraction: 0.82,
  );

  List<Map<String, dynamic>> _ads = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAds();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAds() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _repository.getApprovedAds();
      if (!mounted) return;

      setState(() {
        _ads = result.ads;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isArabic = _isArabic(context);
    final activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AllAdsPage()),
                  );
                  if (mounted) await _loadAds();
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
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddAdPage()),
                  );
                  if (mounted) await _loadAds();
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
        _buildAdsBody(isDarkMode: isDarkMode, isArabic: isArabic),
      ],
    );
  }

  Widget _buildAdsBody({required bool isDarkMode, required bool isArabic}) {
    if (_isLoading && _ads.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty && _ads.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDarkMode
                        ? AppTheme.textSecondary
                        : AppTheme.textGrey,
                    fontSize: 12,
                  ),
                ),
                TextButton(
                  onPressed: _loadAds,
                  child: Text(AppLocalizations.of(context).translate('Retry')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_ads.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppLocalizations.of(context).translate('No ads available'),
            style: TextStyle(
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 148,
      child: PageView.builder(
        controller: _pageController,
        reverse: isArabic,
        padEnds: false,
        itemBuilder: (context, index) {
          final adIndex = index % _ads.length;
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
            child: _buildAdCard(
              ad: _ads[adIndex],
              index: adIndex,
              isDarkMode: isDarkMode,
              isArabic: isArabic,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdCard({
    required Map<String, dynamic> ad,
    required int index,
    required bool isDarkMode,
    required bool isArabic,
  }) {
    final originalColor = _cardColors[index % _cardColors.length];
    final adColor = isDarkMode
        ? Color.lerp(originalColor, Colors.white, 0.35)!
        : originalColor;
    final title = _text(ad['title'], fallback: 'إعلان');
    final description = _text(ad['description']);
    final governorate = _text(ad['governorate']);
    final phoneNumber = _text(ad['phone_number']);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.05),
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
                  title,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
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
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDarkMode
                          ? AppTheme.textSecondary
                          : AppTheme.textGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (governorate.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: isArabic
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: adColor,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context).translate(governorate),
                          style: TextStyle(fontSize: 10, color: adColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (phoneNumber.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: isArabic
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_outlined, size: 12, color: adColor),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          phoneNumber,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(fontSize: 10, color: adColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: adColor.withValues(alpha: isDarkMode ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.campaign_outlined, color: adColor, size: 23),
          ),
        ],
      ),
    );
  }

  String _text(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text.toLowerCase() == 'null' ? fallback : text;
  }
}
