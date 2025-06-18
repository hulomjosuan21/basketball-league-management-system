import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';

class TeamCreatorServices {
  Future<String> registerAccount(UserModel user) async {
    final api = DioClient().client;

    debugPrint(user.toJsonForCreation().toString());
    Response response = await api.post(
      '/team-creator/register-account',
      data: user.toJsonForCreation(),
    );
    final apiResponse = ApiResponse.fromJsonNoPayload(response.data);
    return apiResponse.message;
  }

  Future<ApiResponse> createNewTeam(TeamModel team) async {
    final api = DioClient().client;
    Response response = await api.post(
      '/team/create-new',
      data: team.toFormDataForCreation(),
    );
    final apiResponse = ApiResponse.fromJsonNoPayload(response.data);
    return apiResponse;
  }
}
