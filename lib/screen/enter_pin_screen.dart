import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/screen/wallet_page.dart';
import 'package:shamstore/screen/my_balanc_page.dart';
// 💡 تم تعديل الاستيراد ليتوافق مع الصفحة المخصصة لتفاصيل المنتج
import 'package:shamstore/screen/product_details_page.dart';
import 'package:shamstore/utils/app_localizations.dart';

class EnterPinScreen extends StatefulWidget {
  final bool isBuyer;
  final bool isComingFromCard;
  final Map<String, dynamic>? productData;

  const EnterPinScreen({
    super.key,
    required this.isBuyer,
    this.isComingFromCard = false,
    this.productData,
  });

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  String _pin = '';
  final int _pinLength = 4;

  void _onKeypadTap(String value) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += value;
      });

      if (_pin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _verifyPin() {
    // 1️⃣ أولاً: التوجيه الصحيح لصفحة تفاصيل المنتج عند القدوم من الكارد
    if (widget.isComingFromCard && widget.productData != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // 💡 قمنا بتغييرها هنا إلى ProductDetailsPage لتطابق كود الكارد لديك
          builder: (_) => ProductDetailsPage(product: widget.productData!),
        ),
      );
      return;
    }

    // 2️⃣ ثانياً: التوجيه الاعتيادي للمحفظة
    if (widget.isBuyer) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WalletPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyBalancePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 فحص حالة الدارك مود الحالية بالتطبيق ديناميكياً
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = isDarkMode ? AppTheme.accentBlue : AppTheme.primary;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      body: Column(
        children: [
          _buildHeader(isDarkMode),
          const Spacer(),
          // مؤشرات الـ PIN المتحركة
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_pinLength, (index) {
                bool isFilled = index < _pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isFilled ? activeColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFilled ? activeColor : (isDarkMode ? AppTheme.textSecondary.withOpacity(0.4) : AppTheme.border),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
          ),
          const Spacer(),
          // حاوية لوحة المفاتيح السفلية
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: isDarkMode ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                )
              ] : [],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3'], isDarkMode),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['4', '5', '6'], isDarkMode),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['7', '8', '9'], isDarkMode),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 70, height: 70),
                      _buildKeypadButton(text: '0', onTap: () => _onKeypadTap('0'), isDarkMode: isDarkMode),
                      _buildKeypadButton(
                        icon: Icon(Icons.backspace_outlined, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark, size: 22),
                        onTap: _onBackspace,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: _isArabic() ? null : 20,
              right: _isArabic() ? 20 : null, // 💡 مرونة موقع زر العودة حسب اتجاه لغة الواجهة
              top: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isArabic() ? Icons.arrow_back_ios_rounded : Icons.arrow_back_ios_new_rounded, // 💡 قلب اتجاه السهم
                    color: AppTheme.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.lock_outline_rounded, color: AppTheme.white, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).translate('Enter Security PIN'),
                    style: const TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context).translate('Enter PIN Description'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.white.withOpacity(0.8), fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) {
        return _buildKeypadButton(
          text: key,
          onTap: () => _onKeypadTap(key),
          isDarkMode: isDarkMode,
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton({String? text, Widget? icon, required VoidCallback onTap, required bool isDarkMode}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70, height: 70,
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.background.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: text != null
              ? Text(
            text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark,
            ),
          )
              : icon,
        ),
      ),
    );
  }

  bool _isArabic() => Localizations.localeOf(context).languageCode == 'ar';
}