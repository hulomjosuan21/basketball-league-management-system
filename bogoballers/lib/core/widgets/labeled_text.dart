import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class LabeledText extends StatelessWidget {
  final String label;
  final String value;
  final double fontSize;
  final Color? color;

  const LabeledText({
    super.key,
    required this.label,
    required this.value,
    this.fontSize = Sizes.fontSizeMd,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = context.appColors.gray1100;

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(
          context,
        ).style.copyWith(fontSize: fontSize, color: defaultColor),
        children: [
          TextSpan(
            text: "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold, color: defaultColor),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: defaultColor,
            ),
          ),
        ],
      ),
    );
  }
}
