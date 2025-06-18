import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

const borderWidth = 0.5;

InputDecorationTheme appInputDecorationTheme(BuildContext context) {
  return InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: context.appColors.gray600,
        width: borderWidth,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: context.appColors.gray600,
        width: borderWidth,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: context.appColors.gray400,
        width: borderWidth,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: context.appColors.accent900,
        width: borderWidth,
      ),
    ),
    labelStyle: TextStyle(color: context.appColors.gray1100, fontSize: 12),
    prefixIconColor: context.appColors.gray600,
    focusColor: context.appColors.accent900,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    hintStyle: TextStyle(color: context.appColors.gray600, fontSize: 12),
    helperStyle: TextStyle(fontSize: 8),
    isDense: true,
  );
}
