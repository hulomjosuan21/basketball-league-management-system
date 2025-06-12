import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class LocationData {
  final Map<String, List<String>> barangays;
  final List<String> municipalities;

  LocationData({required this.barangays, required this.municipalities});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      barangays: Map<String, List<String>>.from(
        json['barangays'].map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      municipalities: List<String>.from(json['municipalities']),
    );
  }
}

Future<List<String>> getOrganizationTypes() async {
  final dioClient = DioClient();
  Response response = await dioClient.client.get('/organization-types');

  final apiResponse = ApiResponse<List<String>>.fromJson(
    response.data,
    (json) => List<String>.from(json),
  );
  return apiResponse.payload ?? [];
}

Future<LocationData> getLocationData() async {
  final dioClient = DioClient();
  final response = await dioClient.client.get('/places');

  final apiResponse = ApiResponse<LocationData>.fromJson(
    response.data,
    (json) => LocationData.fromJson(json),
  );

  return apiResponse.payload!;
}
