import 'dart:async';

import 'package:bogoballers/client/screens/client_auth_screen.dart';
import 'package:bogoballers/client/team_creator/team_creator_main_screen.dart';
import 'package:bogoballers/client/widgets/sliding_announcement.dart';
import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/auth_navigator.dart';
import 'package:bogoballers/core/components/password_field.dart';
import 'package:bogoballers/core/components/snackbars.dart';
import 'package:bogoballers/core/constants/image_strings.dart';
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
  bool stayLoggedIn = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> handleLogin() async {
    setState(() => isLoading = true);
    try {
      // validateLoginFields(
      //   emailController: emailController,
      //   passwordController: passwordController,
      // );

      // final user = UserModel.login(
      //   email: emailController.text,
      //   password_str: passwordController.text,
      // );

      // final service = ClientServices();

      // final response = await service.loginAccount(user);

      // if (mounted) {
      //   showAppSnackbar(
      //     context,
      //     message: response.message,
      //     title: "Success",
      //     variant: SnackbarVariant.success,
      //   );
      // }
      await Future.delayed(Duration(seconds: 3));

      await Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => TeamCreatorMainScreen(),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      );
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

    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: context.appColors.accent900,
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Top banner with logo
                          Stack(
                            children: [
                              Container(
                                height: 400,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(ImageStrings.bgImg1),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        ImageStrings.appLogo,
                                        width: 80,
                                        height: 80,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "BogoBallers",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 4,
                                              color: Colors.black.withAlpha(
                                                128,
                                              ),
                                              offset: Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SlidingIntroBanner(),
                            ],
                          ),

                          // Login form fills remaining space
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: Sizes.spaceMd),
                                  TextField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                      label: Text("Email"),
                                    ),
                                  ),
                                  const SizedBox(height: Sizes.spaceMd),
                                  PasswordField(
                                    controller: passwordController,
                                    hintText: "Password",
                                  ),
                                  const SizedBox(height: Sizes.spaceSm),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: stayLoggedIn,
                                            onChanged: (value) => setState(
                                              () =>
                                                  stayLoggedIn = value ?? false,
                                            ),
                                          ),
                                          const Text(
                                            "Stay logged in",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {}, // forgot password
                                        child: Text(
                                          "Forgot password?",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: appColors.accent900,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: Sizes.spaceMd),
                                  AppButton(
                                    label: "Login",
                                    onPressed: handleLogin,
                                    width: double.infinity,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Register navigator
                          Center(
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: Sizes.spaceSm,
                                right: Sizes.spaceSm,
                                top: Sizes.spaceSm,
                                bottom: Sizes.spaceLg,
                              ),
                              child: authNavigator(
                                context,
                                "Don't have an account yet?",
                                " Register",
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ClientAuthScreen(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
