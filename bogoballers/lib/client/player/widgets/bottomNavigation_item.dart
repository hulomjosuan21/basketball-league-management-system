import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // if you're using GetX for controller

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
              ? context.appColors.gray100
              : null,
        ),
        label: label,
      ),
    );
  }
}
