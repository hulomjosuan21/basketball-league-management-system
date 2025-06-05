import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LeagueAdministratorService {
  Future<String> registerAccount({
    required LeagueAdministratorModel newAdministrator,
  }) async {
    final dioClient = DioClient();
    Response response = await dioClient.client.post(
      '/administrator/register-account',
      data: newAdministrator.toJsonForCreation(),
    );
    final apiResponse = ApiResponse<UserModel>.fromJsonNoPayload(response.data);
    return apiResponse.message;
  }

  Future<void> loginAccount({required UserModel user}) async {
    final dioClient = DioClient();

    Response response = await dioClient.client.post(
      '/administrator/login-account',
      data: user.toJsonForLogin(),
    );

    final apiResponse = ApiResponse<LeagueAdministratorModel>.fromJson(
      response.data,
      (json) => LeagueAdministratorModel.fromJson(json),
    );

    debugPrint(apiResponse.payload!.toJson().toString());

    // return apiResponse;
  }
}
