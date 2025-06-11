import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class PlayerService {
  Future<String> registerAccount(PlayerModel player) async {
    final api = DioClient().client;
    Response response = await api.post(
      '/client/register-account',
      data: player.toFormDataForCreation(),
    );
    final apiResponse = ApiResponse.fromJsonNoPayload(response.data);
    return apiResponse.message;
  }
}
