import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

void showAppSnackbar(
  BuildContext context, {
  required message,
  String title = 'Success',
  ContentType contentType = ContentType.success,
  double height = 100,
  Duration duration = const Duration(seconds: 4),
  SnackBarBehavior behavior = SnackBarBehavior.floating,
  Color backgroundColor = Colors.transparent,
  double elevation = 0,
}) {
  final snackBar = SnackBar(
    elevation: elevation,
    behavior: behavior,
    backgroundColor: backgroundColor,
    duration: duration,
    content: SizedBox(
      height: height,
      child: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
