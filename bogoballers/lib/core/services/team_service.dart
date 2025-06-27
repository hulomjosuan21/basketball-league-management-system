import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';

class TeamService {
  Future<List<TeamModel>?> fetchTeamsByUserID(String user_id) async {
    final api = DioClient().client;

    final response = await api.get("/team/user/${user_id}");

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (payload) =>
          (payload as List).map((json) => TeamModel.fromJson(json)).toList(),
    );

    return apiResponse.payload;
  }

  Future<ApiResponse> invitePlayer({
    required String team_id,
    required String name_or_email,
  }) async {
    final api = DioClient().client;

    final response = await api.post(
      "/team/invite-player",
      data: {'team_id': team_id, 'name_or_email': name_or_email},
    );

    final apiResponse = ApiResponse.fromJsonNoPayload(response.data);

    return apiResponse;
  }

  Future<ApiResponse> addPlayer({
    required String team_id,
    required String player_id,
    required TeamInviteStatus is_accepted,
  }) async {
    final api = DioClient().client;

    final response = await api.post(
      "/team/add-player",
      data: {
        'team_id': team_id,
        'player_id': player_id,
        'is_accepted': is_accepted.value,
      },
    );

    final apiResponse = ApiResponse.fromJsonNoPayload(response.data);

    return apiResponse;
  }

  Future<ApiResponse> updatePlayerIsAccepted({
    required String player_team_id,
    required TeamInviteStatus is_accepted,
  }) async {
    final api = DioClient().client;

    final response = await api.put(
      "/team/update-player-is_accepted",
      data: {
        'player_team_id': player_team_id,
        'is_accepted': is_accepted.value,
      },
    );
    final apiResponse = ApiResponse.fromJsonNoPayload(response.data);

    return apiResponse;
  }

  Future<ApiResponse> acceptInvite({required String player_team_id}) async {
    final api = DioClient().client;

    final response = await api.put(
      "/team/accept-invite",
      data: {'player_team_id': player_team_id},
    );

    final apiResponse = ApiResponse.fromJsonNoPayload(response.data);

    return apiResponse;
  }
}
