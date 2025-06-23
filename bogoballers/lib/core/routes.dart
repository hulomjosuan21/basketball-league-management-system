import 'package:bogoballers/administrator/administrator_main_screen.dart';
import 'package:bogoballers/administrator/screen/administrator_login_screen.dart';
import 'package:bogoballers/administrator/screen/administrator_register_screen.dart';
import 'package:bogoballers/client/player/player_main_screen.dart';
import 'package:bogoballers/client/screens/client_login_screen.dart';
import 'package:bogoballers/client/team_creator/team_creator_main_screen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/client/login/screen': (context) => ClientLoginScreen(),
  '/team-creator/home/screen': (context) => TeamCreatorMainScreen(),
  '/player/home/screen': (context) => PlayerMainScreen(),
  '/administrator/login/sreen': (context) => AdministratorLoginScreen(),
  '/administrator/main/screen': (context) => LeagueAdministratorMainScreen(),
  '/administrator/register/screen': (context) => AdministratorRegisterScreen(),
};
