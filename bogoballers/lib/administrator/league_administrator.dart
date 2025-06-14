import 'package:bogoballers/administrator/contents/bracket_structure_content.dart';
import 'package:bogoballers/administrator/contents/dashboard_content.dart';
import 'package:bogoballers/administrator/contents/league_content/league_content.dart';
import 'package:bogoballers/administrator/screen/administrator_login_screen.dart';
import 'package:bogoballers/administrator/widgets/header.dart';
import 'package:bogoballers/administrator/widgets/sidebar.dart';
import 'package:bogoballers/core/hive/app_box.dart';
import 'package:bogoballers/core/providers/league_adminstrator_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AdministratorScreenNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

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
    final showSidebar = RxBool(true);

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 600;
          showSidebar.value = !isSmallScreen;

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
                SubMenuItem(
                  label: 'More',
                  selected: false,
                  onTap: () {
                    final provider = Provider.of<LeagueAdministratorProvider>(
                      context,
                      listen: false,
                    );
                    provider.clearCurrentAdministrator();
                    AppBox.clearAllInBox(AppBox.accessTokenBox);
                  },
                ),
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
              if (showSidebar.value)
                AppSidebar(
                  sidebarItems: sidebarItems,
                  sidebarFooterItems: sidebarFooterItems,
                ),
              Expanded(
                child: Column(
                  children: [
                    Consumer<LeagueAdministratorProvider>(
                      builder: (context, provider, _) {
                        if (provider.getCurrentLeagueAdministrator == null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Session Expired'),
                                content: const Text(
                                  'Please log in again to continue.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdministratorLoginScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          });
                          return const SizedBox.shrink();
                        }

                        return AppHeader(
                          showSidebar: showSidebar.value,
                          onToggleSidebar: () =>
                              showSidebar.value = !showSidebar.value,
                          leagueAdministrator:
                              provider.getCurrentLeagueAdministrator!,
                        );
                      },
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
