import 'package:flutter/material.dart';

import 'package:shamstore/features/ads/repositories/advertisement_repository.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/utils/localized_content.dart';

class AllAdsPage extends StatefulWidget {
  const AllAdsPage({super.key});

  @override
  State<AllAdsPage> createState() => _AllAdsPageState();
}

class _AllAdsPageState extends State<AllAdsPage> {
  final AdvertisementRepository _repository = AdvertisementRepository();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _ads = [];

  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  int _currentPage = 0;
  int _lastPage = 1;

  bool get _hasMore => _currentPage < _lastPage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAds(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 250) {
      _loadAds();
    }
  }

  Future<void> _loadAds({bool refresh = false}) async {
    if (_isInitialLoading || _isLoadingMore) return;
    if (!refresh && !_hasMore) return;

    final requestedPage = refresh ? 1 : _currentPage + 1;
    setState(() {
      if (refresh) {
        _isInitialLoading = _ads.isEmpty;
        _errorMessage = '';
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final result = await _repository.getApprovedAds(page: requestedPage);
      if (!mounted) return;

      setState(() {
        if (refresh) {
          _ads
            ..clear()
            ..addAll(result.ads);
        } else {
          final existingIds = _ads.map((ad) => ad['id']).toSet();
          _ads.addAll(
            result.ads.where((ad) => !existingIds.contains(ad['id'])),
          );
        }

        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
        _errorMessage = '';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  bool _isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _isArabic(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('All Ads Title'),
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            isArabic
                ? Icons.arrow_back_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: AppTheme.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(isArabic: isArabic, isDarkMode: isDarkMode),
    );
  }

  Widget _buildBody({required bool isArabic, required bool isDarkMode}) {
    if (_isInitialLoading && _ads.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty && _ads.isEmpty) {
      return _buildMessageState(
        isDarkMode: isDarkMode,
        icon: Icons.error_outline_rounded,
        message: _errorMessage,
        actionLabel: AppLocalizations.of(context).translate('Retry'),
        onAction: () => _loadAds(refresh: true),
      );
    }

    if (_ads.isEmpty) {
      return _buildMessageState(
        isDarkMode: isDarkMode,
        icon: Icons.campaign_outlined,
        message: AppLocalizations.of(context).translate('No ads available'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadAds(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount:
            _ads.length +
            ((_isLoadingMore || _errorMessage.isNotEmpty) ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= _ads.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: _isLoadingMore
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: () => _loadAds(refresh: !_hasMore),
                        child: Text(
                          AppLocalizations.of(context).translate('Retry'),
                        ),
                      ),
              ),
            );
          }

          return _buildAdCard(
            ad: _ads[index],
            isArabic: isArabic,
            isDarkMode: isDarkMode,
          );
        },
      ),
    );
  }

  Widget _buildMessageState({
    required bool isDarkMode,
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 52,
              color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdCard({
    required Map<String, dynamic> ad,
    required bool isArabic,
    required bool isDarkMode,
  }) {
    final activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;
    final title = _text(ad['title'], fallback: 'إعلان');
    final description = _text(ad['description']);
    final governorate = _text(ad['governorate']);
    final phone = _text(ad['phone_number']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            alignment: isArabic ? WrapAlignment.end : WrapAlignment.start,
            spacing: 16,
            runSpacing: 8,
            children: [
              if (governorate.isNotEmpty)
                _buildInfo(
                  icon: Icons.location_on_outlined,
                  text: LocalizedContent.value(context, governorate),
                  color: activeColor,
                  isDarkMode: isDarkMode,
                ),
              if (phone.isNotEmpty)
                _buildInfo(
                  icon: Icons.phone_outlined,
                  text: phone,
                  color: activeColor,
                  isDarkMode: isDarkMode,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo({
    required IconData icon,
    required String text,
    required Color color,
    required bool isDarkMode,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  String _text(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text.toLowerCase() == 'null' ? fallback : text;
  }
}
