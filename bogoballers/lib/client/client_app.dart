import 'package:bogoballers/administrator/league_administrator.dart';
import 'package:bogoballers/administrator/screen/administrator_login_screen.dart';
import 'package:bogoballers/client/screens/client_auth_screen.dart';
import 'package:bogoballers/client/screens/client_login_screen.dart';
import 'package:bogoballers/core/theme/theme.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class ClientMaterialScreen extends StatelessWidget {
  ClientMaterialScreen({super.key});

  Future<bool> checkIfUserIsLoggedInAsync() async {
    return false;
  }

  final Map<String, WidgetBuilder> clientRoutes = {
    '/client/login': (context) => ClientLoginScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BogoBallers',
      theme: lightTheme(context),
      routes: clientRoutes,
      home: ClientLoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
