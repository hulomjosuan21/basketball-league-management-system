// ignore_for_file: non_constant_identifier_names

import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:flutter/material.dart';

class LeagueAdministratorProvider extends ChangeNotifier {
LeagueAdministratorModel? _league_administrator;
  LeagueAdministratorModel? get getCurrentLeagueAdministrator =>
      _league_administrator;
  void setCurrentAdministrator(LeagueAdministratorModel admin) {
    _league_administrator = admin;
    notifyListeners();
  }

  void clearCurrentAdministrator() {
    _league_administrator = null;
    notifyListeners();
  }
}
