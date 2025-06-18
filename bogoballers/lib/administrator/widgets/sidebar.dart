import 'package:bogoballers/core/constants/sizes.dart';
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
            decoration: BoxDecoration(
              color: selected ? appColors.gray300 : Colors.transparent,
              borderRadius: BorderRadius.circular(Sizes.radiusMd),
            ),
            child: Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: 20,
                    color: selected ? appColors.accent900 : appColors.gray700,
                  ),
                if (icon != null) const SizedBox(width: Sizes.spaceSm),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? appColors.gray1000 : appColors.gray700,
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
          borderRadius: BorderRadius.circular(Sizes.radiusSm),
        ),
        child: Row(
          children: [
            const SizedBox(width: Sizes.spaceXs),
            Icon(Icons.circle, size: 6, color: appColors.gray500),
            const SizedBox(width: Sizes.spaceSm),
            Text(
              label,
              style: TextStyle(
                color: selected ? appColors.accent900 : appColors.gray600,
                fontSize: Sizes.fontSizeSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppSidebar extends StatelessWidget {
  final List<SidebarItem> sidebarItems;
  final List<SidebarItem> sidebarFooterItems;
  const AppSidebar({
    super.key,
    required this.sidebarItems,
    required this.sidebarFooterItems,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: appColors.gray100,
        border: Border(
          right: BorderSide(
            width: Sizes.borderWidthSm,
            color: appColors.gray600,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(Sizes.spaceMd),
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: appColors.gray100,
              border: Border(
                bottom: BorderSide(
                  width: Sizes.borderWidthSm,
                  color: appColors.gray600,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.spaceSm),
                child: Column(children: sidebarItems),
              ),
            ),
          ),

          // Sidebar footer
          if (sidebarFooterItems.isNotEmpty)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: appColors.gray600,
                    width: Sizes.borderWidthSm,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(Sizes.spaceSm),
                  child: Column(children: sidebarFooterItems),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
