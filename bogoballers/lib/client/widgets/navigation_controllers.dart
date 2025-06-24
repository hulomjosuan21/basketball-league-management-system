import 'package:bogoballers/client/screens/notification_screen.dart';
import 'package:bogoballers/client/screens/player_home_screen.dart';
import 'package:bogoballers/client/screens/player_profile_screen.dart';
import 'package:bogoballers/client/screens/team_creator_home_screen.dart';
import 'package:bogoballers/client/screens/team_creator_list_team_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerScreenNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    PlayerHomeScreen(),
    Container(color: Colors.blue),
    Container(color: Colors.blueAccent),
    PlayerProfileScreen(),
  ];
}

class TeamCreatorScreenNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    TeamCreatorHomeScreen(),
    TeamCreatorTeamListScreen(),
    NotificationScreen(),
  ];
}
