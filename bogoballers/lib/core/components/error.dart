import 'package:bogoballers/core/components/app_button.dart';
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
      Icon(Icons.error_outline, color: context.appColors.accent600, size: 48),
      SizedBox(height: 16),
      Text(
        error.toString(),
        style: TextStyle(fontSize: 18, color: context.appColors.gray1100),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 8),
      Text(
        'Please try again.',
        style: TextStyle(fontSize: 14, color: context.appColors.gray1000),
      ),
      SizedBox(height: 20),
      AppButton(
        onPressed: callback,
        icon: Icon(Icons.refresh),
        label: 'Retry',
        variant: ButtonVariant.ghost,
      ),
    ],
  );
}

MaterialApp fullScreenRetryError(
  BuildContext context,
  Object? error,
  void Function() callback,
) {
  return MaterialApp(
    title: "Error",
    home: Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: context.appColors.primaryGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: context.appColors.accent600,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  error.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    color: context.appColors.gray1100,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Please try again.',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appColors.gray1000,
                  ),
                ),
                SizedBox(height: 20),
                AppButton(
                  onPressed: callback,
                  icon: Icon(Icons.refresh),
                  label: 'Retry',
                  variant: ButtonVariant.ghost,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
