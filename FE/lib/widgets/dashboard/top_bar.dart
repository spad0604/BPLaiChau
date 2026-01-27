import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/i18n/app_translations.dart';

class DashboardTopBar extends StatelessWidget {
  final String breadcrumb;
  final String title;

  const DashboardTopBar({super.key, required this.breadcrumb, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(breadcrumb, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 6),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          const SizedBox(width: 8),
          IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline)),
          const SizedBox(width: 8),
          PopupMenuButton<Locale>(
            tooltip: 'Language',
            onSelected: (loc) => Get.updateLocale(loc),
            itemBuilder: (_) => const [
              PopupMenuItem(value: AppTranslations.viVN, child: Text('Tiếng Việt')),
              PopupMenuItem(value: AppTranslations.enUS, child: Text('English')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(Icons.language, size: 18),
                  const SizedBox(width: 6),
                  Text(Get.locale?.languageCode.toUpperCase() ?? 'VI', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
