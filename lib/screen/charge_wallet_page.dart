import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart'; // استيراد ملف الترجمة

class ChargeWalletPage extends StatefulWidget {
  const ChargeWalletPage({super.key});

  @override
  State<ChargeWalletPage> createState() => _ChargeWalletPageState();
}

class _ChargeWalletPageState extends State<ChargeWalletPage> {
  bool _imageSelected = false;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('Charge Wallet'),
          style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
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
            _buildUploadCard(context, isDarkMode),
            const SizedBox(height: 20),
            _buildSendButton(context, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCard(BuildContext context, bool isDarkMode) {
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
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
              border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
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
              border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('Pay'),
                    style: const TextStyle(color: AppTheme.white, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('Admin Account Number'),
                      style: TextStyle(fontSize: 10, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '0991 234 567',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
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

  Widget _buildUploadCard(BuildContext context, bool isDarkMode) {
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.transparent : AppTheme.border),
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
            AppLocalizations.of(context).translate('Transfer Receipt'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 14),

          GestureDetector(
            onTap: () => setState(() => _imageSelected = true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: _imageSelected
                    ? activeColor.withOpacity(0.06)
                    : (isDarkMode ? AppTheme.inputFieldBg : AppTheme.background),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _imageSelected ? activeColor : (isDarkMode ? Colors.transparent : AppTheme.border),
                  width: _imageSelected ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _imageSelected ? Icons.check_circle_outline : Icons.upload_file_outlined,
                    size: 36,
                    color: _imageSelected ? activeColor : (isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _imageSelected
                        ? AppLocalizations.of(context).translate('Image Selected')
                        : AppLocalizations.of(context).translate('Upload Receipt Image'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _imageSelected ? activeColor : (isDarkMode ? AppTheme.textPrimary : AppTheme.textGrey),
                    ),
                  ),
                  if (!_imageSelected) ...[
                    const SizedBox(height: 4),
                    Text(
                      'PNG / JPG — Max size 5MB',
                      style: TextStyle(fontSize: 11, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => setState(() => _imageSelected = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate('Choose Image'),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (!_imageSelected) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                AppLocalizations.of(context).translate('Receipt preview notice'),
                style: TextStyle(fontSize: 11, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSendButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _imageSelected
            ? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).translate('Success SnackBar text')),
            ),
          );
          Navigator.pop(context);
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: AppTheme.white,
          disabledBackgroundColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
          disabledForegroundColor: isDarkMode ? AppTheme.textSecondary.withOpacity(0.5) : Colors.white.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          AppLocalizations.of(context).translate('Send Charge Request'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}