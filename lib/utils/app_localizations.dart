import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  static const String languageStorageKey = 'app_language_code';
  static const Set<String> supportedLanguageCodes = {'ar', 'en'};
  static String _currentLanguageCode = 'ar';

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static String get currentLanguageCode => _currentLanguageCode;

  static bool get isCurrentArabic => _currentLanguageCode == 'ar';

  static String get savedLanguageCode {
    final savedCode = GetStorage().read(languageStorageKey)?.toString();

    return supportedLanguageCodes.contains(savedCode) ? savedCode! : 'ar';
  }

  static Future<void> saveLanguageCode(String languageCode) async {
    final normalized = supportedLanguageCodes.contains(languageCode)
        ? languageCode
        : 'ar';
    _currentLanguageCode = normalized;
    await GetStorage().write(languageStorageKey, normalized);
  }

  Future<bool> load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/l10n/${locale.languageCode}.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      _currentLanguageCode = locale.languageCode;

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

  String translateOrOriginal(String key) {
    return _localizedStrings[key] ?? key;
  }

  bool containsKey(String key) => _localizedStrings.containsKey(key);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => true;
}
