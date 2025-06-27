import 'dart:async';
import 'dart:io';

import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class EntityNotFound implements Exception {
  final String message;

  EntityNotFound(AccountTypeEnum accountType)
    : message = _resolveMessage(accountType);

  static String _resolveMessage(AccountTypeEnum accountType) {
    switch (accountType) {
      case AccountTypeEnum.LOCAL_ADMINISTRATOR:
      case AccountTypeEnum.LGU_ADMINISTRATOR:
        return 'Administrator not found.';
      case AccountTypeEnum.PLAYER:
      case AccountTypeEnum.TEAM_CREATOR:
        return 'User not found.';
      default:
        return 'Entity not found.';
    }
  }

  @override
  String toString() => 'EntityNotFound: $message';
}

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
