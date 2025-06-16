import 'package:bogoballers/client/player/player_main_screen.dart';
import 'package:bogoballers/core/theme/theme.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class ClientMaterialScreen extends StatelessWidget {
  const ClientMaterialScreen({super.key});

  Future<bool> checkIfUserIsLoggedInAsync() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final loadingScreen = MaterialApp(
      title: 'BogoBallers',
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

        return MaterialApp(
          title: 'BogoBallers',
          theme: lightTheme(context),
          home: PlayerMainScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
