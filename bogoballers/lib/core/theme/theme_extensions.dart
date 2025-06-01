import 'package:flutter/material.dart';
import 'colors.dart';

extension AppColorsX on BuildContext {
  AppColors get appColors {
    final colors = Theme.of(this).extension<AppColors>();
    if (colors != null) return colors;

    return lightAppColors;
  }
}
