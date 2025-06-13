import 'dart:async';
import 'package:bogoballers/administrator/screen/administrator_register_screen.dart';
import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/auth_navigator.dart';
import 'package:bogoballers/core/components/password_field.dart';
import 'package:bogoballers/core/components/snackbars.dart';
import 'package:bogoballers/core/providers/league_adminstrator_provider.dart';
import 'package:bogoballers/core/validations/auth_validations.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/services/league_administrator_services.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class AdministratorLoginScreen extends StatefulWidget {
  const AdministratorLoginScreen({super.key});

  @override
  State<AdministratorLoginScreen> createState() =>
      _AdministratorLoginScreenState();
}

class _AdministratorLoginScreenState extends State<AdministratorLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Future<void> handleLogin() async {
      if (!context.mounted) return;

      setState(() => isLoading = true);

      try {
        final leagueAdministratorService = LeagueAdministratorServices();

        validateLoginFields(
          emailController: emailController,
          passwordController: passwordController,
        );

        final email = emailController.text.trim();
        final password = passwordController.text;
        if (email.isEmpty || password.isEmpty) {
          throw Exception('Email or password cannot be empty');
        }

        final user = UserModel.login(email: email, password_str: password);

        final response = await leagueAdministratorService.loginAccount(
          user: user,
        );

        if (response.payload != null && context.mounted) {
          final leagueAdministrator = await leagueAdministratorService
              .fetchLeagueAdministrator(user_id: response.payload!.user_id);

          if (leagueAdministrator.payload == null) {
            throw Exception('Failed to fetch administrator data');
          }

          scheduleMicrotask(() {
            if (context.mounted) {
              final leagueAdministratorProvider =
                  Provider.of<LeagueAdministratorProvider>(
                    context,
                    listen: false,
                  );
              leagueAdministratorProvider.setCurrentAdministrator(
                leagueAdministrator.payload!,
              );
            }
          });

          if (context.mounted &&
              response.redirect != null &&
              response.redirect! == "/administrator/main/screen") {
            showAppSnackbar(
              context,
              message: response.message,
              title: "Success",
              variant: SnackbarVariant.success,
            );
            Navigator.pushNamed(context, response.redirect!);
          }
        } else {
          throw AppException("Something went wrong!");
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

    final loginControll = <Widget>[
      const SizedBox(height: 16),
      TextField(
        decoration: const InputDecoration(label: Text("Email")),
        controller: emailController,
      ),
      const SizedBox(height: 16),
      PasswordField(controller: passwordController, hintText: "Password"),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                handleLogin();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: context.appColors.primaryGradient,
            ),
            child: Center(
              child: isLoading
                  ? CircularProgressIndicator(
                      color: context.appColors.accent900,
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.appColors.gray100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 0.5,
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ...loginControll,
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                              const AdministratorRegisterScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  AppButton(
                                    label: "Login",
                                    onPressed: handleLogin,
                                    isDisabled: isLoading,
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
      ),
    );
  }
}
