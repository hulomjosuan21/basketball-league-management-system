import 'package:bogoballers/client/widgets/navigation_controllers.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart'; // if you're using GetX for controller

class NavigationDestinationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final Rx<int> selectedIndex;

  const NavigationDestinationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => NavigationDestination(
        icon: Icon(
          icon,
          color: selectedIndex.value == index
              ? context.appColors.accent900
              : null,
        ),
        label: label,
      ),
    );
  }
}

class PlayerBottomNavigationMenu extends StatelessWidget {
  const PlayerBottomNavigationMenu({super.key, required this.controller});

  final PlayerScreenNavigationController controller;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return NavigationBar(
      height: 68,
      backgroundColor: appColors.gray100,
      indicatorColor: appColors.accent600,
      elevation: 0,
      selectedIndex: controller.selectedIndex.value,
      onDestinationSelected: (index) => controller.selectedIndex.value = index,
      destinations: [
        NavigationDestinationItem(
          icon: Iconsax.home,
          label: "Home",
          index: 0,
          selectedIndex: controller.selectedIndex,
        ),
        NavigationDestinationItem(
          icon: Iconsax.people,
          label: "Team",
          index: 1,
          selectedIndex: controller.selectedIndex,
        ),
        NavigationDestinationItem(
          icon: Iconsax.setting,
          label: "Settings",
          index: 2,
          selectedIndex: controller.selectedIndex,
        ),
        NavigationDestinationItem(
          icon: Iconsax.user,
          label: "Profile",
          index: 3,
          selectedIndex: controller.selectedIndex,
        ),
      ],
    );
  }
}

class TeamCreatorBottomNavigationMenu extends StatefulWidget {
  const TeamCreatorBottomNavigationMenu({super.key, required this.controller});

  final TeamCreatorScreenNavigationController controller;

  @override
  State<TeamCreatorBottomNavigationMenu> createState() =>
      _TeamCreatorBottomNavigationMenuState();
}

class _TeamCreatorBottomNavigationMenuState
    extends State<TeamCreatorBottomNavigationMenu> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return NavigationBar(
      height: 68,
      backgroundColor: appColors.gray100,
      indicatorColor: appColors.accent600,
      elevation: 0,
      selectedIndex: widget.controller.selectedIndex.value,
      onDestinationSelected: (index) =>
          widget.controller.selectedIndex.value = index,
      destinations: [
        NavigationDestinationItem(
          icon: Iconsax.home,
          label: "Home",
          index: 0,
          selectedIndex: widget.controller.selectedIndex,
        ),
        NavigationDestinationItem(
          icon: Iconsax.people,
          label: "Team",
          index: 1,
          selectedIndex: widget.controller.selectedIndex,
        ),
      ],
    );
  }
}
