// ignore_for_file: non_constant_identifier_names

import 'package:bogoballers/core/models/player_model.dart';
import 'package:flutter/material.dart';

class PlayerProvider extends ChangeNotifier {
  PlayerModel? _player;
  PlayerModel? get getCurrentPlayer => _player;
  void setCurrentPlayer(PlayerModel player) {
    _player = player;
    notifyListeners();
  }

  void clearCurrentPlayer() {
    _player = null;
    notifyListeners();
  }
}
