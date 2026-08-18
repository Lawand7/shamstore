import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'firebase_options.dart';
import 'package:shamstore/services/firebase_notification_service.dart';
import 'package:shamstore/utils/app_localizations.dart';
import 'package:shamstore/core/network/dio_client.dart';
import 'package:shamstore/core/storage/token_storage.dart';
import 'package:shamstore/screen/home_page.dart';
import 'package:shamstore/screen/seller_home_page.dart';
import 'package:shamstore/screen/welcome_page.dart';
import 'package:shamstore/them/app_theme.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GetStorage.init();

  DioClient.onUnauthorized = () async {
    if (Get.key.currentState == null) return;

    Get.offAll<void>(() => const WelcomeScreen());
  };

  await FirebaseNotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();

    state?.changeLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ar');
  late final Widget _initialScreen;

  @override
  void initState() {
    super.initState();
    _initialScreen = _resolveInitialScreen();
  }

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  Widget _resolveInitialScreen() {
    if (!TokenStorage.isLoggedIn) {
      return const WelcomeScreen();
    }

    final role = TokenStorage.getUserRole();

    if (role == 'seller') {
      return const SellerHomePage();
    }

    if (role == 'customer' || role == 'buyer') {
      return const HomePage(isBuyer: true);
    }

    return const WelcomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return GetMaterialApp(
          title: 'ShamStore',
          debugShowCheckedModeBanner: false,

          locale: _locale,

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,

          supportedLocales: const [Locale('en'), Locale('ar')],

          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          home: _initialScreen,
        );
      },
    );
  }
}
