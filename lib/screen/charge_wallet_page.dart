import 'package:flutter/material.dart';
import 'package:shamstore/features/wallet/repositories/wallet_repository.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_feedback.dart';
import 'package:shamstore/utils/app_localizations.dart'; // استيراد ملف الترجمة

class ChargeWalletPage extends StatefulWidget {
  const ChargeWalletPage({super.key});

  @override
  State<ChargeWalletPage> createState() => _ChargeWalletPageState();
}

class _ChargeWalletPageState extends State<ChargeWalletPage> {
  final WalletRepository _walletRepository = WalletRepository();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _transferNumberController =
      TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _transferNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitDeposit() async {
    final amount = _amountController.text.trim();
    final transferNumber = _transferNumberController.text.trim();
    final parsedAmount = num.tryParse(amount);

    if (parsedAmount == null || parsedAmount <= 0) {
      AppFeedback.error(context, 'أدخل مبلغ شحن صحيحًا أكبر من الصفر');
      return;
    }
    if (transferNumber.isEmpty) {
      AppFeedback.error(context, 'أدخل رقم عملية التحويل');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final message = await _walletRepository.deposit(
        transferNumber: transferNumber,
        amount: amount,
      );
      if (!mounted) return;

      AppFeedback.success(context, message);
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');
      AppFeedback.error(context, message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('Charge Wallet'),
          style: const TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildQrCard(context, isDarkMode),
            const SizedBox(height: 14),
            _buildTransferNumberCard(context, isDarkMode),
            const SizedBox(height: 20),
            _buildSendButton(context, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCard(BuildContext context, bool isDarkMode) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
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
          Text(
            AppLocalizations.of(context).translate('Sham Cash Barcode'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.transparent : AppTheme.border,
              ),
            ),
            child: Icon(Icons.qr_code_2, size: 130, color: activeColor),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDarkMode ? Colors.transparent : AppTheme.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppTheme.selectedBorder
                        : AppTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('Pay'),
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      ).translate('Admin Account Number'),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDarkMode
                            ? AppTheme.textSecondary
                            : AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '0991 234 567',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppTheme.textPrimary
                            : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context).translate('Transfer description text'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferNumberCard(BuildContext context, bool isDarkMode) {
    final Color activeColor = isDarkMode
        ? AppTheme.accentBlue
        : AppTheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppTheme.border,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مبلغ الشحن',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amountController,
            enabled: !_isSubmitting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'أدخل المبلغ المحوّل عبر ShamCash',
              hintStyle: TextStyle(
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
                fontSize: 12,
              ),
              prefixIcon: Icon(Icons.payments_outlined, color: activeColor),
              filled: true,
              fillColor: isDarkMode
                  ? AppTheme.inputFieldBg
                  : AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.transparent : AppTheme.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.transparent : AppTheme.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: activeColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'رقم عملية التحويل',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _transferNumberController,
            enabled: !_isSubmitting,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submitDeposit(),
            style: TextStyle(
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'أدخل رقم العملية الظاهر في إيصال ShamCash',
              hintStyle: TextStyle(
                color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
                fontSize: 12,
              ),
              prefixIcon: Icon(Icons.receipt_long_outlined, color: activeColor),
              filled: true,
              fillColor: isDarkMode
                  ? AppTheme.inputFieldBg
                  : AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.transparent : AppTheme.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.transparent : AppTheme.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: activeColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'سيتم مراجعة رقم التحويل قبل إضافة الرصيد إلى محفظتك.',
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            _amountController.text.trim().isNotEmpty &&
                _transferNumberController.text.trim().isNotEmpty &&
                !_isSubmitting
            ? _submitDeposit
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: AppTheme.white,
          disabledBackgroundColor: isDarkMode
              ? AppTheme.inputFieldBg
              : AppTheme.border,
          disabledForegroundColor: isDarkMode
              ? AppTheme.textSecondary.withOpacity(0.5)
              : Colors.white.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                AppLocalizations.of(context).translate('Send Charge Request'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
