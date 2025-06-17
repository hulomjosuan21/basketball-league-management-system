import 'package:bogoballers/client/player/screens/player_home_screen.dart';
import 'package:bogoballers/client/player/screens/player_profile_screen.dart';
import 'package:bogoballers/client/player/widgets/bottomNavigation_item.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class PlayerMainScreen extends StatelessWidget {
  const PlayerMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlayerScreenNavigationController());
    final appColors = context.appColors;

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 68,
          backgroundColor: appColors.gray100,
          indicatorColor: appColors.accent600,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
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
        ),
      ),
    );
  }
}

class PlayerScreenNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    PlayerHomeScreen(),
    Container(color: Colors.blue),
    Container(color: Colors.blueAccent),
    PlayerProfileScreen(),
  ];
}
