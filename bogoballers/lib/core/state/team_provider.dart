import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/services/team_service.dart';
import 'package:flutter/material.dart';

class TeamProvider extends ChangeNotifier {
  final List<TeamModel> _teams = [];
  bool _hasFetched = false;
  List<TeamModel> get teams => _teams;

  Future<void> addTeam(TeamModel newTeam) async {
    _teams.add(newTeam);
    notifyListeners();
  }

  Future<void> fetchTeamsOnce(String userId) async {
    if (_hasFetched) return;

    final service = TeamService();
    final fetchedTeams = await service.fetchTeamsByUserID(userId) ?? [];

    _teams
      ..clear()
      ..addAll(fetchedTeams);
    _hasFetched = true;
    notifyListeners();
  }

  void resetFetchedFlag() {
    _hasFetched = false;
  }

  Future<void> fetchTeams(String user_id) async {
    final service = TeamService();
    final teams = await service.fetchTeamsByUserID(user_id) ?? [];

    if (teams.isNotEmpty) {
      _teams.addAll(teams);
      notifyListeners();
    }
  }

  Future<void> refreshTeams(String userId) async {
    _hasFetched = false;
    await fetchTeamsOnce(userId);
  }

  void addTeams(List<TeamModel> newTeams) {
    _teams.addAll(newTeams);
    notifyListeners();
  }

  void editTeam(TeamModel updatedTeam) {
    final index = _teams.indexWhere((t) => t.team_id == updatedTeam.team_id);
    if (index != -1) {
      _teams[index] = updatedTeam;
      notifyListeners();
    }
  }
}
