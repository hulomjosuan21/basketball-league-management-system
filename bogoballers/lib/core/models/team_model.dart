// ignore_for_file: non_constant_identifier_names

import 'package:bogoballers/core/models/league_model.dart';
import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/models/user.dart';

class TeamModel {
  String? team_id;
  String user_id;
  String team_name;
  String team_address;
  late int championships_won;
  String? coach_name;

  UserModel? user;
  DateTime? created_at;
  DateTime? updated_at;

  List<PlayerModel>? players;
  List<LeagueModel>? league;

  TeamModel({
    this.team_id,
    required this.user_id,
    required this.team_name,
    required this.team_address,
    required this.championships_won,
    this.coach_name,
    this.user,
    this.players,
    this.league,
    this.created_at,
    this.updated_at,
  });

  TeamModel.create({
    required this.user_id,
    required this.team_name,
    required this.team_address,
    this.coach_name,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      team_id: json['team_id'],
      user_id: json['user_id'],
      team_name: json['team_name'],
      team_address: json['team_address'],
      championships_won: json['championships_won'],
      coach_name: json['coach_name'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      players: json['players'] != null
          ? (json['players'] as List)
                .map((e) => PlayerModel.fromJson(e))
                .toList()
          : null,
      league: json['league'] != null
          ? (json['league'] as List)
                .map((e) => LeagueModel.fromJson(e))
                .toList()
          : null,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': team_id,
      'user_id': user_id,
      'team_name': team_name,
      'team_address': team_address,
      'championships_won': championships_won,
      'coach_name': coach_name,
      'user': user?.toJson(),
      'players': players?.map((e) => e.toJson()).toList(),
      'created_at': created_at?.toIso8601String(),
      'updated_at': updated_at?.toIso8601String(),
    };
  }

  TeamModel copyWith({
    String? team_id,
    String? user_id,
    String? team_name,
    String? team_address,
    int? championships_won,
    String? coach_name,
    UserModel? user,
    List<PlayerModel>? players,
    List<LeagueModel>? league,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return TeamModel(
      team_id: team_id ?? this.team_id,
      user_id: user_id ?? this.user_id,
      team_name: team_name ?? this.team_name,
      team_address: team_address ?? this.team_address,
      championships_won: championships_won ?? this.championships_won,
      coach_name: coach_name ?? this.coach_name,
      user: user ?? this.user,
      players: players ?? this.players,
      league: league ?? this.league,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }
}
