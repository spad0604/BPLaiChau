import 'package:flutter/material.dart';
import 'sidebar.dart';

class DashboardLayout extends StatelessWidget {
  final SidebarItemKey active;
  final Widget child;
  final PreferredSizeWidget? appBar;
  final ValueChanged<SidebarItemKey>? onSelect;

  const DashboardLayout({
    super.key,
    required this.active,
    required this.child,
    this.appBar,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: appBar,
      body: Row(
        children: [
          DashboardSidebar(active: active, onSelect: onSelect),
          Expanded(child: child),
        ],
      ),
    );
  }
}
