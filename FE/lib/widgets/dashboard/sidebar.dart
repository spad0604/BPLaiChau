import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../core/token_storage.dart';

enum SidebarItemKey { cases, createCase, stations, userManagement, banners }

class SidebarItem {
  final SidebarItemKey key;
  final String titleKey;
  final IconData icon;
  final String route;

  const SidebarItem({required this.key, required this.titleKey, required this.icon, required this.route});
}

class DashboardSidebar extends StatelessWidget {
  final SidebarItemKey active;
  final ValueChanged<SidebarItemKey>? onSelect;

  const DashboardSidebar({super.key, required this.active, this.onSelect});

  static const items = <SidebarItem>[
    SidebarItem(key: SidebarItemKey.cases, titleKey: 'sidebar.cases', icon: Icons.folder_outlined, route: Routes.caseList),
    SidebarItem(key: SidebarItemKey.createCase, titleKey: 'sidebar.createCase', icon: Icons.add_circle_outline, route: Routes.caseCreate),
    SidebarItem(key: SidebarItemKey.stations, titleKey: 'sidebar.stations', icon: Icons.apartment_outlined, route: Routes.stations),
    SidebarItem(key: SidebarItemKey.userManagement, titleKey: 'sidebar.userManagement', icon: Icons.people_outline, route: Routes.userManagement),
    SidebarItem(key: SidebarItemKey.banners, titleKey: 'sidebar.banners', icon: Icons.image_outlined, route: Routes.banners),
  ];

  @override
  Widget build(BuildContext context) {
    final role = (TokenStorage.instance.role ?? '');
    final visibleItems = items.where((it) {
      if (it.key == SidebarItemKey.banners) return role == 'super_admin';
      return true;
    }).toList();

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('sidebar.brandTitle'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text('sidebar.brandSubtitle'.tr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('sidebar.section'.tr, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: visibleItems.length,
              itemBuilder: (context, index) {
                final item = visibleItems[index];
                final isActive = item.key == active;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    leading: Icon(item.icon, size: 20, color: isActive ? const Color(0xFF1B4D3E) : Colors.grey.shade700),
                    title: Text(
                      item.titleKey.tr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? const Color(0xFF1B4D3E) : Colors.grey.shade800,
                      ),
                    ),
                    tileColor: isActive ? const Color(0xFFE8F3EF) : Colors.transparent,
                    onTap: () {
                      if (onSelect != null) {
                        onSelect!(item.key);
                        return;
                      }

                      if (Get.currentRoute != item.route) {
                        Get.offAllNamed(item.route);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: Colors.grey.shade200, child: const Icon(Icons.person, size: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(TokenStorage.instance.username ?? 'Nguyễn Văn A', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        role == 'super_admin' ? 'role.superAdmin'.tr : 'role.admin'.tr,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'common.logout'.tr,
                  onPressed: () async {
                    await TokenStorage.instance.clear();
                    Get.offAllNamed(Routes.login);
                  },
                  icon: const Icon(Icons.logout, size: 18),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
