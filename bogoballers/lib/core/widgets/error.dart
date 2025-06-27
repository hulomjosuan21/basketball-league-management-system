import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

Widget retryError(
  BuildContext context,
  Object? error,
  void Function() callback,
) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.error_outline, color: context.appColors.accent900, size: 48),
      SizedBox(height: 16),
      Text(
        error.toString(),
        style: TextStyle(fontSize: 18, color: context.appColors.gray1100),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 20),
      AppButton(
        onPressed: callback,
        icon: Icon(Icons.refresh),
        label: 'Retry',
        size: ButtonSize.sm,
        variant: ButtonVariant.ghost,
      ),
    ],
  );
}

Widget fullScreenRetryError(
  BuildContext context,
  Object? error,
  void Function() callback,
) {
  return Scaffold(
    extendBodyBehindAppBar: true,
    body: Container(
      decoration: BoxDecoration(gradient: context.appColors.primaryGradient),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: context.appColors.accent900,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              error.toString(),
              style: TextStyle(fontSize: 18, color: context.appColors.gray1100),
              overflow: TextOverflow.fade,
              maxLines: 4,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            AppButton(
              onPressed: callback,
              icon: Icon(Icons.refresh),
              label: 'Retry',
              size: ButtonSize.sm,
              variant: ButtonVariant.ghost,
            ),
          ],
        ),
      ),
    ),
  );
}
