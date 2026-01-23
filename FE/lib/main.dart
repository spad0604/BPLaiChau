import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX Starter',
      initialRoute: Routes.HOME,
      getPages: AppPages.pages,
      theme: ThemeData(useMaterial3: true),
    );
  }
}
