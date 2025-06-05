import 'package:bogoballers/administrator/league_administrator.dart';
import 'package:bogoballers/administrator/screen/administrator_auth.dart';
import 'package:bogoballers/core/components/loading.dart';
import 'package:bogoballers/core/theme/theme.dart';
import 'package:flutter/material.dart';

class AdministratorMaterialScreen extends StatelessWidget {
  const AdministratorMaterialScreen({super.key});

  Future<bool> checkIfUserIsLoggedInAsync() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkIfUserIsLoggedInAsync(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return appFullScreenLoading(context);
        }

        final isAuthenticated = snapshot.data ?? false;

        return MaterialApp(
          title: 'Administrator App',
          theme: lightTheme(context),
          home: const LeagueAdministratorMainScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
