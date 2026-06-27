import 'package:flutter/material.dart';
import 'package:shamstore/screen/charge_wallet_page.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart'; // 💡 استيراد ملف الترجمة

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  final List<Map<String, dynamic>> _transactions = const [
    {'title': 'Buy Jacket', 'date': 'May 12, 2026', 'amount': -349, 'type': 'out'},
    {'title': 'Wallet Charge', 'date': 'May 10, 2026', 'amount': 50000, 'type': 'in'},
    {'title': 'Buy Headphones', 'date': 'May 8, 2026', 'amount': -199, 'type': 'out'},
  ];

  @override
  Widget build(BuildContext context) {
    // 💡 فحص حالة الدارك مود الحالية بالتطبيق ديناميكياً واختيار الألوان المناسبة
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('My Wallet'),
          style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward : Icons.arrow_back, // مرونة السهم حسب اتجاه اللغة
            color: AppTheme.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildBalanceCard(context, isDarkMode),
          const SizedBox(height: 20),
          _buildTransactions(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? AppTheme.accentBlue.withOpacity(0.3) : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? AppTheme.accentBlue : AppTheme.primary).withOpacity(isDarkMode ? 0.05 : 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).translate('Current Balance'),
            style: TextStyle(color: isDarkMode ? AppTheme.textSecondary : Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '125,000',
            style: TextStyle(color: isDarkMode ? AppTheme.accentBlue : AppTheme.white, fontSize: 42, fontWeight: FontWeight.bold),
          ),
          Text(
            AppLocalizations.of(context).translate('Syrian Pound'),
            style: TextStyle(color: isDarkMode ? AppTheme.textSecondary.withOpacity(0.7) : Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChargeWalletPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context).translate('Charge Wallet'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactions(BuildContext context, bool isDarkMode) {
    final Color dividerColor = isDarkMode ? AppTheme.inputFieldBg : AppTheme.border;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Text(
                AppLocalizations.of(context).translate('Recent Transactions'),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
              ),
            ),
            Divider(height: 1, color: dividerColor),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _transactions.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: dividerColor),
                itemBuilder: (context, index) {
                  final t = _transactions[index];
                  final isIn = t['type'] == 'in';

                  // تعديل ألوان الإيداع والسحب لتناسب الخلفية الداكنة وتكون مريحة للعين
                  final Color greenColor = isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669);
                  final Color redColor = isDarkMode ? const Color(0xFFF87171) : const Color(0xFFEF4444);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isIn
                                ? greenColor.withOpacity(isDarkMode ? 0.15 : 0.1)
                                : redColor.withOpacity(isDarkMode ? 0.15 : 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isIn ? Icons.arrow_downward : Icons.arrow_upward,
                            size: 18,
                            color: isIn ? greenColor : redColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t['title'],
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              t['date'],
                              style: TextStyle(fontSize: 11, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          isIn ? '+${t['amount']}' : '${t['amount']}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isIn ? greenColor : redColor),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}