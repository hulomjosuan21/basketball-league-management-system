import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void handleDioError(
  BuildContext context,
  Object error,
  void Function(String) showErrorDialog,
) {
  if (error is DioException) {
    final responseData = error.response?.data;
    String errorMessage = 'Something went wrong.';

    if (responseData is Map && responseData.containsKey('message')) {
      errorMessage = responseData['message'];
    }

    debugPrint('Error: ${error.response?.statusCode} - $errorMessage');

    showErrorDialog(errorMessage);
  } else {
    debugPrint('Unexpected error: $error');
  }
}
