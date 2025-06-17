// ignore_for_file: non_constant_identifier_names
import 'package:bogoballers/core/models/user.dart';
import 'package:flutter/material.dart';

class TeamCreatorProvider extends ChangeNotifier {
  UserModel? _team_creator;
  UserModel? get getCurrentTeamCreator => _team_creator;
  void setCurrentTeamCreator(UserModel team_creator) {
    _team_creator = team_creator;
    notifyListeners();
  }

  void clearCurrentTeamCreator() {
    _team_creator = null;
    notifyListeners();
  }
}
