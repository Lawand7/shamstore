import 'package:flutter/material.dart';
import 'package:shamstore/features/ads/repositories/advertisement_repository.dart';
import 'package:shamstore/screen/add_ad_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart';

class MyAdsPage extends StatefulWidget {
  const MyAdsPage({super.key});

  @override
  State<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> {
  final AdvertisementRepository _repository = AdvertisementRepository();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _myAds = [];
  final Set<int> _deletingAdIds = <int>{};

  String _selectedStatus = 'pending';
  String _errorMessage = '';
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadAds(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _scrollController.position.pixels <
            _scrollController.position.maxScrollExtent - 200) {
      return;
    }

    _loadMoreAds();
  }

  Future<void> _loadAds({required bool refresh}) async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';

      if (refresh) {
        _currentPage = 1;
        _lastPage = 1;
        _myAds.clear();
      }
    });

    try {
      final result = await _repository.getMyAdsByStatus(
        status: _selectedStatus,
        page: _currentPage,
      );

      if (!mounted) return;

      setState(() {
        _myAds
          ..clear()
          ..addAll(result.ads);
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreAds() async {
    if (_isLoading || _isLoadingMore || _currentPage >= _lastPage) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _errorMessage = '';
    });

    try {
      final result = await _repository.getMyAdsByStatus(
        status: _selectedStatus,
        page: _currentPage + 1,
      );

      if (!mounted) return;

      setState(() {
        _myAds.addAll(result.ads);
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _selectStatus(String status) async {
    if (_selectedStatus == status || _isLoading) return;

    setState(() => _selectedStatus = status);
    await _loadAds(refresh: true);
  }

  Future<void> _deleteAd(int adId) async {
    if (_deletingAdIds.contains(adId)) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_isArabic() ? 'حذف الإعلان' : 'Delete ad'),
        content: Text(
          _isArabic()
              ? 'هل أنت متأكد من حذف هذا الإعلان؟'
              : 'Are you sure you want to delete this ad?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_isArabic() ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              _isArabic() ? 'حذف' : 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    setState(() => _deletingAdIds.add(adId));
    try {
      final message = await _repository.deleteAd(adId);
      if (!mounted) return;

      await _loadAds(refresh: true);
      if (!mounted) return;

      AppFeedback.success(context, message);
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');
      AppFeedback.error(context, message);
    } finally {
      if (mounted) {
        setState(() => _deletingAdIds.remove(adId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color activePrimary = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('my_ads'),
          style: const TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
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
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppTheme.white,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAdPage()),
              ).then((_) => _loadAds(refresh: true));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusSelector(isDarkMode),
          Expanded(
            child: _buildContent(
              context: context,
              isDarkMode: isDarkMode,
              activePrimary: activePrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector(bool isDarkMode) {
    const statuses = ['pending', 'approved', 'declined'];

    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];

          return ChoiceChip(
            label: Text(_statusLabel(status)),
            selected: _selectedStatus == status,
            onSelected: _isLoading ? null : (_) => _selectStatus(status),
            selectedColor: isDarkMode
                ? AppTheme.selectedBorder
                : AppTheme.primary,
            labelStyle: TextStyle(
              color: _selectedStatus == status
                  ? AppTheme.white
                  : (isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
              fontSize: 12,
            ),
            backgroundColor: isDarkMode
                ? AppTheme.cardBackground
                : AppTheme.white,
            side: BorderSide(
              color: isDarkMode ? Colors.transparent : AppTheme.border,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required bool isDarkMode,
    required Color activePrimary,
  }) {
    if (_isLoading && _myAds.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty && _myAds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 52,
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode
                      ? AppTheme.textSecondary
                      : AppTheme.textGrey,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _loadAds(refresh: true),
                child: Text(_isArabic() ? 'إعادة المحاولة' : 'Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_myAds.isEmpty) {
      return _buildEmptyState(context, isDarkMode);
    }

    return _buildAdsList(isDarkMode, activePrimary);
  }

  String _statusLabel(String status) {
    if (_isArabic()) {
      switch (status) {
        case 'approved':
          return 'مقبولة';
        case 'declined':
          return 'مرفوضة';
        default:
          return 'قيد المراجعة';
      }
    }

    switch (status) {
      case 'approved':
        return 'Approved';
      case 'declined':
        return 'Declined';
      default:
        return 'Pending';
    }
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 70,
            color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('no_ads_found'),
            style: TextStyle(
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdsList(bool isDarkMode, Color activePrimary) {
    return RefreshIndicator(
      onRefresh: () => _loadAds(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _myAds.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _myAds.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final ad = _myAds[index];
          final adId = int.tryParse(ad['id']?.toString() ?? '') ?? 0;
          final Color originalColor = activePrimary;
          final Color adColor = isDarkMode
              ? Color.lerp(originalColor, Colors.white, 0.35)!
              : originalColor;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode
                    ? AppTheme.inputFieldBg.withOpacity(0.5)
                    : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
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
                      child: Icon(
                        Icons.campaign_outlined,
                        color: adColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: _isArabic()
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            ad['title'],
                            style: TextStyle(
                              fontSize: 13,
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
                            ad['description']?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDarkMode
                                  ? AppTheme.textSecondary
                                  : AppTheme.textGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: _isArabic()
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on, size: 12, color: adColor),
                              const SizedBox(width: 2),
                              Text(
                                ad['governorate']?.toString() ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: adColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.phone_outlined,
                                size: 12,
                                color: isDarkMode
                                    ? AppTheme.textSecondary
                                    : AppTheme.textLight,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                ad['phone_number']?.toString() ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDarkMode
                                      ? AppTheme.textSecondary
                                      : AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionBtn(
                      AppLocalizations.of(context).translate('delete_action'),
                      Icons.delete_outline,
                      isDarkMode
                          ? const Color(0xFFF87171)
                          : const Color(0xFFEF4444),
                      adId > 0 && !_deletingAdIds.contains(adId)
                          ? () => _deleteAd(adId)
                          : null,
                      isLoading: _deletingAdIds.contains(adId),
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

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onTap, {
    bool isLoading = false,
  }) {
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
            if (isLoading)
              SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: color,
                ),
              )
            else ...[
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 13, color: color),
            ],
          ],
        ),
      ),
    );
  }

  bool _isArabic() => Localizations.localeOf(context).languageCode == 'ar';
}
