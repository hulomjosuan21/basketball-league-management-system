import 'package:bogoballers/core/theme/theme.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

MaterialApp appFullScreenLoading(BuildContext context) {
  return MaterialApp(
    title: 'Administrator App',
    theme: lightTheme(context),
    home: Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: context.appColors.accent900),
      ),
    ),
    debugShowCheckedModeBanner: false,
  );
}
