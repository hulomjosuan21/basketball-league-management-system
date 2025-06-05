import 'package:bogoballers/core/components/app_header.dart';
import 'package:bogoballers/core/components/app_sidebar.dart';
import 'package:flutter/material.dart';

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

  final List<Widget> pages = const [
    Center(child: Text('Dashboard Page')),
    Center(child: Text('Settings Page')),
    Center(child: Text('Account Page')),
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
        label: 'Settings',
        icon: Icons.settings,
        selected: selectedIndex == 1,
        onTap: () => onSelectIndex(1),
        subMenu: [
          SubMenuItem(
            label: 'Account',
            selected: selectedIndex == 2,
            onTap: () => onSelectIndex(2),
          ),
          SubMenuItem(
            label: 'Privacy',
            selected: false,
            onTap: () => debugPrint('Privacy tapped'),
          ),
        ],
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (showSidebar) AppSidebar(sidebarItems: sidebarItems),
            Expanded(
              child: Column(
                children: [
                  AppHeader(
                    showSidebar: showSidebar,
                    onToggleSidebar: toggleSidebar,
                  ),
                  Expanded(
                    child: SingleChildScrollView(child: pages[selectedIndex]),
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
