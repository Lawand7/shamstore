import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shamstore/features/seller/repositories/seller_orders_repository.dart';
import 'package:shamstore/features/wallet/controllers/wallet_controller.dart';
import 'package:shamstore/features/wallet/models/wallet_transaction_model.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class MyBalancePage extends StatefulWidget {
  const MyBalancePage({super.key});

  @override
  State<MyBalancePage> createState() => _MyBalancePageState();
}

class _MyBalancePageState extends State<MyBalancePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  late final WalletController _walletController;
  late final SellerOrdersRepository _sellerOrdersRepository;

  bool _isLoadingStats = false;
  String _statsError = '';
  int? _completedOrdersCount;
  double? _totalSales;

  double get _requestedAmount {
    final value = _amountController.text.trim().replaceAll(',', '');
    return double.tryParse(value) ?? 0;
  }

  double get _platformFee => _requestedAmount * 0.01;

  double get _totalWalletDeduction => _requestedAmount + _platformFee;

  @override
  void initState() {
    super.initState();
    _walletController = WalletController();
    _sellerOrdersRepository = SellerOrdersRepository();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  bool _isArabic() {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _walletController.loadBalance(),
      _walletController.loadTransactions(),
      _loadSellerStats(),
    ]);
  }

  Future<void> _loadSellerStats() async {
    if (_isLoadingStats) return;

    setState(() {
      _isLoadingStats = true;
      _statsError = '';
    });

    final errors = <String>[];
    int? completedOrdersCount;
    double? totalSales;

    await Future.wait([
      () async {
        try {
          completedOrdersCount = await _sellerOrdersRepository
              .getCompletedOrdersCount();
        } catch (error) {
          errors.add(_cleanError(error));
        }
      }(),
      () async {
        try {
          final completedOrders = await _sellerOrdersRepository.getOrders(
            status: 'complete',
          );
          totalSales = completedOrders.fold<double>(
            0,
            (total, order) => total + order.totalPrice,
          );
        } catch (error) {
          errors.add(_cleanError(error));
        }
      }(),
    ]);

    if (!mounted) return;
    final loadedCount = completedOrdersCount;
    final loadedSales = totalSales;
    setState(() {
      if (loadedCount != null) _completedOrdersCount = loadedCount;
      if (loadedSales != null) _totalSales = loadedSales;
      _statsError = errors.toSet().join('\n');
      _isLoadingStats = false;
    });
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  Future<void> _submitWithdrawal() async {
    final amount = _amountController.text.trim().replaceAll(',', '');
    final shamCashNumber = _accountController.text.trim();
    final parsedAmount = num.tryParse(amount);

    if (parsedAmount == null || parsedAmount <= 0) {
      _showMessage(
        AppLocalizations.of(context).translate('Enter valid withdrawal amount'),
        isError: true,
      );
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(shamCashNumber)) {
      _showMessage(
        AppLocalizations.of(context).translate('Enter valid ShamCash number'),
        isError: true,
      );
      return;
    }

    final success = await _walletController.withdraw(
      amount: amount,
      shamCashNumber: shamCashNumber,
    );

    if (!mounted) return;

    if (!success) {
      _showMessage(_walletController.withdrawalError.value, isError: true);
      return;
    }

    _showMessage(
      _walletController.withdrawalMessage.value.isNotEmpty
          ? _walletController.withdrawalMessage.value
          : AppLocalizations.of(context).translate('Withdrawal request sent'),
    );
    _amountController.clear();
    _accountController.clear();
    setState(() {});
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
      ),
    );
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
        leading: IconButton(
          icon: Icon(
            _isArabic()
                ? Icons.arrow_back_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: AppTheme.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).translate('My Balance'),
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildBalanceCard(context, isDarkMode),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_statsError.isNotEmpty) ...[
                      _buildStatsError(context, isDarkMode),
                      const SizedBox(height: 16),
                    ],
                    _buildWithdrawalForm(context, isDarkMode),
                    const SizedBox(height: 16),
                    _buildWarningBanner(context),
                    const SizedBox(height: 16),
                    _buildInvoiceDetails(context, isDarkMode),
                    const SizedBox(height: 16),
                    _buildPendingWithdrawalsBanner(context, isDarkMode),
                    _buildTransactionsCard(context, isDarkMode),
                    const SizedBox(height: 24),
                    _buildConfirmButton(context, isDarkMode),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: _isArabic()
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(() {
                  final balance = _walletController.balance.value;
                  final error = _walletController.balanceError.value;
                  final isLoading = _walletController.isLoadingBalance.value;

                  return Column(
                    crossAxisAlignment: _isArabic()
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        ).translate('Available Balance'),
                        style: TextStyle(
                          color: AppTheme.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isLoading && balance == null)
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: AppTheme.white,
                            strokeWidth: 3,
                          ),
                        )
                      else
                        Text(
                          balance == null
                              ? '—'
                              : '${_formatAmount(balance)} ${AppLocalizations.of(context).translate('SP')}',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 3),
                      Text(
                        error.isNotEmpty
                            ? error
                            : AppLocalizations.of(context).translate(
                                balance == null
                                    ? 'Wallet balance unavailable'
                                    : 'Available Balance',
                              ),
                        style: TextStyle(
                          color: error.isNotEmpty
                              ? AppTheme.error
                              : AppTheme.white.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppTheme.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppTheme.white.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardStat(
                AppLocalizations.of(context).translate('Completed Orders'),
                _isLoadingStats
                    ? '...'
                    : _completedOrdersCount == null
                    ? '—'
                    : '$_completedOrdersCount ${AppLocalizations.of(context).translate('Orders Count')}',
              ),
              _buildCardStat(
                AppLocalizations.of(context).translate('Total Sales'),
                _isLoadingStats
                    ? '...'
                    : _totalSales == null
                    ? '—'
                    : '${_formatAmount(_totalSales!)} ${AppLocalizations.of(context).translate('SP')}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat(String label, String value) {
    return Flexible(
      child: Column(
        crossAxisAlignment: _isArabic()
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsError(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statsError,
              style: TextStyle(
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
                fontSize: 11,
              ),
            ),
          ),
          IconButton(
            onPressed: _loadSellerStats,
            icon: const Icon(Icons.refresh, color: AppTheme.error),
            tooltip: AppLocalizations.of(context).translate('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm(BuildContext context, bool isDarkMode) {
    final activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDarkMode),
      child: Column(
        crossAxisAlignment: _isArabic()
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: _isArabic()
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Icon(Icons.payments_outlined, color: activePrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).translate('Withdraw Earnings'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: activePrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('Amount to Withdraw (SP)'),
            style: _fieldLabelStyle(isDarkMode),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: _isArabic() ? TextAlign.right : TextAlign.left,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              fontSize: 14,
            ),
            decoration: _inputDecoration(isDarkMode),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('Payout Method'),
            style: _fieldLabelStyle(isDarkMode),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_android, color: AppTheme.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'ShamCash',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('ShamCash Account Number'),
            style: _fieldLabelStyle(isDarkMode),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _accountController,
            keyboardType: TextInputType.phone,
            textAlign: _isArabic() ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
              fontSize: 14,
            ),
            decoration: _inputDecoration(isDarkMode),
          ),
        ],
      ),
    );
  }

  TextStyle _fieldLabelStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 12,
      color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey,
      fontWeight: FontWeight.w500,
    );
  }

  InputDecoration _inputDecoration(bool isDarkMode) {
    return InputDecoration(
      filled: true,
      fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildWarningBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.warning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(
                context,
              ).translate('Platform fee warning notice'),
              style: const TextStyle(
                color: AppTheme.warning,
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
              textAlign: _isArabic() ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDarkMode),
      child: Column(
        children: [
          _buildInvoiceRow(
            AppLocalizations.of(context).translate('Requested Amount'),
            '${_formatAmount(_requestedAmount)} ${AppLocalizations.of(context).translate('SP')}',
            isBold: false,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 10),
          _buildInvoiceRow(
            AppLocalizations.of(context).translate('Platform Fee (1%)'),
            '+ ${_formatAmount(_platformFee)} ${AppLocalizations.of(context).translate('SP')}',
            isBold: false,
            valueColor: AppTheme.error,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 10),
          Divider(
            color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
            height: 1,
          ),
          const SizedBox(height: 10),
          _buildInvoiceRow(
            AppLocalizations.of(context).translate('Total Wallet Deduction'),
            '${_formatAmount(_totalWalletDeduction)} ${AppLocalizations.of(context).translate('SP')}',
            isBold: true,
            valueColor: AppTheme.success,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(
    String label,
    String value, {
    required bool isBold,
    Color? valueColor,
    required bool isDarkMode,
  }) {
    final defaultTextColor = isDarkMode
        ? AppTheme.textPrimary
        : AppTheme.textDark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isBold
                  ? defaultTextColor
                  : (isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: valueColor ?? defaultTextColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsCard(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('Recent Transactions'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final transactions = _walletController.transactions;
            final isLoading = _walletController.isLoadingTransactions;

            if (isLoading && transactions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (transactions.isEmpty) {
              final pendingError = _walletController.pendingError.value;
              final completedError = _walletController.completedError.value;
              final hasError =
                  pendingError.isNotEmpty || completedError.isNotEmpty;

              return Column(
                children: [
                  if (pendingError.isNotEmpty)
                    _buildTransactionWarning(
                      context,
                      'Pending transactions unavailable',
                    ),
                  if (completedError.isNotEmpty)
                    _buildTransactionWarning(
                      context,
                      'Completed transactions unavailable',
                    ),
                  if (!hasError)
                    Text(
                      AppLocalizations.of(
                        context,
                      ).translate('No wallet transactions'),
                      style: TextStyle(
                        color: isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textGrey,
                        fontSize: 12,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _walletController.loadTransactions,
                      child: Text(
                        AppLocalizations.of(context).translate('Retry'),
                      ),
                    ),
                ],
              );
            }

            return Column(
              children: [
                if (_walletController.pendingError.value.isNotEmpty)
                  _buildTransactionWarning(
                    context,
                    'Pending transactions unavailable',
                  ),
                if (_walletController.completedError.value.isNotEmpty)
                  _buildTransactionWarning(
                    context,
                    'Completed transactions unavailable',
                  ),
                ...transactions.map(
                  (transaction) =>
                      _buildTransactionRow(context, transaction, isDarkMode),
                ),
                if (_walletController.hasMoreTransactions)
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
      padding: const EdgeInsets.only(top: 8),
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

  Widget _buildPendingWithdrawalsBanner(BuildContext context, bool isDarkMode) {
    return Obx(() {
      final pendingWithdrawals = _walletController.pendingTransactions
          .where((transaction) => transaction.type == 'withdraw')
          .toList();

      if (pendingWithdrawals.isEmpty) return const SizedBox.shrink();

      final total = pendingWithdrawals.fold<double>(
        0,
        (sum, transaction) => sum + transaction.amount,
      );
      final localization = AppLocalizations.of(context);

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.warning.withValues(alpha: isDarkMode ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.warning.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.hourglass_top_rounded,
              color: AppTheme.warning,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: _isArabic()
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.translate('Wallet withdrawal'),
                    style: TextStyle(
                      color: isDarkMode
                          ? AppTheme.textPrimary
                          : AppTheme.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${localization.translate('Pending')} • ${pendingWithdrawals.length} • ${_formatAmount(total)} ${localization.translate('SP')}',
                    textAlign: _isArabic() ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      color: AppTheme.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTransactionWarning(BuildContext context, String messageKey) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        AppLocalizations.of(context).translate(messageKey),
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.warning, fontSize: 10),
      ),
    );
  }

  Widget _buildTransactionRow(
    BuildContext context,
    WalletTransactionModel transaction,
    bool isDarkMode,
  ) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? AppTheme.success : AppTheme.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _transactionTitle(context, transaction.type),
                  style: TextStyle(
                    color: isDarkMode
                        ? AppTheme.textPrimary
                        : AppTheme.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${AppLocalizations.of(context).translate(transaction.status == 'completed' ? 'Completed' : 'Pending')} • ${_formatDate(transaction.createdAt)}',
                  style: TextStyle(
                    color: isDarkMode
                        ? AppTheme.textSecondary
                        : AppTheme.textLight,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${_formatAmount(transaction.amount)}',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, bool isDarkMode) {
    return Obx(() {
      final isSubmitting = _walletController.isWithdrawing.value;

      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: isSubmitting ? null : _submitWithdrawal,
          icon: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppTheme.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.file_download_outlined, color: AppTheme.white),
          label: Text(
            AppLocalizations.of(context).translate('Confirm Withdrawal'),
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode
                ? AppTheme.selectedBorder
                : AppTheme.primary,
            disabledBackgroundColor: isDarkMode
                ? AppTheme.inputFieldBg
                : AppTheme.textLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      );
    });
  }

  BoxDecoration _cardDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
      borderRadius: BorderRadius.circular(16),
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

  String _formatAmount(num value) {
    final doubleValue = value.toDouble();
    final isWhole = doubleValue == doubleValue.roundToDouble();
    final raw = isWhole
        ? doubleValue.toStringAsFixed(0)
        : doubleValue.toStringAsFixed(2);
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
