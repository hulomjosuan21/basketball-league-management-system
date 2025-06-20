// ignore_for_file: non_constant_identifier_names

import 'package:bogoballers/core/models/user.dart';
import 'package:dio/dio.dart';

class LeagueAdministratorModel {
  late String league_administrator_id;
  late String user_id;
  String organization_type;
  String organization_name;
  String organization_address;
  String? organization_photo_url;
  String? organization_logo_url;
  UserModel user;
  late DateTime created_at;
  late DateTime updated_at;
  late bool is_allowed;
  late bool is_operational;
  late MultipartFile organization_logo;

  LeagueAdministratorModel({
    required this.created_at,
    required this.is_allowed,
    required this.is_operational,
    required this.league_administrator_id,
    required this.organization_address,
    required this.organization_type,
    required this.organization_logo_url,
    required this.organization_name,
    required this.organization_photo_url,
    required this.updated_at,
    required this.user,
    required this.user_id,
  });

  factory LeagueAdministratorModel.fromJson(Map<String, dynamic> json) {
    return LeagueAdministratorModel(
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
      is_allowed: json['is_allowed'],
      is_operational: json['is_operational'],
      league_administrator_id: json['league_administrator_id'],
      organization_address: json['organization_address'],
      organization_type: json['organization_type'],
      organization_logo_url: json['organization_logo_url'],
      organization_name: json['organization_name'],
      organization_photo_url: json['organization_photo_url'],
      user: UserModel.fromJson(json['user']),
      user_id: json['user_id'],
    );
  }
  LeagueAdministratorModel.create({
    required this.organization_type,
    required this.organization_name,
    required this.organization_address,
    required this.user,
    required this.organization_logo,
  });

  FormData toFormDataForCreation() {
    final userMap = user.toJsonForCreation();
    final formMap = {
      'organization_type': organization_type,
      'organization_name': organization_name,
      'organization_address': organization_address,
      'organization_logo': organization_logo,
    };

    userMap.forEach((key, value) {
      formMap['user[$key]'] = value;
    });

    return FormData.fromMap(formMap);
  }

  Map<String, dynamic> toJson() {
    return {
      'league_administrator_id': league_administrator_id,
      'user_id': user_id,
      'organization_type': organization_type,
      'organization_name': organization_name,
      'organization_address': organization_address,
      'organization_photo_url': organization_photo_url,
      'organization_logo_url': organization_logo_url,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
      'is_allowed': is_allowed,
      'is_operational': is_operational,
      'user': user.toJson(),
    };
  }
}
