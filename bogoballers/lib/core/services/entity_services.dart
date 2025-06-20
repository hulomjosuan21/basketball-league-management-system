import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/hive/app_box.dart';
import 'package:bogoballers/core/models/access_token.dart';
import 'package:bogoballers/core/models/login_response.dart';
import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:bogoballers/core/providers/player_provider.dart';
import 'package:bogoballers/core/providers/team_creator_provider.dart';
import 'package:bogoballers/core/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntityServices<T> {
  Future<ApiResponse> login({
    required BuildContext context,
    required UserModel user,
    bool stayLoggedIn = true,
  }) async {
    final api = DioClient().client;

    try {
      final response = await api.post(
        '/entity/login',
        data: user.toFormDataForLogin(),
        queryParameters: {'stay_login': stayLoggedIn},
      );
      final apiResponse = ApiResponse.fromJsonNoPayload(response.data);

      final redirect = apiResponse.redirect;
      if (!clientRoutes.containsKey(redirect)) {
        throw Exception("Unknown redirect route: $redirect");
      }

      final payload = apiResponse.payload;
      AccountTypeEnum? accountType = AccountTypeEnum.fromValue(
        payload['account_type'],
      );

      AccessToken? accessToken;

      switch (accountType) {
        case AccountTypeEnum.PLAYER:
          final loginResponse = LoginResponse<PlayerModel>.fromJson(
            payload,
            (json) => PlayerModel.fromJson(json),
          );

          if (loginResponse.access_token != null) {
            accessToken = AccessToken(
              access_token: loginResponse.access_token!,
            );
          }
          final playerProvider = Provider.of<PlayerProvider>(
            context,
            listen: false,
          );
          playerProvider.setCurrentPlayer(loginResponse.entity);
          break;

        case AccountTypeEnum.TEAM_CREATOR:
          final loginResponse = LoginResponse<UserModel>.fromJson(
            payload,
            (json) => UserModel.fromJson(json),
          );

          if (loginResponse.access_token != null) {
            accessToken = AccessToken(
              access_token: loginResponse.access_token!,
            );
          }

          final teamCreatorrovider = Provider.of<TeamCreatorProvider>(
            context,
            listen: false,
          );
          teamCreatorrovider.setCurrentTeamCreator(loginResponse.entity);
          break;

        case AccountTypeEnum.LOCAL_ADMINISTRATOR:
        case AccountTypeEnum.LGU_ADMINISTRATOR:
          break;

        default:
          throw Exception("Unknown account type: $accountType");
      }

      if (accessToken != null) {
        AppBox.accessTokenBox.put('access_token', accessToken);
        debugPrint("Token Stored");
      } else {
        debugPrint(
          "Access token not saved (user may not be staying logged in)",
        );
      }

      return apiResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetch(BuildContext context, String user_id) async {
    final api = DioClient().client;
    try {
      final response = await api.get('/entity/fetch/${user_id}');
      final apiResponse = ApiResponse.fromJsonNoPayload(response.data);

      final payload = apiResponse.payload;
      AccountTypeEnum? accountType = AccountTypeEnum.fromValue(
        payload['account_type'],
      );

      switch (accountType) {
        case AccountTypeEnum.PLAYER:
          final player = PlayerModel.fromJson(payload['entity']);
          final playerProvider = Provider.of<PlayerProvider>(
            context,
            listen: false,
          );
          playerProvider.setCurrentPlayer(player);
          break;

        case AccountTypeEnum.TEAM_CREATOR:
          final user = UserModel.fromJson(payload['entity']);
          final teamCreatorrovider = Provider.of<TeamCreatorProvider>(
            context,
            listen: false,
          );
          teamCreatorrovider.setCurrentTeamCreator(user);
          break;

        case AccountTypeEnum.LOCAL_ADMINISTRATOR:
        case AccountTypeEnum.LGU_ADMINISTRATOR:
          break;

        default:
          throw Exception("Unknown account type: $accountType");
      }
    } catch (e) {
      rethrow;
    }
  }
}
