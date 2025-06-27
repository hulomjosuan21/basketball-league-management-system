import 'package:bogoballers/core/hive/app_box.dart';
import 'package:bogoballers/core/service_locator.dart';
import 'package:bogoballers/core/state/app_state.dart';
import 'package:flutter/material.dart';

Future<void> handleLogout({
  required BuildContext context,
  required String route,
}) async {
  await AppBox.clearAccessToken();
  getIt<AppState>().clear();
  Navigator.pushReplacementNamed(context, route);
}
