// ignore_for_file: non_constant_identifier_names

import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:flutter/material.dart';

class LeagueAdministratorProvider extends ChangeNotifier {
  LeagueAdministratorModel? league_administrator;

  LeagueAdministratorModel? get getLeagueAdministrator => league_administrator;

  void setAdministrator(LeagueAdministratorModel admin) {
    league_administrator = admin;
    notifyListeners();
  }

  void clearAdministrator() {
    league_administrator = null;
    notifyListeners();
  }

  bool get isLoggedIn => league_administrator != null;
}
