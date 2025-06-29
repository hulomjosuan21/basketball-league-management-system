import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, destructive, outline, ghost }

enum ButtonSize { xs, sm, md, lg }

class AppButton extends MaterialButton {
  final String label;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? icon;
  final bool isDisabled;
  final bool iconOnRight;
  final double? width;

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
        borderSide = BorderSide.none;
        break;
      case ButtonVariant.secondary:
        backgroundColor = colors.accent100;
        textColor = colors.gray1100;
        borderSide = BorderSide.none;
        break;
      case ButtonVariant.destructive:
        backgroundColor = Colors.redAccent;
        textColor = colors.accent100;
        borderSide = BorderSide.none;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = colors.gray1100;
        borderSide = BorderSide(
          color: colors.gray600,
          width: Sizes.borderWidthSm,
        );
        break;
      case ButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        textColor = colors.gray1100;
        borderSide = BorderSide.none;
        break;
    }

    EdgeInsets padding;
    double fontSize;

    switch (size) {
      case ButtonSize.xs:
        padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4);
        fontSize = Sizes.fontSizeXs;
        break;
      case ButtonSize.sm:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        fontSize = Sizes.fontSizeSm;
        break;
      case ButtonSize.md:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        fontSize = Sizes.fontSizeMd;
        break;
      case ButtonSize.lg:
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
        fontSize = Sizes.fontSizeLg;
        break;
    }

    final iconWidget = icon;
    final textWidget = Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: isDisabled ? colors.gray500 : textColor,
      ),
    );

    return SizedBox(
      width: width,
      height: height,
      child: MaterialButton(
        onPressed: onPressed,
        color: backgroundColor,
        textColor: isDisabled ? colors.gray500 : textColor,
        disabledColor: colors.gray400,
        disabledTextColor: colors.gray500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusSm),
          side: borderSide,
        ),
        padding: padding,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
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
