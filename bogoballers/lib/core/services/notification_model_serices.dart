import 'package:bogoballers/core/models/notification_model.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';

class NotificationModelSerices {
  Future<ApiResponse<List<NotificationModel>>?> fetchNotifications(
    String user_id,
  ) async {
    final api = DioClient().client;

    try {
      final response = await api.get("/notification/fetch-from/$user_id");
      final apiResponse = ApiResponse<List<NotificationModel>>.fromJson(
        response.data,
        (data) => (data as List)
            .map((item) => NotificationModel.fromDynamicJson(item))
            .toList(),
      );

      return apiResponse;
    } catch (_) {
      rethrow;
    }
  }
}
