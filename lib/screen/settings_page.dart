import 'package:flutter/material.dart';
import 'package:shamstore/them/app_theme.dart';
import 'package:shamstore/utils/app_localizations.dart'; // استيراد ملف الترجمة الخاص بك
import 'package:shamstore/main.dart'; // استيراد الـ main للوصول لدالة تغيير اللغة وتغيير الثيم

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // 💡 فحص حالة الدارك مود الحالية في التطبيق ديناميكياً
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // جلب اللغة الحالية المطبقة في التطبيق لمعرفة القيمة الابتدائية للـ Dropdown
    Locale currentLocale = Localizations.localeOf(context);
    String selectedLanguage = currentLocale.languageCode == 'ar' ? 'العربية' : 'English';

    return Scaffold(
      // 🎨 التبديل التلقائي لخلفية الصفحة كاملة بناءً على الثيم
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        // 🎨 شريط الحالة العلوي (نيلي داكن للدارك، وأزرق بريمري للايت)
        backgroundColor: isDarkMode ? AppTheme.topBottomBar : AppTheme.primary,
        title: Text(
          AppLocalizations.of(context).translate('settings'), // ترجمة العنوان
          style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            // 🎨 كارد الخيارات الخلفي (نيلي داكن للدارك، وأبيض للايت)
            color: isDarkMode ? AppTheme.cardBackground : AppTheme.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🌐 خيار تغيير اللغة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: selectedLanguage,
                      underline: const SizedBox(),
                      dropdownColor: isDarkMode ? AppTheme.cardBackground : AppTheme.white, // قائمة الخيارات متناسقة
                      icon: Icon(Icons.keyboard_arrow_down, color: isDarkMode ? AppTheme.textSecondary : AppTheme.textLight),
                      style: TextStyle(fontSize: 13, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary, fontWeight: FontWeight.bold),
                      items: <String>['العربية', 'English'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != selectedLanguage) {
                          if (newValue == 'العربية') {
                            MyApp.setLocale(context, const Locale('ar'));
                          } else {
                            MyApp.setLocale(context, const Locale('en'));
                          }
                        }
                      },
                    ),
                    const Spacer(),
                    Text(
                      AppLocalizations.of(context).translate('app_language'), // ترجمة النص
                      style: TextStyle(fontSize: 14, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (isDarkMode ? AppTheme.accentBlue : AppTheme.primary).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.language, size: 18, color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary),
                    ),
                  ],
                ),
              ),

              // 🎨 فاصل متناسق اللون هندسياً مع الدارك مود
              Divider(height: 1, color: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border, indent: 16, endIndent: 16),

              // 🌙 خيار الدارك مود (الوضع الداكن المتفاعل)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Switch(
                      // 💡 قيمته تتبع حالة التطبيق الفعلية بلحظتها
                      value: isDarkMode,
                      activeColor: AppTheme.accentBlue, // أزرق نيون مضيء للدارك
                      activeTrackColor: AppTheme.selectedBorder.withOpacity(0.4),
                      inactiveThumbColor: AppTheme.textLight,
                      inactiveTrackColor: isDarkMode ? AppTheme.inputFieldBg : AppTheme.border,
                      onChanged: (value) {
                        setState(() {
                          // 💡 التحديث الفوري المباشر عبر الـ themeNotifier المستمع بالـ main
                          if (value) {
                            themeNotifier.value = ThemeMode.dark;
                          } else {
                            themeNotifier.value = ThemeMode.light;
                          }
                        });
                      },
                    ),
                    const Spacer(),
                    Text(
                      AppLocalizations.of(context).translate('dark_mode'), // ترجمة النص
                      style: TextStyle(fontSize: 14, color: isDarkMode ? AppTheme.textPrimary : AppTheme.textDark),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (isDarkMode ? AppTheme.accentBlue : AppTheme.primary).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                          isDarkMode ? Icons.dark_mode : Icons.dark_mode_outlined,
                          size: 18,
                          color: isDarkMode ? AppTheme.accentBlue : AppTheme.primary
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}