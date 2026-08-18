import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/wallet/controllers/wallet_controller.dart';
import 'package:shamstore/features/wallet/models/wallet_transaction_model.dart';
import 'package:shamstore/screen/charge_wallet_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late final WalletController _walletController;

  @override
  void initState() {
    super.initState();
    _walletController = WalletController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _walletController.refreshWallet();
    });
  }

  @override
  void dispose() {
    _walletController.dispose();
    super.dispose();
  }

  bool _isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  Future<void> _openChargeWallet() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ChargeWalletPage()),
    );

    if (result == true) {
      await _walletController.refreshWallet();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isArabic = _isArabic(context);

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('My Wallet'),
          style: const TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward : Icons.arrow_back,
            color: AppTheme.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _walletController.refreshWallet,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _buildBalanceCard(context, isDarkMode),
            const SizedBox(height: 4),
            _buildTransactionsCard(context, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, bool isDarkMode) {
    final activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.white;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? AppTheme.accentBlue.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? AppTheme.accentBlue : AppTheme.primary)
                .withValues(alpha: isDarkMode ? 0.05 : 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).translate('Current Balance'),
            style: TextStyle(
              color: isDarkMode ? AppTheme.textSecondary : Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final balance = _walletController.balance.value;

            if (_walletController.isLoadingBalance.value && balance == null) {
              return const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: AppTheme.white,
                  strokeWidth: 3,
                ),
              );
            }

            return Text(
              balance == null
                  ? '—'
                  : '${_formatAmount(balance)} ${AppLocalizations.of(context).translate('SP')}',
              style: TextStyle(
                color: activeColor,
                fontSize: balance == null ? 42 : 32,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
          const SizedBox(height: 4),
          Obx(() {
            final error = _walletController.balanceError.value;
            final hasBalance = _walletController.balance.value != null;

            return Text(
              error.isNotEmpty
                  ? error
                  : AppLocalizations.of(context).translate(
                      hasBalance
                          ? 'Available Balance'
                          : 'Wallet balance unavailable',
                    ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: error.isNotEmpty
                    ? AppTheme.error
                    : (isDarkMode ? AppTheme.textSecondary : Colors.white70),
                fontSize: 12,
              ),
            );
          }),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openChargeWallet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context).translate('Charge Wallet'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard(BuildContext context, bool isDarkMode) {
    final dividerColor = isDarkMode ? AppTheme.inputFieldBg : AppTheme.border;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              AppLocalizations.of(context).translate('Recent Transactions'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              ),
            ),
          ),
          Divider(height: 1, color: dividerColor),
          Obx(() {
            final transactions = _walletController.transactions;
            final isLoading = _walletController.isLoadingTransactions;
            final pendingError = _walletController.pendingError.value;
            final completedError = _walletController.completedError.value;

            if (isLoading && transactions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (transactions.isEmpty &&
                pendingError.isNotEmpty &&
                completedError.isNotEmpty) {
              return _buildErrorState(context, isDarkMode, pendingError);
            }

            return Column(
              children: [
                if (pendingError.isNotEmpty)
                  _buildPartialError(
                    context,
                    'Pending transactions unavailable',
                  ),
                if (completedError.isNotEmpty)
                  _buildPartialError(
                    context,
                    'Completed transactions unavailable',
                  ),
                if (transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).translate('No wallet transactions'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textGrey,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: dividerColor),
                    itemBuilder: (context, index) {
                      return _buildTransactionTile(
                        context,
                        transactions[index],
                        isDarkMode,
                      );
                    },
                  ),
                if (transactions.isNotEmpty &&
                    _walletController.hasMoreTransactions)
                  _buildLoadMoreTransactionsButton(context),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLoadMoreTransactionsButton(BuildContext context) {
    final isLoading = _walletController.isLoadingMoreTransactions.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextButton.icon(
        onPressed: isLoading ? null : _walletController.loadMoreTransactions,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.expand_more_rounded),
        label: Text(
          AppLocalizations.of(context).translate('Load more transactions'),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    bool isDarkMode,
    String message,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppTheme.error, size: 34),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _walletController.loadTransactions,
            child: Text(AppLocalizations.of(context).translate('Retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildPartialError(BuildContext context, String messageKey) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.35)),
      ),
      child: Text(
        AppLocalizations.of(context).translate(messageKey),
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.warning, fontSize: 11),
      ),
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    WalletTransactionModel transaction,
    bool isDarkMode,
  ) {
    final isCredit = transaction.isCredit;
    final transactionColor = isCredit ? AppTheme.success : AppTheme.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: transactionColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
              color: transactionColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _transactionTitle(context, transaction.type),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppTheme.textPrimary
                        : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatusChip(context, transaction.status),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(transaction.createdAt),
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
          Text(
            '${isCredit ? '+' : '-'}${_formatAmount(transaction.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: transactionColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final isCompleted = status == 'completed';
    final color = isCompleted ? AppTheme.success : AppTheme.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        AppLocalizations.of(
          context,
        ).translate(isCompleted ? 'Completed' : 'Pending'),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _transactionTitle(BuildContext context, String type) {
    final key = switch (type) {
      'deposit' => 'Wallet deposit',
      'withdraw' => 'Wallet withdrawal',
      'payment' => 'Wallet payment',
      'refund' => 'Wallet refund',
      _ => 'Wallet transaction',
    };
    return AppLocalizations.of(context).translate(key);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    return '$day/$month/${localDate.year}';
  }

  String _formatAmount(double value) {
    final isWhole = value == value.roundToDouble();
    final raw = isWhole ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    final parts = raw.split('.');
    final formattedInteger = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return parts.length == 1
        ? formattedInteger
        : '$formattedInteger.${parts.last}';
  }
}
