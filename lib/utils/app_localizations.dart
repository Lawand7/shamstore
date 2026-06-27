import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  // 💡 جعلناها static لكي نحافظ على المرجع الموحد للنصوص عبر الـ 40 واجهة دون تضارب
  static Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<bool> load() async {
    try {
      final jsonString =
      await rootBundle.loadString('assets/l10n/${locale.languageCode}.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings =
          jsonMap.map((key, value) => MapEntry(key, value.toString()));

      return true;
    } catch (e) {
      _localizedStrings = {};
      debugPrint("Error loading localization file: $e");
      return false;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  // 💡 قمنا بتغييرها إلى true لكي يكتشف النظام تغيير اللغة ويقوم بتحديث النصوص فوراً
  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => true;
}