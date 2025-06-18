import 'package:bogoballers/core/helpers/helpers.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

Widget termAndCondition({
  required BuildContext context,
  required bool hasAcceptedTerms,
  required void Function(bool?) onChanged,
  required String key,
}) {
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
                          future: termsAndConditionsContent(key: key),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return AlertDialog(
                                title: Text("Terms and Conditions"),
                                content: Center(
                                  child: CircularProgressIndicator(),
                                ),
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
                                  TextButton(
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
