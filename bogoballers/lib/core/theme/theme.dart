import 'package:bogoballers/core/theme/colors.dart';
import 'package:bogoballers/core/theme/inputs.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

DialogThemeData defaultDialogThemeData = DialogThemeData(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
);

CheckboxThemeData defaultCheckboxThemeData(BuildContext context) {
  return CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.disabled)) {
        return context.appColors.gray200;
      }
      if (states.contains(WidgetState.selected)) {
        return context.appColors.accent600;
      }
      return context.appColors.gray100;
    }),
    checkColor: WidgetStateProperty.all<Color>(context.appColors.accent100),
    side: BorderSide(color: context.appColors.gray600, width: 0.5),
  );
}

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
    dialogTheme: defaultDialogThemeData,
    inputDecorationTheme: appInputDecorationTheme(context),
    checkboxTheme: defaultCheckboxThemeData(context),
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
    dialogTheme: defaultDialogThemeData,
    inputDecorationTheme: appInputDecorationTheme(context),
    checkboxTheme: defaultCheckboxThemeData(context),
    extensions: [darkAppColors],
  );
}
