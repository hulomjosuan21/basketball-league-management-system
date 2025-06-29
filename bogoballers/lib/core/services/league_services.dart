import 'package:bogoballers/core/models/league_model.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class LeagueServices {
  Future<ApiResponse<String>> createNewLeague(LeagueModel league) async {
    final api = DioClient().client;

    Response response = await api.post(
      '/league/create-new',
      data: league.toFormDataForCreation(),
      options: Options(contentType: 'multipart/form-data'),
    );

    final apiResponse = ApiResponse<String>.fromJson(
      response.data,
      (data) => data as String,
    );

    return apiResponse;
  }

  Future<ApiResponse> uploadLeagueImages({
    required String league_id,
    MultipartFile? championship_trophy_image,
    MultipartFile? banner_image,
  }) async {
    final api = DioClient().client;

    final formData = FormData.fromMap({
      'league_id': league_id,
      if (championship_trophy_image != null)
        'championship_trophy_image': championship_trophy_image,
      if (banner_image != null) 'banner_image': banner_image,
    });

    final response = await api.put(
      '/league/upload/images',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return ApiResponse.fromJsonNoPayload(response.data);
  }

  Future<List<LeagueModel>> fetchLeagues({
    String? org_name,
    String? brgy,
    String? muni,
    String? org_type,
  }) async {
    final api = DioClient().client;

    try {
      final Map<String, dynamic> body = {};

      if (org_name != null && org_name.isNotEmpty)
        body['organization_name'] = org_name;
      if (brgy != null && brgy.isNotEmpty) body['barangay_name'] = brgy;
      if (muni != null && muni.isNotEmpty) body['municipality_name'] = muni;
      if (org_type != null && org_type.isNotEmpty)
        body['organization_type'] = org_type;

      final response = await api.get(
        '/league/fetch', // ✅ POST instead of GET
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final apiResponse = ApiResponse<List<LeagueModel>>.fromJson(
        response.data,
        (data) => (data as List)
            .map((e) => LeagueModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      return apiResponse.payload ?? [];
    } catch (e) {
      print("League fetch error: $e");
      return [];
    }
  }
}
