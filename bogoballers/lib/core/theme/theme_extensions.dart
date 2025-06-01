import 'package:bogoballers/core/theme/colors.dart';
import 'package:flutter/material.dart';

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
