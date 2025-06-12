import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

Widget termAndCondition(
  BuildContext context,
  bool hasAcceptedTerms,
  Future<String> termsFuture,
  void Function(bool?) onChanged,
) {
  return Row(
    children: [
      Checkbox(value: hasAcceptedTerms, onChanged: onChanged),
      Expanded(
        child: Text.rich(
          TextSpan(
            text: 'I agree to the ',
            style: TextStyle(color: context.appColors.gray1100, fontSize: 11),
            children: [
              TextSpan(
                text: 'Terms and Conditions',
                style: TextStyle(
                  color: context.appColors.accent900,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return FutureBuilder<String>(
                          future: termsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return AlertDialog(
                                title: Text("Terms and Conditions"),
                                content: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return AlertDialog(
                                title: Text("Error"),
                                content: Text(
                                  "Error loading terms: ${snapshot.error}",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text("Close"),
                                  ),
                                ],
                              );
                            } else {
                              return AlertDialog(
                                title: Text(
                                  "Terms and Conditions",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: SingleChildScrollView(
                                  child: Text(snapshot.data!),
                                ),
                                actions: [
                                  MaterialButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text("Close"),
                                  ),
                                ],
                              );
                            }
                          },
                        );
                      },
                    );
                  },
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
