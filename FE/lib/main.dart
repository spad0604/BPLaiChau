import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'core/app_binding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX Starter',
      initialBinding: AppBinding(),
      initialRoute: Routes.login,
      getPages: AppPages.pages,
      theme: ThemeData(useMaterial3: true),
    );
  }
}
