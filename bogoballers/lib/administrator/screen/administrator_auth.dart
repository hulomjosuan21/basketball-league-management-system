import 'package:bogoballers/components/app_button.dart';
import 'package:bogoballers/components/snackbars.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/services/league_administrator_service.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AdministratorRegisterScreen extends StatefulWidget {
  const AdministratorRegisterScreen({super.key});

  @override
  State<AdministratorRegisterScreen> createState() =>
      _AdministratorRegisterScreenState();
}

class _AdministratorRegisterScreenState
    extends State<AdministratorRegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Future<void> handleRegister() async {
      setState(() {
        isLoading = true;
      });
      try {
        final leagueAdministratorService = LeagueAdministratorService();

        final newAdministrator = UserModel.create(
          email: emailController.text,
          password_str: passwordController.text,
          account_type: AccountTypeEnum.League_Administrator,
        );

        await leagueAdministratorService.registerAccount(
          newAdministrator: newAdministrator,
        );
      } catch (e) {
        if (context.mounted) {
          handleDioError(context, e, (message) {
            showErrorSnackbar(context, message);
          });
        }
      } finally {
        if (context.mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }

    final registerControllers = GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 0,
      childAspectRatio: 3 / 1,
      children: [
        TextField(
          decoration: InputDecoration(labelText: "Email"),
          controller: emailController,
        ),
        TextField(
          decoration: InputDecoration(labelText: "Password"),
          obscureText: true,
          obscuringCharacter: '*',
          controller: passwordController,
        ),
      ],
    );

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

              registerControllers,

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
                    onPressed: handleRegister,
                    variant: ButtonVariant.primary,
                    size: ButtonSize.lg,
                    isDisabled: isLoading,
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
