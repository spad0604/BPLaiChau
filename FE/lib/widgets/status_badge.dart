import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    // TODO: Map exact status strings from BE
    switch (status.toLowerCase()) {
      case 'khẩn cấp':
      case 'urgent':
        bg = Colors.red.shade50;
        fg = Colors.red;
        break;
      case 'đang thụ lý':
      case 'proccessing':
        bg = Colors.green.shade50;
        fg = Colors.green;
        break;
      case 'chờ phê duyệt':
      case 'pending':
        bg = Colors.orange.shade50;
        fg = Colors.orange;
        break;
      case 'đã kết thúc':
      case 'closed':
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
        break;
      default:
        bg = Colors.blue.shade50;
        fg = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
