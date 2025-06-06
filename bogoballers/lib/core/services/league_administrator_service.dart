// ignore_for_file: non_constant_identifier_names

import 'package:bogoballers/core/hive/app_box.dart';
import 'package:bogoballers/core/models/access_token.dart';
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

  Future<ApiResponse> loginAccount({required UserModel user}) async {
    final dioClient = DioClient();

    Response response = await dioClient.client.post(
      '/administrator/login-account',
      data: user.toJsonForLogin(),
    );

    final apiResponse = ApiResponse<AccessToken>.fromJson(
      response.data,
      (json) => AccessToken.fromJson(json),
    );

    final access_token = apiResponse.payload;

    if (access_token != null) {
      AppBox.accessTokenBox.put('access_token', access_token);
      debugPrint("Token Stored");
    }

    return apiResponse;
  }
}
