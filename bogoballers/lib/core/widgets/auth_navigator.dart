import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

RichText authNavigator(
  BuildContext context,
  String text,
  String textTo,
  void Function() callback,
) {
  return RichText(
    text: TextSpan(
      text: text,
      style: TextStyle(color: context.appColors.gray1100, fontSize: 12),
      children: [
        TextSpan(
          text: textTo,
          style: TextStyle(
            color: context.appColors.accent900,
            fontWeight: FontWeight.w600,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              callback();
            },
        ),
      ],
    ),
  );
}
