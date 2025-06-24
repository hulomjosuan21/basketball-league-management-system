import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

void checkSupabaseStatus() {
  try {
    Supabase.instance.client;
    debugPrint("✅ Supabase initialized successfully!");
  } catch (_) {
    rethrow;
  }
}

Future<ApiResponse> updateUserFcmToken(String userId, String token) async {
  final api = DioClient().client;

  try {
    final response = await api.put(
      '/user/set-token/${userId}',
      data: {'token': token},
    );

    final apiReponse = ApiResponse.fromJsonNoPayload(response.data);

    return apiReponse;
  } catch (_) {
    rethrow;
  }
}
