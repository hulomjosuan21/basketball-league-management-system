import 'package:bogoballers/core/models/league_model.dart';
import 'package:bogoballers/core/services/league_services.dart';
import 'package:flutter/material.dart';

class LeagueProvider extends ChangeNotifier {
  final List<LeagueModel> _leagueList = [];

  List<LeagueModel> get leagues => _leagueList;
  bool _hasFetchedLeagues = false;

  Future<void> fetchLeaguesOnce() async {
    if (_hasFetchedLeagues) return;

    final service = LeagueServices();
    final fetchedLeagues = await service.fetchLeagues();

    _leagueList
      ..clear()
      ..addAll(fetchedLeagues);
    _hasFetchedLeagues = true;
    notifyListeners();
  }

  void resetLeagueFetchedFlag() {
    _hasFetchedLeagues = false;
  }
}
