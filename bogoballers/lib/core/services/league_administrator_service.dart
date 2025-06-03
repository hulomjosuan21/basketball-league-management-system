import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LeagueAdministratorService {
  Future<void> registerAccount({required UserModel newAdministrator}) async {
    final dioClient = DioClient();
    debugPrint("Email: ${newAdministrator.email}");
    debugPrint("Password: ${newAdministrator.account_type.name}");

    Response response = await dioClient.client.post(
      '/administrator/register-account',
      data: newAdministrator.toJsonForCreation(),
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response data: ${response.data.message}');
  }
}
