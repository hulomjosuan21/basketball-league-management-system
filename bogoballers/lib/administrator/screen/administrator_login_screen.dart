import 'package:bogoballers/client/widgets/sliding_announcement.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/auth_navigator.dart';
import 'package:bogoballers/core/widgets/password_field.dart';
import 'package:bogoballers/core/widgets/snackbars.dart';
import 'package:bogoballers/core/constants/image_strings.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/services/entity_services.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/validations/auth_validations.dart';
import 'package:flutter/material.dart';

class AdministratorLoginScreen extends StatefulWidget {
  const AdministratorLoginScreen({super.key});

  @override
  State<AdministratorLoginScreen> createState() =>
      _AdministratorLoginScreenState();
}

class _AdministratorLoginScreenState extends State<AdministratorLoginScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: context.appColors.accent900,
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isLargeScreen = constraints.maxWidth > 800;

                return isLargeScreen
                    ? Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
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
                          ),

                          // Right: Login Form
                          Container(
                            width: 340,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: _LoginForm(),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // Top Image
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

                            Container(
                              width: 340,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: _LoginForm(),
                              ),
                            ),
                          ],
                        ),
                      );
              },
            ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool stayLoggedIn = true;
  bool isLoading = false;

  Future<void> _handleLogin() async {
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

      final service = EntityServices();

      final response = await service.login(
        context: context,
        user: user,
        stayLoggedIn: stayLoggedIn,
      );
      if (mounted) {
        showAppSnackbar(
          context,
          message: response.message,
          title: "Success",
          variant: SnackbarVariant.success,
        );

        final redirect = response.redirect;
        if (redirect == null) {
          throw AppException("Something went wrong!");
        }

        await Navigator.pushReplacementNamed(context, redirect);
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
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return isLoading
        ? Center(child: CircularProgressIndicator(color: appColors.accent900))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Sizes.spaceMd),
              const Text(
                "Login to your account",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: Sizes.spaceMd),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: Sizes.spaceMd),

              PasswordField(
                controller: passwordController,
                hintText: "Password",
              ),
              const SizedBox(height: Sizes.spaceSm),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: stayLoggedIn,
                        onChanged: (value) {
                          setState(() {
                            stayLoggedIn = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        "Stay logged in",
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
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
                onPressed: _handleLogin,
                width: double.infinity,
              ),

              const SizedBox(height: Sizes.spaceMd),
              Center(
                child: authNavigator(
                  context,
                  "Don't have an account yet?",
                  " Register",
                  () => Navigator.pushReplacementNamed(
                    context,
                    '/administrator/register/screen',
                  ),
                ),
              ),
            ],
          );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
