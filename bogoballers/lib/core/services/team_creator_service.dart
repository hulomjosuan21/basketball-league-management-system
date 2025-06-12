import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';

class TeamCreatorService {
  Future<String> registerAccount(UserModel user) async {
    user.account_type = AccountTypeEnum.Team_Creator;
    final api = DioClient().client;

    debugPrint(user.toJsonForCreation().toString());
    Response response = await api.post(
      '/team-creator/register-account',
      data: user.toJsonForCreation(),
    );
    final apiResponse = ApiResponse.fromJsonNoPayload(response.data);
    return apiResponse.message;
  }
}
