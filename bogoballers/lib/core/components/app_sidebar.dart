import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class SidebarItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final List<SubMenuItem>? subMenu;

  const SidebarItem({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.subMenu,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final hasSubMenu = subMenu != null && subMenu!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: selected ? appColors.gray300 : Colors.transparent,
            child: Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: 20,
                    color: selected ? appColors.accent900 : appColors.gray700,
                  ),
                if (icon != null) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? appColors.accent900 : appColors.gray700,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (hasSubMenu)
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: appColors.gray500,
                  ),
              ],
            ),
          ),
        ),
        if (hasSubMenu && selected)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(children: subMenu!),
          ),
      ],
    );
  }
}

class SubMenuItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const SubMenuItem({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? appColors.gray300 : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Icon(Icons.circle, size: 6, color: appColors.gray500),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? appColors.accent900 : appColors.gray600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelectIndex;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      width: 250,
      color: appColors.gray100,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: appColors.accent900,
            child: Text(
              'League Admin',
              style: TextStyle(
                color: appColors.accent100,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SidebarItem(
                    label: 'Dashboard',
                    icon: Icons.dashboard,
                    selected: selectedIndex == 0,
                    onTap: () => onSelectIndex(0),
                  ),
                  SidebarItem(
                    label: 'Settings',
                    icon: Icons.settings,
                    selected: selectedIndex == 1,
                    onTap: () => onSelectIndex(1),
                    subMenu: [
                      SubMenuItem(
                        label: 'Account',
                        selected: false,
                        onTap: () => debugPrint('Account tapped'),
                      ),
                      SubMenuItem(
                        label: 'Privacy',
                        selected: false,
                        onTap: () => debugPrint('Privacy tapped'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: appColors.gray400)),
            ),
            child: Text(
              'v1.0.0',
              style: TextStyle(fontSize: 12, color: appColors.gray600),
            ),
          ),
        ],
      ),
    );
  }
}
