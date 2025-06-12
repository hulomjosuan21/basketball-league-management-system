// ignore_for_file: non_constant_identifier_names

import 'package:bogoballers/core/hive/app_box.dart';
import 'package:bogoballers/core/models/access_token.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ClientServices {
  Future<ApiResponse> loginAccount(UserModel user) async {
    final api = DioClient().client;

    Response response = await api.post(
      '/client/login-account',
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
