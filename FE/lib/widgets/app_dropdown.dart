import 'package:flutter/material.dart';

class AppDropdownItem<T> {
  final T value;
  final String label;

  const AppDropdownItem({required this.value, required this.label});
}

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final T value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T> onChanged;
  final double radius;

  const AppDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.radius = 10,
  });

  static const _primary = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          const SizedBox(height: 6),
        ],
        GestureDetector(
          key: key,
          onTap: () async {
            final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
            final box = key.currentContext!.findRenderObject() as RenderBox;
            final position = box.localToGlobal(Offset.zero, ancestor: overlay);
            final rect = RelativeRect.fromLTRB(
              position.dx,
              position.dy + box.size.height,
              overlay.size.width - position.dx - box.size.width,
              overlay.size.height - position.dy,
            );

            final selected = await showMenu<T>(
              context: context,
              position: rect,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
              items: _menuItems(context),
            );

            if (selected != null && selected != value) onChanged(selected);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _labelOf(value),
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PopupMenuEntry<T>> _menuItems(BuildContext context) {
    final entries = <PopupMenuEntry<T>>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      entries.add(
        PopupMenuItem<T>(
          value: item.value,
          child: Row(
            children: [
              Expanded(child: Text(item.label, style: const TextStyle(fontSize: 13))),
              if (item.value == value) const Icon(Icons.check, size: 18, color: _primary),
            ],
          ),
        ),
      );
      if (i != items.length - 1) {
        entries.add(const PopupMenuDivider(height: 1));
      }
    }
    return entries;
  }

  String _labelOf(T v) {
    for (final it in items) {
      if (it.value == v) return it.label;
    }
    return v.toString();
  }
}
