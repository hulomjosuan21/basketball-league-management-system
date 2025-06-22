// ignore_for_file: non_constant_identifier_names
import 'package:dio/dio.dart';

class TeamModel {
  late String team_id;
  String user_id;
  String team_name;
  String team_address;
  String contact_number;
  String team_motto;
  String coach_name;
  String? assistant_coach_name;
  late String team_logo_url;
  late int championships_won;
  late MultipartFile team_logo_image;
  String? team_captain_id;
  late DateTime created_at;
  late DateTime updated_at;
  late bool is_recruiting;

  TeamModel({
    required this.team_id,
    required this.user_id,
    required this.team_name,
    required this.team_address,
    required this.contact_number,
    required this.team_motto,
    required this.coach_name,
    this.assistant_coach_name,
    required this.team_logo_url,
    required this.championships_won,
    required this.team_captain_id,
    required this.created_at,
    required this.updated_at,
    required this.is_recruiting,
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
  });

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
