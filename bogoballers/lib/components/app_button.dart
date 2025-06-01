import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, destructive }

enum ButtonSize { sm, md, lg }

class AppButton extends MaterialButton {
  final String label;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? icon;
  final bool isDisabled;
  final bool iconOnRight;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    required VoidCallback? onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.icon,
    this.isDisabled = false,
    this.iconOnRight = false,
    this.width,
    this.height,
  }) : super(onPressed: isDisabled ? null : onPressed);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Color backgroundColor;
    Color textColor;
    BorderSide? borderSide;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = colors.accent900;
        textColor = colors.gray100;
        break;
      case ButtonVariant.secondary:
        backgroundColor = colors.accent100;
        textColor = colors.gray1100;
        break;
      case ButtonVariant.destructive:
        backgroundColor = colors.accent1200;
        textColor = colors.accent100;
        break;
    }

    EdgeInsets padding;
    double fontSize;

    switch (size) {
      case ButtonSize.sm:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        fontSize = 12;
        break;
      case ButtonSize.md:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        fontSize = 14;
        break;
      case ButtonSize.lg:
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
        fontSize = 16;
        break;
    }

    final iconWidget = icon;
    final textWidget = Text(
      label,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
    );

    return SizedBox(
      width: width,
      height: height,
      child: MaterialButton(
        onPressed: onPressed,
        color: backgroundColor,
        textColor: textColor,
        disabledColor: colors.gray400,
        disabledTextColor: colors.gray500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: borderSide ?? BorderSide.none,
        ),
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null && !iconOnRight) ...[
              iconWidget,
              const SizedBox(width: 8),
            ],
            textWidget,
            if (iconWidget != null && iconOnRight) ...[
              const SizedBox(width: 8),
              iconWidget,
            ],
          ],
        ),
      ),
    );
  }
}
