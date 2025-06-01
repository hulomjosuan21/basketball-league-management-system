import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

InputDecorationTheme appInputDecorationTheme(BuildContext context) {
  return InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: context.appColors.gray600),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: context.appColors.gray600),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: context.appColors.accent900,
      ), // uses context
    ),
    labelStyle: TextStyle(color: context.appColors.gray1100),
    prefixIconColor: context.appColors.gray600,
    focusColor: context.appColors.accent900,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}
