import 'package:flutter/material.dart';
import 'package:shamstore/utils/app_localizations.dart'; // استدعاء ملف الترجمة المعدل الخاص بك
import 'package:shamstore/screen/login_page.dart';
import 'package:shamstore/them/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 فحص حالة الدارك مود الحالية بالتطبيق ديناميكياً لتوجيه ألوان عناصر الواجهة
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 🎨 جعل الخلفية تأخذ لون البار العلوي تماماً حسب الثيم الحالي
    final Color barBackground = isDarkMode ? AppTheme.topBottomBar : AppTheme.primary;

    // ضبط الألوان لتظهر بوضوح عالٍ وتباين مريح فوق الخلفية النيلية للبار العلوي
    final Color activePrimary = isDarkMode ? AppTheme.accentBlue : AppTheme.white;
    final Color buttonActiveBg = isDarkMode ? AppTheme.selectedBorder : AppTheme.white;
    final Color buttonActiveText = isDarkMode ? AppTheme.darkBackground : AppTheme.primary;

    return Scaffold(
      backgroundColor: barBackground, // 💡 تم الربط بلون البار العلوي هنا
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              // أيقونة الواجهة الترحيبية الدائرية فوق اللون النيلي
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 75,
                  color: activePrimary,
                ),
              ),

              const SizedBox(height: 32),

              // 1️⃣ ترجمة نص: مرحباً بكم في
              Text(
                AppLocalizations.of(context).translate('welcome_to'),
                style: const TextStyle(color: Colors.white60, fontSize: 13, letterSpacing: 2.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              // 2️⃣ ترجمة نص اسم التطبيق: شام ستور
              Text(
                AppLocalizations.of(context).translate('shamstore'),
                style: TextStyle(
                  color: activePrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // 3️⃣ ترجمة نص الوصف
              Text(
                AppLocalizations.of(context).translate('welcome_desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 48),

              // زر البداية المشرق فوق الخلفية الداكنة
              Center(
                child: SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonActiveBg,
                      foregroundColor: buttonActiveText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 4️⃣ ترجمة نص زر البداية: ابدأ الآن
                        Text(
                            AppLocalizations.of(context).translate('get_started'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? Icons.arrow_back
                              : Icons.arrow_forward,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}