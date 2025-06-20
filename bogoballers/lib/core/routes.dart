import 'package:bogoballers/client/player/player_main_screen.dart';
import 'package:bogoballers/client/screens/client_login_screen.dart';
import 'package:bogoballers/client/team_creator/team_creator_main_screen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> clientRoutes = {
  '/client/login': (context) => ClientLoginScreen(),
  '/team-creator/home': (context) => TeamCreatorMainScreen(),
  '/player/home': (context) => PlayerMainScreen(),
};
