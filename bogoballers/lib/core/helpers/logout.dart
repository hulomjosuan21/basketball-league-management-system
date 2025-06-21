import 'package:bogoballers/core/hive/app_box.dart';
import 'package:flutter/material.dart';

Future<void> handleLogout({
  required BuildContext context,
  required String route,
}) async {
  await AppBox.clearAccessToken();
  Navigator.pushReplacementNamed(context, route);
}
