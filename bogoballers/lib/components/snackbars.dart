import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

void showErrorSnackbar(
  BuildContext context,
  String errorMessage, {
  double height = 100,
}) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: SizedBox(
      height: height,
      child: AwesomeSnackbarContent(
        title: 'Error',
        message: errorMessage,
        contentType: ContentType.failure,
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
