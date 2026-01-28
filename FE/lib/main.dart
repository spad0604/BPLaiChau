import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'routes/app_pages.dart';
import 'core/app_binding.dart';
import 'core/i18n/app_translations.dart';
import 'core/token_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _configureEasyLoading();
  runApp(const MyApp());
}

void _configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 1200)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 44.0
    ..radius = 12.0
    ..progressColor = const Color(0xFF1565C0)
    ..indicatorColor = const Color(0xFF1565C0)
    ..textColor = const Color(0xFF1565C0)
    ..backgroundColor = Colors.white
    ..maskColor = const Color(0xFF0D47A1).withValues(alpha: 0.10)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'app.title'.tr,
      initialBinding: AppBinding(),
      home: const AuthChecker(),
      getPages: AppPages.pages,
      theme: ThemeData(useMaterial3: true),
      translations: AppTranslations(),
      locale: AppTranslations.viVN,
      fallbackLocale: AppTranslations.viVN,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi'), Locale('en')],
      builder: EasyLoading.init(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: TokenStorage.instance.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigate to appropriate page after loading token
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final initialRoute = TokenStorage.instance.isAuthenticated
              ? Routes.dashboard
              : Routes.login;
          Get.offAllNamed(initialRoute);
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
