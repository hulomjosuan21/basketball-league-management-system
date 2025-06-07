// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:bogoballers/core/models/user.dart';
import 'package:dio/dio.dart';

class LeagueAdministratorModel {
  late String league_administrator_id;
  String organization_type;
  String organization_name;
  String contact_number;
  String barangay_name;
  String municipality_name;
  String? organization_photo_url;
  String? organization_logo_url;
  UserModel user;
  late DateTime created_at;
  late DateTime updated_at;
  late Future<MultipartFile> organization_logo_file;

  LeagueAdministratorModel({
    required this.league_administrator_id,
    required this.organization_type,
    required this.organization_name,
    required this.contact_number,
    required this.barangay_name,
    required this.municipality_name,
    this.organization_photo_url,
    this.organization_logo_url,
    required this.user,
    required this.created_at,
    required this.updated_at,
  });

  LeagueAdministratorModel.create({
    required this.organization_type,
    required this.organization_name,
    required this.contact_number,
    required this.barangay_name,
    required this.municipality_name,
    required this.user,
  });

  factory LeagueAdministratorModel.fromJson(Map<String, dynamic> json) {
    return LeagueAdministratorModel(
      league_administrator_id: json['league_administrator_id'],
      organization_type: json['organization_type'],
      organization_name: json['organization_name'],
      contact_number: json['contact_number'] ?? '',
      barangay_name: json['barangay_name'],
      municipality_name: json['municipality_name'],
      organization_photo_url: json['organization_photo_url'],
      organization_logo_url: json['organization_logo_url'],
      user: UserModel.fromJson(json['user']),
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJsonForCreation() {
    return {
      'organization_type': organization_type,
      'organization_name': organization_name,
      'contact_number': contact_number,
      'barangay_name': barangay_name,
      'municipality_name': municipality_name,
      'user': user.toJsonForCreation(),
    };
  }

  Future<FormData> toFormDataForCreation() async {
    final userMap = user.toJsonForCreation();
    final formMap = {
      'organization_type': organization_type,
      'organization_name': organization_name,
      'contact_number': contact_number,
      'barangay_name': barangay_name,
      'municipality_name': municipality_name,
      'organization_logo_file': await organization_logo_file,
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
      'contact_number': contact_number,
      'barangay_name': barangay_name,
      'municipality_name': municipality_name,
      'organization_photo_url': organization_photo_url,
      'organization_logo_url': organization_logo_url,
      'user': user.toJson(),
    };
  }
}
