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

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (showSidebar)
              AppSidebar(
                selectedIndex: selectedIndex,
                onSelectIndex: onSelectIndex,
              ),
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
