import 'package:flutter/material.dart';
import 'package:shamstore/features/support/repositories/support_repository.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class MySupportRequestsPage extends StatefulWidget {
  const MySupportRequestsPage({super.key});

  @override
  State<MySupportRequestsPage> createState() => _MySupportRequestsPageState();
}

class _MySupportRequestsPageState extends State<MySupportRequestsPage> {
  final SupportRepository _repository = SupportRepository();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _questions = [];

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
    _loadQuestions(refresh: true);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _scrollController.position.pixels <
            _scrollController.position.maxScrollExtent - 200) {
      return;
    }

    _loadMoreQuestions();
  }

  Future<void> _loadQuestions({required bool refresh}) async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      if (refresh) {
        _currentPage = 1;
        _lastPage = 1;
        _questions.clear();
      }
    });

    try {
      final result = await _repository.getMyQuestionsByStatus(
        status: _selectedStatus,
        page: _currentPage,
      );

      if (!mounted) return;

      setState(() {
        _questions
          ..clear()
          ..addAll(result.questions);
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

  Future<void> _loadMoreQuestions() async {
    if (_isLoading || _isLoadingMore || _currentPage >= _lastPage) return;

    setState(() {
      _isLoadingMore = true;
      _errorMessage = '';
    });

    try {
      final result = await _repository.getMyQuestionsByStatus(
        status: _selectedStatus,
        page: _currentPage + 1,
      );

      if (!mounted) return;

      setState(() {
        _questions.addAll(result.questions);
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
    await _loadQuestions(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
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
          AppLocalizations.of(context).translate('support_requests_title'),
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildStatusSelector(isDarkMode),
          Expanded(child: _buildContent(isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildStatusSelector(bool isDarkMode) {
    return SizedBox(
      height: 58,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _statusChip(
            'pending',
            AppLocalizations.of(context).translate('status_pending_review'),
            isDarkMode,
          ),
          const SizedBox(width: 8),
          _statusChip(
            'answered',
            AppLocalizations.of(context).translate('status_answered_support'),
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status, String label, bool isDarkMode) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedStatus == status,
      onSelected: _isLoading ? null : (_) => _selectStatus(status),
      selectedColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
      labelStyle: TextStyle(
        color: _selectedStatus == status
            ? AppTheme.white
            : (isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
        fontSize: 12,
      ),
      backgroundColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
      side: BorderSide(
        color: isDarkMode ? Colors.transparent : AppTheme.border,
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (_isLoading && _questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty && _questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 52, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _loadQuestions(refresh: true),
                child: Text(AppLocalizations.of(context).translate('retry')),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadQuestions(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 220),
            Center(
              child: Text(
                AppLocalizations.of(
                  context,
                ).translate('no_support_requests_status'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadQuestions(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _questions.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _questions.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return _buildQuestionCard(_questions[index], isDarkMode);
        },
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, bool isDarkMode) {
    final answer = question['answer']?.toString().trim() ?? '';
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Card(
      color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question['question']?.toString() ?? '',
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (answer.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(
                  context,
                ).translate('support_response_label'),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                answer,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  color: isDarkMode
                      ? AppTheme.textSecondary
                      : AppTheme.textGrey,
                  fontSize: 12,
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(
                  context,
                ).translate('waiting_support_response'),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: const TextStyle(color: Colors.orange, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
