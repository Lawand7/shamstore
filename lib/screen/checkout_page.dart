import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic> item;
  const CheckoutPage({super.key, required this.item});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _phoneController = TextEditingController(text: '0991 234 567');
  final _addressController = TextEditingController(text: 'Damascus - Al-Mezzeh - Jame3a Street');

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

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
          AppLocalizations.of(context).translate('Shopping Cart'),
          style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildDeliveryForm(context, isDarkMode),
                const SizedBox(height: 14),
                _buildOrderSummary(context, isDarkMode),
                const SizedBox(height: 20),
                _buildConfirmButton(context, isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryForm(BuildContext context, bool isDarkMode) {
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppLocalizations.of(context).translate('Delivery Details'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            AppLocalizations.of(context).translate('Phone Number'),
            style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textAlign: _textInputLeftRight(),
            style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone_outlined, color: activeColor, size: 18),
              filled: true,
              fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, width: 1.5)),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            AppLocalizations.of(context).translate('Address'),
            style: TextStyle(fontSize: 12, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textGrey),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _addressController,
            maxLines: 2,
            textAlign: TextAlign.right,
            style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Icon(Icons.location_on_outlined, color: activeColor, size: 18),
              ),
              filled: true,
              fillColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isDarkMode ? BorderSide.none : const BorderSide(color: AppTheme.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, bool isDarkMode) {
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppLocalizations.of(context).translate('Order Summary'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.item['price']} ${AppLocalizations.of(context).translate('SP')}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary,
                ),
              ),
              Text(
                widget.item['name'] ?? '',
                style: TextStyle(fontSize: 13, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).translate('Order Success Notice')),
            ),
          );
          Navigator.pop(context);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? AppTheme.selectedBorder : AppTheme.primary,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          AppLocalizations.of(context).translate('Confirm Order'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  TextAlign _textInputLeftRight() => Localizations.localeOf(context).languageCode == 'ar' ? TextAlign.left : TextAlign.right;
}