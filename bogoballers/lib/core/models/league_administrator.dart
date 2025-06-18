// ignore_for_file: non_constant_identifier_names

import 'package:bogoballers/core/models/user.dart';
import 'package:dio/dio.dart';

class LeagueAdministratorModel {
  late String league_administrator_id;
  String organization_type;
  String organization_name;
  String organization_address;
  String? organization_photo_url;
  String? organization_logo_url;
  UserModel user;
  late DateTime created_at;
  late DateTime updated_at;
  late MultipartFile organization_logo_file;

  LeagueAdministratorModel({
    required this.league_administrator_id,
    required this.organization_type,
    required this.organization_name,
    required this.organization_address,
    this.organization_photo_url,
    this.organization_logo_url,
    required this.user,
    required this.created_at,
    required this.updated_at,
  });

  LeagueAdministratorModel.create({
    required this.organization_type,
    required this.organization_name,
    required this.organization_address,
    required this.user,
    required this.organization_logo_file,
  });

  factory LeagueAdministratorModel.fromJson(Map<String, dynamic> json) {
    return LeagueAdministratorModel(
      league_administrator_id: json['league_administrator_id'],
      organization_type: json['organization_type'],
      organization_name: json['organization_name'],
      organization_address: json['organization_address'],
      organization_photo_url: json['organization_photo_url'],
      organization_logo_url: json['organization_logo_url'],
      user: UserModel.fromJson(json['user']),
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
    );
  }

  FormData toFormDataForCreation() {
    final userMap = user.toJsonForCreation();
    final formMap = {
      'organization_type': organization_type,
      'organization_name': organization_name,
      'organization_address': organization_address,
      'organization_logo_file': organization_logo_file,
    };

    userMap.forEach((key, value) {
      formMap['user[$key]'] = value;
    });

    return FormData.fromMap(formMap);
  }

  Map<String, dynamic> toJson() {
    return {
      'organization_type': organization_type,
      'organization_name': organization_name,
      'organization_address': organization_address,
      'organization_photo_url': organization_photo_url,
      'organization_logo_url': organization_logo_url,
      'user': user.toJson(),
    };
  }
}
