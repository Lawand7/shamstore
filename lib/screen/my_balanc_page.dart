import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class MyBalancePage extends StatefulWidget {
  const MyBalancePage({super.key});

  @override
  State<MyBalancePage> createState() => _MyBalancePageState();
}

class _MyBalancePageState extends State<MyBalancePage> {
  final TextEditingController _amountController = TextEditingController(text: "100,000");
  final TextEditingController _accountController = TextEditingController(text: "0991234567");

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

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
        leading: IconButton(
          icon: Icon(
            _isArabic() ? Icons.arrow_back_ios_rounded : Icons.arrow_back_ios_new_rounded,
            color: AppTheme.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).translate('My Balance'),
          style: const TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBalanceCard(context, isDarkMode),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildWithdrawalForm(context, isDarkMode),
                  const SizedBox(height: 16),

                  _buildWarningBanner(context),
                  const SizedBox(height: 16),

                  _buildInvoiceDetails(context, isDarkMode),
                  const SizedBox(height: 24),

                  _buildConfirmButton(context, isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, isDarkMode),
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
        crossAxisAlignment: _isArabic() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: _isArabic() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('Available Balance'),
                    style: TextStyle(color: AppTheme.white.withOpacity(0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '285,000',
                    style: TextStyle(color: AppTheme.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    AppLocalizations.of(context).translate('SP'),
                    style: TextStyle(color: AppTheme.white.withOpacity(0.8), fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppTheme.white.withOpacity(0.2), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardStat(
                AppLocalizations.of(context).translate('Completed Orders'),
                '8 ${AppLocalizations.of(context).translate('Orders Count')}',
              ),
              _buildCardStat(
                AppLocalizations.of(context).translate('Total Sales'),
                '287,870 ${AppLocalizations.of(context).translate('SP')}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat(String label, String value) {
    return Column(
      crossAxisAlignment: _isArabic() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppTheme.white.withOpacity(0.6), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppTheme.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildWithdrawalForm(BuildContext context, bool isDarkMode) {
    final Color activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: _isArabic() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: _isArabic() ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: _isArabic()
                ? [
              Text(AppLocalizations.of(context).translate('Withdraw Earnings'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: activePrimary)),
              const SizedBox(width: 8),
              Icon(Icons.payments_outlined, color: activePrimary, size: 20),
            ]
                : [
              Icon(Icons.payments_outlined, color: activePrimary, size: 20),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context).translate('Withdraw Earnings'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: activePrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('Amount to Withdraw (SP)'),
            style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textAlign: _isArabic() ? TextAlign.right : TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('Payout Method'),
            style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _isArabic()
                  ? [
                const Text('ShamCash', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 8),
                const Icon(Icons.phone_android, color: AppTheme.white, size: 18),
              ]
                  : [
                const Icon(Icons.phone_android, color: AppTheme.white, size: 18),
                const SizedBox(width: 8),
                const Text('ShamCash', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('ShamCash Account Number'),
            style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _accountController,
            keyboardType: TextInputType.phone,
            textAlign: _isArabic() ? TextAlign.right : TextAlign.left,
            style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
              prefixIcon: _isArabic() ? null : Icon(Icons.lock_outline, size: 18, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
              suffixIcon: _isArabic() ? Icon(Icons.lock_outline, size: 18, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context).translate('Platform fee warning notice'),
              style: const TextStyle(color: AppTheme.warning, fontSize: 11, height: 1.4, fontWeight: FontWeight.w500),
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
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
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
          _buildInvoiceRow(AppLocalizations.of(context).translate('Requested Amount'), '100,000 ${AppLocalizations.of(context).translate('SP')}', isBold: false, isDarkMode: isDarkMode),
          const SizedBox(height: 10),
          _buildInvoiceRow(AppLocalizations.of(context).translate('Platform Fee (1%)'), '- 1,000 ${AppLocalizations.of(context).translate('SP')}', isBold: false, valueColor: AppTheme.error, isDarkMode: isDarkMode),
          const SizedBox(height: 10),
          Divider(color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border, height: 1),
          const SizedBox(height: 10),
          _buildInvoiceRow(AppLocalizations.of(context).translate('Net Payout Amount'), '99,000 ${AppLocalizations.of(context).translate('SP')}', isBold: true, valueColor: AppTheme.success, isDarkMode: isDarkMode),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, {required bool isBold, Color? valueColor, required bool isDarkMode}) {
    final Color defaultTextColor = isDarkMode ? AppTheme.textPrimary : AppTheme.textDark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isBold ? defaultTextColor : (isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: valueColor ?? defaultTextColor, fontWeight: isBold ? FontWeight.bold : FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.file_download_outlined, color: AppTheme.white),
        label: Text(
          AppLocalizations.of(context).translate('Confirm Withdrawal'),
          style: const TextStyle(color: AppTheme.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDarkMode) {
    final Color activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;
    final Color inactiveColor = isDarkMode ? AppTheme.textSecondary : AppTheme.textLight;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.topBottomBar : AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.store_outlined, AppLocalizations.of(context).translate('Store Nav'), false, activePrimary, inactiveColor),
          _buildNavItem(Icons.account_balance_wallet, AppLocalizations.of(context).translate('Balance Nav'), true, activePrimary, inactiveColor),
          _buildNavItem(Icons.receipt_long_outlined, AppLocalizations.of(context).translate('Orders Nav'), false, activePrimary, inactiveColor),
          _buildNavItem(Icons.settings_outlined, AppLocalizations.of(context).translate('Settings Nav'), false, activePrimary, inactiveColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, Color activeColor, Color inactiveColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? activeColor : inactiveColor, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: isActive ? activeColor : inactiveColor, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }

  bool _isArabic() => Localizations.localeOf(context).languageCode == 'ar';
}