import 'package:flutter/material.dart';

enum SnackbarVariant { success, error, warning, info }

void showAppSnackbar(
  BuildContext context, {
  required String message,
  String? title,
  SnackbarVariant variant = SnackbarVariant.success,
  Duration duration = const Duration(seconds: 4),
}) {
  final theme = Theme.of(context);
  final color = _getBackgroundColor(variant, theme);
  final icon = _getIcon(variant);
  final snackBarTitle = title ?? _getDefaultTitle(variant);

  final snackBar = SnackBar(
    elevation: 6,
    behavior: SnackBarBehavior.floating,
    backgroundColor: color,
    duration: duration,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    content: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snackBarTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Color _getBackgroundColor(SnackbarVariant variant, ThemeData theme) {
  switch (variant) {
    case SnackbarVariant.success:
      return Colors.green;
    case SnackbarVariant.error:
      return Colors.red;
    case SnackbarVariant.warning:
      return Colors.orange;
    case SnackbarVariant.info:
      return Colors.blue;
  }
}

IconData _getIcon(SnackbarVariant variant) {
  switch (variant) {
    case SnackbarVariant.success:
      return Icons.check_circle;
    case SnackbarVariant.error:
      return Icons.error;
    case SnackbarVariant.warning:
      return Icons.warning;
    case SnackbarVariant.info:
      return Icons.info;
  }
}

String _getDefaultTitle(SnackbarVariant variant) {
  switch (variant) {
    case SnackbarVariant.success:
      return 'Success';
    case SnackbarVariant.error:
      return 'Error';
    case SnackbarVariant.warning:
      return 'Warning';
    case SnackbarVariant.info:
      return 'Info';
  }
}
