import 'package:bogoballers/client/player/screens/player_home_screen.dart';
import 'package:bogoballers/client/player/screens/player_profile_screen.dart';
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
          backgroundColor: appColors.gray100,
          indicatorColor: appColors.accent600,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Iconsax.home,
                color: controller.selectedIndex.value == 0
                    ? appColors.gray100
                    : null,
              ),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(
                Iconsax.people,
                color: controller.selectedIndex.value == 1
                    ? appColors.gray100
                    : null,
              ),
              label: "Team",
            ),
            NavigationDestination(
              icon: Icon(
                Iconsax.setting,
                color: controller.selectedIndex.value == 2
                    ? appColors.gray100
                    : null,
              ),
              label: "Settings",
            ),
            NavigationDestination(
              icon: Icon(
                Iconsax.user,
                color: controller.selectedIndex.value == 3
                    ? appColors.gray100
                    : null,
              ),
              label: "Profile",
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
