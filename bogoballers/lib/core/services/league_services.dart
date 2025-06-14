import 'package:bogoballers/core/models/league_model.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class LeagueServices {
  Future<ApiResponse> createNewLeague(LeagueModel league) async {
    final api = DioClient().client;

    Response response = await api.post(
      '/league/create-new',
      data: league.toJsonForCreation(),
    );

    final apiResponse = ApiResponse.fromJsonNoPayload(response.data);

    return apiResponse;
  }
}
