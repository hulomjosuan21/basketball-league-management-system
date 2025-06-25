import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';

class TeamService {
  Future<List<TeamModel>?> fetchTeamsByUserID(String user_id) async {
    final api = DioClient().client;

    try {
      final response = await api.get("/team/user/${user_id}");

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (payload) =>
            (payload as List).map((json) => TeamModel.fromJson(json)).toList(),
      );

      return apiResponse.payload;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse> invitePlayer({
    required String team_id,
    required String name_or_email,
  }) async {
    final api = DioClient().client;

    try {
      final response = await api.get(
        "/team/invite-player",
        data: {'team_id': team_id, 'name_or_email': name_or_email},
      );

      final apiResponse = ApiResponse.fromJsonNoPayload(response.data);

      return apiResponse;
    } catch (e) {
      rethrow;
    }
  }
}
