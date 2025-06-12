import 'package:bogoballers/administrator/contents/bracket_structure_content.dart';
import 'package:bogoballers/administrator/contents/dashboard_content.dart';
import 'package:bogoballers/administrator/contents/league_content.dart';
import 'package:bogoballers/administrator/screen/administrator_login_screen.dart';
import 'package:bogoballers/administrator/screen/administrator_register_screen.dart';
import 'package:bogoballers/core/components/app_header.dart';
import 'package:bogoballers/core/components/app_sidebar.dart';
import 'package:bogoballers/core/hive/app_box.dart';
import 'package:bogoballers/core/providers/league_adminstrator_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeagueAdministratorMainScreen extends StatefulWidget {
  const LeagueAdministratorMainScreen({super.key});

  @override
  State<LeagueAdministratorMainScreen> createState() =>
      _LeagueAdministratorMainScreenState();
}

class _LeagueAdministratorMainScreenState
    extends State<LeagueAdministratorMainScreen> {
  bool showSidebar = true;
  int selectedIndex = 0;
  double previousScreenWidth = 0;

  final List<Widget> contents = [
    const DashboardContent(),
    LeagueContent(),
    const Center(child: Text('Account Page')),
  ];

  void toggleSidebar() {
    setState(() => showSidebar = !showSidebar);
  }

  void onSelectIndex(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    if (screenWidth != previousScreenWidth) {
      previousScreenWidth = screenWidth;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          showSidebar = !isSmallScreen;
        });
      });
    }

    final List<SidebarItem> sidebarItems = [
      SidebarItem(
        label: 'Dashboard',
        icon: Icons.dashboard,
        selected: selectedIndex == 0,
        onTap: () => onSelectIndex(0),
      ),
      SidebarItem(
        label: 'League',
        icon: Icons.analytics,
        selected: selectedIndex == 1,
        onTap: () => onSelectIndex(1),
        subMenu: [
          SubMenuItem(
            label: 'Bracket Structure',
            selected: selectedIndex == 2,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return BracketStructureContent();
                  },
                ),
              );
            },
          ),
          SubMenuItem(
            label: 'More',
            selected: false,
            onTap: () {
              final leagueAdministratorProvider =
                  Provider.of<LeagueAdministratorProvider>(
                    context,
                    listen: false,
                  );
              leagueAdministratorProvider.clearCurrentAdministrator();
              AppBox.clearAllInBox(AppBox.accessTokenBox);
            },
          ),
        ],
      ),
    ];

    final List<SidebarItem> sidebarFooterItems = [
      SidebarItem(
        label: 'Settings',
        icon: Icons.dashboard,
        selected: selectedIndex == 2,
        onTap: () => onSelectIndex(2),
        subMenu: [
          SubMenuItem(label: 'About Us', onTap: () {}),
          SubMenuItem(label: 'App Settings', onTap: () {}),
        ],
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (showSidebar)
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
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
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
                                        builder: (context) =>
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
                        showSidebar: showSidebar,
                        onToggleSidebar: toggleSidebar,
                        leagueAdministrator:
                            provider.getCurrentLeagueAdministrator!,
                      );
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: contents[selectedIndex],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
