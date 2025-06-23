import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/services/team_creator_services.dart';
import 'package:bogoballers/core/services/team_service.dart';
import 'package:flutter/material.dart';

class TeamProvider extends ChangeNotifier {
  final List<TeamModel> _teams = [];

  List<TeamModel> get teams => _teams;

  Future<void> addTeam(TeamModel newTeam) async {
    final service = TeamCreatorServices();
    final response = await service.createNewTeam(newTeam);
    final team = response.payload;

    if (team == null) return;

    _teams.add(team);
    notifyListeners();
  }

  Future<void> fetchTeams(String user_id) async {
    final service = TeamService();
    final teams = await service.fetchTeamsByUserID(user_id) ?? [];

    if (teams.isNotEmpty) {
      _teams.addAll(teams);
      notifyListeners();
    }
  }

  Future<void> refetchTeams(String user_id) async {
    final service = TeamService();
    final teams = await service.fetchTeamsByUserID(user_id) ?? [];

    _teams
      ..clear()
      ..addAll(teams);
    notifyListeners();
  }

  void addTeams(List<TeamModel> newTeams) {
    _teams.addAll(newTeams);
    notifyListeners();
  }
}
