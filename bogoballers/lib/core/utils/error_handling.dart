import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message.toString();
}

class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message.toString();
}

String getErrorMessage(Object error) {
  if (error is DioException) {
    final responseData = error.response?.data;
    if (responseData is Map && responseData.containsKey('message')) {
      return responseData['message'];
    }
    return 'Something went wrong. (${error.response?.statusCode ?? 'Unknown status'})';
  } else if (error is FormatException) {
    return 'Invalid format: ${error.message}';
  } else if (error is TimeoutException) {
    return 'Request timed out. Please try again.';
  } else if (error is SocketException) {
    return 'No internet connection.';
  } else if (error is HttpException) {
    return 'No internet connection.';
  }

  return error.toString();
}

void handleErrorCallBack(Object error, void Function(String) showErrorDialog) {
  final errorMessage = getErrorMessage(error);

  debugPrint('Error: $errorMessage');

  showErrorDialog(errorMessage);
}
