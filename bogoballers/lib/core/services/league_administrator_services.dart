// ignore_for_file: non_constant_identifier_names

import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class LeagueAdministratorServices {
  Future<ApiResponse> createNewAdministrator({
    required LeagueAdministratorModel leagueAdministrator,
  }) async {
    final api = DioClient().client;
    Response response = await api.post(
      '/entity/create-new/league-administrator',
      data: leagueAdministrator.toFormDataForCreation(),
    );
    final apiResponse = ApiResponse.fromJsonNoPayload(response.data);
    return apiResponse;
  }
}
