import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../core/token_storage.dart';

enum SidebarItemKey { cases, createCase, stations, userManagement, banners }

class SidebarItem {
  final SidebarItemKey key;
  final String title;
  final IconData icon;
  final String route;

  const SidebarItem({required this.key, required this.title, required this.icon, required this.route});
}

class DashboardSidebar extends StatelessWidget {
  final SidebarItemKey active;
  final ValueChanged<SidebarItemKey>? onSelect;

  const DashboardSidebar({super.key, required this.active, this.onSelect});

  static const items = <SidebarItem>[
    SidebarItem(key: SidebarItemKey.cases, title: 'Danh sách chuyên án', icon: Icons.folder_outlined, route: Routes.caseList),
    SidebarItem(key: SidebarItemKey.createCase, title: 'Thêm chuyên án', icon: Icons.add_circle_outline, route: Routes.caseCreate),
    SidebarItem(key: SidebarItemKey.stations, title: 'Quản lý đồn biên phòng', icon: Icons.apartment_outlined, route: Routes.stations),
    SidebarItem(key: SidebarItemKey.userManagement, title: 'Quản lý cán bộ', icon: Icons.people_outline, route: Routes.userManagement),
    SidebarItem(key: SidebarItemKey.banners, title: 'Quản lý banner', icon: Icons.image_outlined, route: Routes.banners),
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
                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/vi/thumb/3/3e/Ph%C3%B9_hi%E1%BB%87u_B%E1%BB%99_%C4%91%E1%BB%99i_Bi%C3%AAn_ph%C3%B2ng_Vi%E1%BB%87t_Nam.webp/408px-Ph%C3%B9_hi%E1%BB%87u_B%E1%BB%99_%C4%91%E1%BB%99i_Bi%C3%AAn_ph%C3%B2ng_Vi%E1%BB%87t_Nam.webp.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BĐBP Lai Châu', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text('HỆ THỐNG QUẢN LÝ', style: TextStyle(fontSize: 11, color: Colors.grey)),
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
              child: Text('DANH MỤC', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
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
                      item.title,
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
                        role == 'super_admin' ? 'Quản trị tối cao' : 'Quản trị viên',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Đăng xuất',
                  onPressed: () => Get.offAllNamed(Routes.login),
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
