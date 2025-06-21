import 'package:bogoballers/administrator/contents/bracket_structure_content.dart';
import 'package:bogoballers/administrator/contents/dashboard_content.dart';
import 'package:bogoballers/administrator/contents/league_content/league_content.dart';
import 'package:bogoballers/administrator/widgets/header.dart';
import 'package:bogoballers/administrator/widgets/sidebar.dart';
import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdministratorScreenNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final RxBool showSidebar = true.obs;

  final contents = [
    const DashboardContent(),
    LeagueContent(),
    const Center(child: Text('Account Page')),
  ];
}

class LeagueAdministratorMainScreen extends StatelessWidget {
  const LeagueAdministratorMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.put(AdministratorScreenNavigationController());

    final entity = getIt<EntityState<LeagueAdministratorModel>>().entity;

    if (entity != null) {
      print("Current Administrator: ${entity.toJson()}");
    }

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 600;
          navController.showSidebar.value = !isSmallScreen;

          final sidebarItems = [
            SidebarItem(
              label: 'Dashboard',
              icon: Icons.dashboard,
              selected: navController.selectedIndex.value == 0,
              onTap: () => navController.selectedIndex.value = 0,
            ),
            SidebarItem(
              label: 'League',
              icon: Icons.analytics,
              selected: navController.selectedIndex.value == 1,
              onTap: () => navController.selectedIndex.value = 1,
              subMenu: [
                SubMenuItem(
                  label: 'Bracket Structure',
                  selected: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BracketStructureContent(),
                    ),
                  ),
                ),
                SubMenuItem(label: 'More', selected: false, onTap: () {}),
              ],
            ),
          ];

          final sidebarFooterItems = [
            SidebarItem(
              label: 'Settings',
              icon: Icons.settings,
              selected: navController.selectedIndex.value == 2,
              onTap: () => navController.selectedIndex.value = 2,
              subMenu: [
                SubMenuItem(label: 'About Us', onTap: () {}),
                SubMenuItem(label: 'App Settings', onTap: () {}),
              ],
            ),
          ];

          return Row(
            children: [
              if (navController.showSidebar.value)
                AppSidebar(
                  sidebarItems: sidebarItems,
                  sidebarFooterItems: sidebarFooterItems,
                ),
              Expanded(
                child: Column(
                  children: [
                    AppHeader(
                      showSidebar: navController.showSidebar.value,
                      onToggleSidebar: () => navController.showSidebar.value =
                          !navController.showSidebar.value,
                    ),
                    Expanded(
                      child: Obx(
                        () => navController
                            .contents[navController.selectedIndex.value],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
