// ignore_for_file: non_constant_identifier_names
import 'package:bogoballers/core/models/league_model.dart';
import 'package:bogoballers/core/models/player_model.dart';
import 'package:dio/dio.dart';

class PlayerTeamModel {
  late String player_team_id;
  String player_id;
  String team_id;
  late bool is_ban;
  late PlayerModel player;
  late DateTime created_at;
  late DateTime updated_at;

  PlayerTeamModel({
    required this.player_team_id,
    required this.player_id,
    required this.team_id,
    required this.is_ban,
    required this.player,
    required this.created_at,
    required this.updated_at,
  });

  PlayerTeamModel.create({required this.player_id, required this.team_id});

  factory PlayerTeamModel.fromJson(Map<String, dynamic> json) {
    return PlayerTeamModel(
      player_team_id: json['player_team_id'],
      player_id: json['player_id'],
      team_id: json['team_id'],
      is_ban: json['is_ban'],
      player: json['player'],
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'player_team_id': player_team_id,
      'player_id': player_id,
      'team_id': team_id,
      'is_ban': is_ban,
      'player': player.toJson(),
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}

class TeamModel {
  late String team_id;
  String user_id;
  String team_name;
  String team_address;
  String contact_number;
  String team_motto;
  late String team_logo_url;
  late int championships_won;
  String coach_name;
  String? assistant_coach_name;
  late int total_wins;
  late int total_losses;
  late bool is_recruiting;
  String? team_captain_id;
  PlayerTeamModel? team_captain;
  LeagueModel? active_league;
  List<PlayerModel> players;

  late MultipartFile team_logo_image;
  late DateTime created_at;
  late DateTime updated_at;

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      team_id: json['team_id'],
      user_id: json['user_id'],
      active_league: json['active_league'] ?? null,
      team_name: json['team_name'],
      team_address: json['team_address'],
      contact_number: json['contact_number'],
      team_motto: json['team_motto'],
      team_logo_url: json['team_logo_url'],
      championships_won: json['championships_won'],
      coach_name: json['coach_name'],
      assistant_coach_name: json['assistant_coach_name'] ?? null,
      team_captain: json['team_captain'] ?? null,
      total_wins: json['total_wins'],
      total_losses: json['total_losses'] ?? 0,
      is_recruiting: json['is_recruiting'] ?? 0,
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'team_id': team_id,
      'user_id': user_id,
      'active_league': active_league.toString(),
      'team_name': team_name,
      'team_address': team_address,
      'contact_number': contact_number,
      'team_motto': team_motto,
      'team_logo_url': team_logo_url,
      'championships_won': championships_won,
      'coach_name': coach_name,
      'assistant_coach_name': assistant_coach_name,
      'team_captain': team_captain?.toMap() ?? null,
      'players': players.toList(),
      'total_wins': total_wins,
      'is_recruiting': is_recruiting,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }

  TeamModel({
    required this.team_id,
    required this.user_id,
    required this.team_name,
    required this.team_address,
    required this.contact_number,
    required this.team_motto,
    required this.coach_name,
    this.active_league,
    this.assistant_coach_name,
    required this.team_logo_url,
    required this.championships_won,
    this.team_captain_id,
    required this.created_at,
    required this.updated_at,
    required this.is_recruiting,
    this.team_captain,
    this.players = const [],
    required this.total_wins,
    required this.total_losses,
  });

  TeamModel.create({
    required this.user_id,
    required this.team_name,
    required this.team_address,
    required this.contact_number,
    required this.team_motto,
    required this.coach_name,
    this.assistant_coach_name,
    required this.team_logo_image,
    this.players = const [],
  });

  get imageUrl => null;

  FormData toFormDataForCreation() {
    final formMap = {
      'user_id': user_id,
      'team_name': team_name,
      'team_address': team_address,
      'contact_number': contact_number,
      'team_motto': team_motto,
      'coach_name': coach_name,
      'assistant_coach_name': assistant_coach_name,
      'team_logo_image': team_logo_image,
    };

    return FormData.fromMap(formMap);
  }
}
