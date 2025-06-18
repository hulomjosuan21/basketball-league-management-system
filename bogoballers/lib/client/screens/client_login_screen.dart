import 'dart:async';

import 'package:bogoballers/client/screens/client_register_screen.dart';
import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/auth_navigator.dart';
import 'package:bogoballers/core/components/password_field.dart';
import 'package:bogoballers/core/components/snackbars.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/services/client_services.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/validations/auth_validations.dart';
import 'package:flutter/material.dart';

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> handleLogin() async {
    setState(() => isLoading = true);
    try {
      validateLoginFields(
        emailController: emailController,
        passwordController: passwordController,
      );

      final user = UserModel.login(
        email: emailController.text,
        password_str: passwordController.text,
      );

      final service = ClientServices();

      final response = await service.loginAccount(user);

      if (mounted) {
        showAppSnackbar(
          context,
          message: response.message,
          title: "Success",
          variant: SnackbarVariant.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        handleErrorCallBack(e, (message) {
          showAppSnackbar(
            context,
            message: message,
            title: "Error",
            variant: SnackbarVariant.error,
          );
        });
      }
    } finally {
      if (context.mounted) {
        scheduleMicrotask(() => setState(() => isLoading = false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final loginControll = <Widget>[
      const SizedBox(height: Sizes.spaceMd),
      TextField(
        decoration: const InputDecoration(label: Text("Email")),
        controller: emailController,
      ),
      const SizedBox(height: Sizes.spaceMd),
      PasswordField(controller: passwordController, hintText: "Password"),
    ];

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: appColors.secondaryGradient),
          child: Center(
            child: isLoading
                ? CircularProgressIndicator(color: context.appColors.accent900)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(Sizes.spaceLg),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Container(
                        padding: const EdgeInsets.all(Sizes.spaceMd),
                        decoration: BoxDecoration(
                          color: context.appColors.gray100,
                          borderRadius: BorderRadius.circular(Sizes.radiusMd),
                          border: Border.all(
                            width: Sizes.borderWidthSm,
                            color: context.appColors.gray600,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                "Welcome",
                                style: TextStyle(
                                  fontSize: Sizes.fontSizeXl,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ...loginControll,
                            const SizedBox(height: Sizes.spaceLg),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                authNavigator(
                                  context,
                                  "Don't have an account yet?",
                                  " Register",
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ClientRegisterScreen(),
                                      ),
                                    );
                                  },
                                ),
                                AppButton(
                                  label: "Login",
                                  onPressed: handleLogin,
                                  isDisabled: isLoading,
                                  size: ButtonSize.sm,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
