import 'package:bogoballers/core/constants/image_strings.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final List<SidebarItem> sidebarItems;
  final List<SidebarItem> sidebarFooterItems;
  final bool isCollapsed;

  const AppSidebar({
    super.key,
    required this.sidebarItems,
    required this.sidebarFooterItems,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      width: isCollapsed ? 70 : 220,
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
          // Logo Area
          Container(
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            child: ClipOval(
              child: Image.asset(
                ImageStrings.exampleTeamLogo,
                width: isCollapsed ? 30 : 50,
                height: isCollapsed ? 30 : 50,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.spaceSm),
                child: Column(
                  children: sidebarItems
                      .map(
                        (item) => SidebarItem(
                          label: item.label,
                          icon: item.icon,
                          selected: item.selected,
                          onTap: item.onTap,
                          subMenu: item.subMenu,
                          isCollapsed: isCollapsed,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          if (sidebarFooterItems.isNotEmpty)
            Container(
              width: double.infinity,
              height: 180,
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
                  child: Column(
                    children: sidebarFooterItems
                        .map(
                          (item) => SidebarItem(
                            label: item.label,
                            icon: item.icon,
                            selected: item.selected,
                            onTap: item.onTap,
                            subMenu: item.subMenu,
                            isCollapsed: isCollapsed,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final List<SubMenuItem>? subMenu;
  final bool isCollapsed;

  const SidebarItem({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.subMenu,
    this.isCollapsed = false,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? appColors.accent900 : Colors.transparent,
              borderRadius: BorderRadius.circular(Sizes.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: 20,
                    color: selected ? appColors.gray100 : appColors.gray900,
                  ),
                if (!isCollapsed) const SizedBox(width: Sizes.spaceSm),
                if (!isCollapsed)
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: selected ? appColors.gray100 : appColors.gray900,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                if (hasSubMenu && !isCollapsed)
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: selected ? appColors.gray100 : appColors.gray900,
                  ),
              ],
            ),
          ),
        ),
        if (hasSubMenu && selected && !isCollapsed)
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
                color: selected ? appColors.accent1100 : appColors.gray900,
                fontSize: Sizes.fontSizeSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
