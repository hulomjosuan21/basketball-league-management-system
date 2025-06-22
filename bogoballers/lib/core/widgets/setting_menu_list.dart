import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class SettingsMenuList extends StatefulWidget {
  final List<SettingsMenuItem> items;

  const SettingsMenuList({super.key, required this.items});

  @override
  State<SettingsMenuList> createState() => _SettingsMenuListState();
}

class _SettingsMenuListState extends State<SettingsMenuList> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final appColor = context.appColors;
    return Column(
      children: widget.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isExpanded = _expandedIndex == index;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Sizes.spaceXs),
            Container(
              decoration: BoxDecoration(
                color: appColor.gray100,
                border: Border.all(color: appColor.gray600, width: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      if (item.isExpandable) {
                        setState(() {
                          _expandedIndex = isExpanded ? null : index;
                        });
                      } else if (item.isNavigable) {
                        item.onTap?.call();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(item.icon, color: appColor.gray1000),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              item.label,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Icon(
                            item.isExpandable
                                ? (isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more)
                                : Icons.chevron_right,
                            color: appColor.gray1000,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (item.isExpandable && isExpanded)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: item.content ?? const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class SettingsMenuItem {
  final IconData icon;
  final String label;
  final Widget? content; // for expandable
  final VoidCallback? onTap; // for go-to

  const SettingsMenuItem({
    required this.icon,
    required this.label,
    this.content,
    this.onTap,
  });

  bool get isExpandable => content != null;
  bool get isNavigable => onTap != null;
}
