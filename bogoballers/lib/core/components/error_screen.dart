import 'package:bogoballers/core/theme/theme.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:flutter/material.dart';

MaterialApp appFullScreenError(
  BuildContext context,
  Object? error,
  void Function() callback,
) {
  return MaterialApp(
    title: 'Administrator App',
    theme: lightTheme(context),
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(getErrorMessage(error!)),
            const SizedBox(height: 16),
            MaterialButton(
              onPressed: () {
                callback();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    ),
    debugShowCheckedModeBanner: false,
  );
}
