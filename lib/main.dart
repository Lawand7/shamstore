import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/screen/welcome_page.dart';
import 'package:shamstore/screen/home_page.dart'; // ✨ استدعاء الهوم بيج للاحتياط
import 'package:shamstore/them/app_theme.dart'; // استدعاء ملف الثيم الخاص بك

// 💡 المتغير العالمي المسؤول عن الاستماع لتغيرات الثيم في التطبيق بأكمله (افتراضياً يتبع وضع الهاتف)
// 💡 جعل التطبيق يبدأ دائماً بالوضع الفاتح، وينتظر ضغطة السويتش ليتحول
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // دالة استاتيكية تتيح لنا الوصول إلى حالة الـ main من أي واجهة أخرى لتغيير اللغة
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ar'); // اللغة الافتراضية عند فتح التطبيق

  // الدالة التي تقلب اللغة وتحدث التطبيق بالكامل
  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 💡 الاستماع لديناميكية تغيير الثيم من صفحة الإعدادات وإعادة بناء الألوان فوراً
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'ShamStore',
          debugShowCheckedModeBanner: false,

          locale: _locale, // الربط مع المتغير الديناميكي

          // 🎨 إعدادات الثيم الجديد المتطابق مع وضع الإعدادات واللوغ إن
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode, // الوضع الحالي المختار

          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],

          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // 🚨 حركة ذكية للمقابلة:
          // إذا أردت فتح التطبيق فوراً على واجهة البائع أمام المشرف بدون المرور بصفحات الدخول،
          // احذف السطر الأسفل وفك التعليق عن السطر الذي يليه!
          home: const WelcomeScreen(),
          // home: const HomePage(isBuyer: false), // 🔥 لفتح واجهة البائع مباشرة رغماً عن أي شيء!
        );
      },
    );
  }
}