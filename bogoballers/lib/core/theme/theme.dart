import 'package:bogoballers/core/theme/colors.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: lightPrimarySwatch,
  scaffoldBackgroundColor: lightAppColors.gray200,
  appBarTheme: AppBarTheme(
    backgroundColor: lightAppColors.accent900,
    foregroundColor: lightAppColors.accent100,
  ),

  extensions: [lightAppColors],
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: darkPrimarySwatch,
  scaffoldBackgroundColor: darkAppColors.accent200,
  appBarTheme: AppBarTheme(
    backgroundColor: darkAppColors.accent900,
    foregroundColor: darkAppColors.accent100,
  ),

  extensions: [darkAppColors],
);
