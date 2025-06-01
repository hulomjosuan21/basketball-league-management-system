import 'package:bogoballers/components/app_button.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AdministratorRegisterScreen extends StatelessWidget {
  const AdministratorRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 600, // wide enough for 2 columns
          decoration: BoxDecoration(
            color: context.appColors.gray100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.appColors.gray600, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Create Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),

              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 0,
                childAspectRatio: 3 / 1,
                children: const [
                  TextField(decoration: InputDecoration(labelText: "Email")),
                  TextField(
                    decoration: InputDecoration(labelText: "Password"),
                    obscureText: true,
                    obscuringCharacter: '*',
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: context.appColors.gray1100,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            color: context.appColors.accent900,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdministratorLoginScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    label: "Register",
                    onPressed: () {
                      // Handle registration logic
                    },
                    variant: ButtonVariant.primary,
                    size: ButtonSize.lg,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdministratorLoginScreen extends StatelessWidget {
  const AdministratorLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 400,
          decoration: BoxDecoration(
            color: context.appColors.gray100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.appColors.gray600, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome Back",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),

              Column(
                children: [
                  TextField(decoration: InputDecoration(labelText: "Email")),
                  const SizedBox(height: 12),
                  TextField(decoration: InputDecoration(labelText: "Password")),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: context.appColors.gray1100,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: "Register",
                          style: TextStyle(
                            color: context.appColors.accent900,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdministratorRegisterScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    label: "Login",
                    onPressed: () {
                      // Handle registration logic
                    },
                    variant: ButtonVariant.primary,
                    size: ButtonSize.lg,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
