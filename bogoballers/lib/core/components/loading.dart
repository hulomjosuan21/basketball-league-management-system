import 'package:bogoballers/core/theme/theme.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

MaterialApp appFullScreenLoading(BuildContext context) {
  return MaterialApp(
    theme: lightTheme(context),
    home: Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: context.appColors.primaryGradient,
          ),

          child: Center(
            child: CircularProgressIndicator(
              color: context.appColors.accent900,
            ),
          ),
        ),
      ),
    ),
    debugShowCheckedModeBanner: false,
  );
}
