// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:dio/dio.dart';

class LeagueModel {
  late String league_id;
  String league_administrator_id;
  String league_title;
  double league_budget;
  DateTime registration_deadline;
  DateTime opening_date;
  DateTime start_date;
  String? banner_url;
  String status;
  late int season_year;
  String league_rules;
  String? sponsors;
  String league_description;

  late LeagueAdministratorModel league_administrator;
  late List<LeagueTeamModel> league_teams;
  late List<LeagueCategoryModel> categories;

  MultipartFile? banner_image;

  DateTime? created_at;
  DateTime? updated_at;

  LeagueModel({
    required this.league_id,
    required this.league_administrator_id,
    required this.league_title,
    required this.league_description,
    required this.league_budget,
    required this.registration_deadline,
    required this.opening_date,
    required this.start_date,
    required this.status,
    required this.season_year,
    required this.league_rules,
    required this.league_administrator,
    required this.league_teams,
    required this.categories,
    this.banner_url,
    this.sponsors,
    this.created_at,
    this.updated_at,
  });

  LeagueModel.create({
    required this.league_administrator_id,
    required this.league_title,
    required this.league_budget,
    required this.registration_deadline,
    required this.opening_date,
    required this.start_date,
    required this.league_description,
    required this.league_rules,
    this.sponsors,
    required this.status,
    required this.categories,
    this.banner_image,
  });

  FormData toFormDataForCreation() {
    return FormData.fromMap({
      'league_administrator_id': league_administrator_id,
      'league_title': league_title,
      'league_description': league_description,
      'league_budget': league_budget.toString(),
      'registration_deadline': registration_deadline.toIso8601String(),
      'opening_date': opening_date.toIso8601String(),
      'start_date': start_date.toIso8601String(),
      'league_rules': league_rules,
      'status': status,
      'categories': jsonEncode(
        categories
            .map(
              (cat) => {
                'category_name': cat.category_name,
                'category_format': cat.category_format,
                'stage': cat.stage,
                'max_team': cat.max_team,
                'entrance_fee_amount': cat.entrance_fee_amount,
              },
            )
            .toList(),
      ),
      if (sponsors != null) 'sponsors': sponsors,
      if (banner_image != null) 'banner_image': banner_image,
    });
  }

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    return LeagueModel(
      league_id: json['league_id'],
      league_administrator_id: json['league_administrator_id'],
      league_title: json['league_title'],
      league_description: json['league_description'],
      league_budget: json['league_budget'],
      registration_deadline: DateTime.parse(json['registration_deadline']),
      opening_date: DateTime.parse(json['opening_date']),
      start_date: DateTime.parse(json['start_date']),
      status: json['status'],
      season_year: json['season_year'],
      league_rules: json['league_rules'],
      league_administrator: LeagueAdministratorModel.fromJson(
        json['league_administrator'],
      ),
      league_teams:
          (json['league_teams'] as List?)
              ?.map((e) => LeagueTeamModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List)
          .map((e) => LeagueCategoryModel.fromJson(e))
          .toList(),
      banner_url: json['banner_url'] ?? null,
      sponsors: json['sponsors'] ?? null,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  LeagueModel copyWith({
    String? league_id,
    String? league_administrator_id,
    String? league_title,
    String? league_description,
    double? league_budget,
    DateTime? registration_deadline,
    DateTime? opening_date,
    DateTime? start_date,
    String? championship_trophy_url,
    String? banner_url,
    String? status,
    int? season_year,
    String? league_rules,
    String? league_format,
    String? sponsors,
    LeagueAdministratorModel? league_administrator,
    List<LeagueTeamModel>? league_teams,
    List<LeagueCategoryModel>? categories,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return LeagueModel(
      league_id: league_id ?? this.league_id,
      league_administrator_id:
          league_administrator_id ?? this.league_administrator_id,
      league_title: league_title ?? this.league_title,
      league_description: league_description ?? this.league_description,
      league_budget: league_budget ?? this.league_budget,
      registration_deadline:
          registration_deadline ?? this.registration_deadline,
      opening_date: opening_date ?? this.opening_date,
      start_date: start_date ?? this.start_date,
      banner_url: banner_url ?? this.banner_url,
      status: status ?? this.status,
      season_year: season_year ?? this.season_year,
      league_rules: league_rules ?? this.league_rules,
      sponsors: sponsors ?? this.sponsors,
      league_administrator: league_administrator ?? this.league_administrator,
      league_teams: league_teams ?? this.league_teams,
      categories: categories ?? this.categories,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }
}

class LeagueCategoryModel {
  String? category_id;
  late String league_id;

  String category_name;

  String category_format;
  String stage;
  int max_team;
  double entrance_fee_amount;
  late bool accept_teams;

  late DateTime created_at;
  late DateTime updated_at;

  List<LeagueTeamModel>? category_teams;

  LeagueCategoryModel({
    this.category_id,
    required this.league_id,
    required this.category_name,
    required this.category_format,
    required this.stage,
    required this.max_team,
    this.category_teams,
    required this.created_at,
    required this.updated_at,
    required this.entrance_fee_amount,
    required this.accept_teams,
  });

  LeagueCategoryModel.create({
    required this.category_name,
    required this.category_format,
    this.stage = "Group Stage",
    required this.max_team,
    this.entrance_fee_amount = 0.0,
  });

  Map<String, dynamic> toJsonForCreation() {
    return {
      'category_name': category_name,
      'category_format': category_format,
      'stage': stage,
      'max_team': max_team,
      'entrance_fee_amount': entrance_fee_amount,
    };
  }

  factory LeagueCategoryModel.fromJson(Map<String, dynamic> json) {
    return LeagueCategoryModel(
      category_id: json['category_id'],
      league_id: json['league_id'],
      category_name: json['category_name'],
      category_format: json['category_format'],
      entrance_fee_amount: (json['entrance_fee_amount'] as num).toDouble(),
      stage: json['stage'],
      max_team: json['max_team'],
      category_teams:
          (json['category_teams'] as List?)
              ?.map((e) => LeagueTeamModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],

      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
      accept_teams: json['accept_teams'],
    );
  }

  LeagueCategoryModel copyWith({
    String? category_id,
    String? league_id,
    String? category_name,
    String? category_format,
    String? stage,
    int? max_team,
    List<LeagueTeamModel>? category_teams,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return LeagueCategoryModel(
      category_id: category_id ?? this.category_id,
      league_id: league_id ?? this.league_id,
      category_name: category_name ?? this.category_name,
      category_format: category_format ?? this.category_format,
      stage: stage ?? this.stage,
      max_team: max_team ?? this.max_team,
      category_teams: category_teams ?? this.category_teams,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      entrance_fee_amount: entrance_fee_amount,
      accept_teams: accept_teams,
    );
  }
}

class LeagueTeamModel {
  late String league_team_id;
  late String team_id;
  late String league_id;
  late String category_id;

  int wins;
  int losses;
  int draws;
  int points;

  DateTime? created_at;
  DateTime? updated_at;

  LeagueTeamModel({
    required this.league_team_id,
    required this.team_id,
    required this.league_id,
    required this.category_id,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.points,
    this.created_at,
    this.updated_at,
  });

  LeagueTeamModel.create({
    required this.team_id,
    required this.league_id,
    required this.category_id,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.points,
  });

  factory LeagueTeamModel.fromJson(Map<String, dynamic> json) {
    return LeagueTeamModel(
      league_team_id: json['league_team_id'],
      team_id: json['team_id'],
      league_id: json['league_id'],
      category_id: json['category_id'],
      wins: json['wins'],
      losses: json['losses'],
      draws: json['draws'],
      points: json['points'],
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
      'league_team_id': league_team_id,
      'team_id': team_id,
      'league_id': league_id,
      'category_id': category_id,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'points': points,
      'created_at': created_at?.toIso8601String(),
      'updated_at': updated_at?.toIso8601String(),
    };
  }

  LeagueTeamModel copyWith({
    String? league_team_id,
    String? team_id,
    String? league_id,
    String? category_id,
    int? wins,
    int? losses,
    int? draws,
    int? points,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return LeagueTeamModel(
      league_team_id: league_team_id ?? this.league_team_id,
      team_id: team_id ?? this.team_id,
      league_id: league_id ?? this.league_id,
      category_id: category_id ?? this.category_id,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      points: points ?? this.points,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }
}
