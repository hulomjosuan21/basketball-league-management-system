import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final bool showSidebar;
  final VoidCallback onToggleSidebar;

  const AppHeader({
    super.key,
    required this.showSidebar,
    required this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      height: 34,
      width: double.infinity,
      color: appColors.accent900,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: appColors.accent100, size: 14),
            onPressed: onToggleSidebar,
          ),
          const SizedBox(width: 8),
          Text(
            "League Admin",
            style: TextStyle(
              color: appColors.accent100,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
