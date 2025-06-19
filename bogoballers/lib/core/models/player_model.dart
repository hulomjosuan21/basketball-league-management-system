// ignore_for_file: non_constant_identifier_names

import 'package:bogoballers/core/models/user.dart';
import 'package:dio/dio.dart';

class PlayerModel {
  late String player_id;
  late String user_id;
  String full_name;
  String gender;
  DateTime birth_date;
  String player_address;
  String jersey_name;
  double jersey_number;
  String position;
  double? height_in;
  double? weight_kg;
  late int games_played;
  late int points_scored;
  late int assists;
  late int rebounds;

  late String profile_image_url;
  String? document_url_1;
  String? document_url_2;

  UserModel user;

  late DateTime created_at;
  late DateTime updated_at;
  late MultipartFile profile_image;

  PlayerModel({
    required this.player_id,
    required this.user_id,
    required this.full_name,
    required this.gender,
    required this.birth_date,
    required this.player_address,
    required this.jersey_name,
    required this.jersey_number,
    required this.position,
    required this.height_in,
    required this.weight_kg,
    required this.games_played,
    required this.points_scored,
    required this.assists,
    required this.rebounds,
    required this.profile_image_url,
    required this.user,
  });

  PlayerModel.create({
    required this.full_name,
    required this.gender,
    required this.birth_date,
    required this.player_address,
    required this.jersey_name,
    required this.jersey_number,
    required this.position,
    required this.user,
    required this.profile_image,
  });

  FormData toFormDataForCreation() {
    final userMap = user.toJsonForCreation();
    final formMap = {
      'full_name': full_name,
      'gender': gender,
      'birth_date': birth_date.toIso8601String(),
      'player_address': player_address,
      'jersey_name': jersey_name,
      'jersey_number': jersey_number,
      'position': position,
      'profile_image': profile_image,
    };

    userMap.forEach((key, value) {
      formMap['user[$key]'] = value;
    });

    return FormData.fromMap(formMap);
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      player_id: json['player_id'],
      user_id: json['user_id'],
      full_name: json['full_name'],
      gender: json['gender'],
      birth_date: DateTime.parse(json['birth_date']),
      player_address: json['player_address'],
      jersey_name: json['jersey_name'],
      jersey_number: json['jersey_number'],
      position: json['position'],
      height_in: json['height_in'],
      weight_kg: json['weight_kg'],
      games_played: json['games_played'] ?? 0,
      points_scored: json['points_scored'] ?? 0,
      assists: json['assists'] ?? 0,
      rebounds: json['rebounds'] ?? 0,
      profile_image_url: json['profile_image_url'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_id': player_id,
      'user_id': user_id,
      'full_name': full_name,
      'gender': gender,
      'birth_date': birth_date,
      'player_address': player_address,
      'jersey_name': jersey_name,
      'jersey_number': jersey_number,
      'position': position,
      'height_in': height_in,
      'weight_kg': weight_kg,
      'games_played': games_played,
      'points_scored': points_scored,
      'assists': assists,
      'rebounds': rebounds,
      'profile_image_url': profile_image_url,
      'user': user.toJson(),
    };
  }
}
