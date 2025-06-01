import 'package:bogoballers/administrator/league_administrator.dart';
import 'package:bogoballers/administrator/screen/administrator_auth.dart';
import 'package:bogoballers/core/theme/theme.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class AdministratorMaterialScreen extends StatelessWidget {
  const AdministratorMaterialScreen({super.key});

  Future<bool> checkIfUserIsLoggedInAsync() async {
    await Future.delayed(const Duration(seconds: 2));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final loadingScreen = MaterialApp(
      title: 'Administrator App',
      theme: lightTheme(context),
      home: Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: context.appColors.accent900),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );

    return FutureBuilder<bool>(
      future: checkIfUserIsLoggedInAsync(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingScreen;
        }

        final isAuthenticated = snapshot.data ?? false;

        return MaterialApp(
          title: 'Administrator App',
          theme: lightTheme(context),
          home: isAuthenticated
              ? const LeagueAdministratorMainScreen()
              : const AdministratorRegisterScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
