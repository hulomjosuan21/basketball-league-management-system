import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LeagueAdministratorService {
  Future<String> registerAccount({required UserModel newAdministrator}) async {
    final dioClient = DioClient();

    debugPrint("Email: ${newAdministrator.email}");
    debugPrint("Account Type: ${newAdministrator.account_type?.name}");

    Response response = await dioClient.client.post(
      '/administrator/register-account',
      data: newAdministrator.toJsonForCreation(),
    );

    final apiResponse = ApiResponse<void>.fromJsonNoPayload(response.data);

    return apiResponse.message;
  }

  Future<ApiResponse<UserModel>> loginAccount({required UserModel user}) async {
    final dioClient = DioClient();

    Response response = await dioClient.client.post(
      '/administrator/login-account',
      data: user.toJsonForLogin(),
    );

    final apiResponse = ApiResponse<UserModel>.fromJson(
      response.data,
      (json) => UserModel.fromJson(json),
    );

    return apiResponse;
  }
}
