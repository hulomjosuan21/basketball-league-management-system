import 'package:bogoballers/client/widgets/bottom_navigation.dart';
import 'package:bogoballers/client/widgets/navigation_controllers.dart';
import 'package:bogoballers/core/constants/sizes.dart';
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
          indicatorColor: Colors.transparent,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: appColors.accent900,
                fontWeight: FontWeight.w500,
                fontSize: Sizes.fontSizeSm,
              );
            }
            return TextStyle(
              color: appColors.gray1100,
              fontWeight: FontWeight.w500,
              fontSize: Sizes.fontSizeSm,
            );
          }),
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
