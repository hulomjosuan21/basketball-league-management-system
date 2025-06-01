import 'package:bogoballers/core/theme/colors.dart';
import 'package:bogoballers/core/theme/inputs.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme(BuildContext context) {
  return ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Montserrat',
    primarySwatch: lightPrimarySwatch,
    scaffoldBackgroundColor: lightAppColors.gray200,

    appBarTheme: AppBarTheme(
      backgroundColor: lightAppColors.accent900,
      foregroundColor: lightAppColors.accent100,
    ),
    inputDecorationTheme: appInputDecorationTheme(context),
    extensions: [lightAppColors],
  );
}

ThemeData darkTheme(BuildContext context) {
  return ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Montserrat',
    primarySwatch: darkPrimarySwatch,
    scaffoldBackgroundColor: darkAppColors.gray200,
    appBarTheme: AppBarTheme(
      backgroundColor: darkAppColors.accent900,
      foregroundColor: darkAppColors.accent100,
    ),
    inputDecorationTheme: appInputDecorationTheme(context),
    extensions: [darkAppColors],
  );
}
