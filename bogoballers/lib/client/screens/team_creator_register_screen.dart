import 'package:bogoballers/core/components/phone_number_input.dart';
import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/password_field.dart';
import 'package:bogoballers/core/components/snackbars.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/services/team_creator_services.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/utils/terms.dart';
import 'package:bogoballers/core/validations/auth_validations.dart';
import 'package:flutter/material.dart';

class TeamCreatorRegisterScreen extends StatefulWidget {
  const TeamCreatorRegisterScreen({super.key});

  @override
  State<TeamCreatorRegisterScreen> createState() =>
      _TeamCreatorRegisterScreenState();
}

class _TeamCreatorRegisterScreenState extends State<TeamCreatorRegisterScreen> {
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  String? phoneNumber;
  bool hasAcceptedTerms = false;
  bool isRegistering = false;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      body: Center(
        child: isRegistering
            ? CircularProgressIndicator(color: context.appColors.accent900)
            : SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 350),
                  padding: const EdgeInsets.all(Sizes.spaceMd),
                  decoration: BoxDecoration(
                    color: appColors.gray100,
                    border: Border.all(
                      width: Sizes.borderWidthSm,
                      color: appColors.gray600,
                    ),
                    borderRadius: BorderRadius.circular(Sizes.radiusMd),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Register as a Team Creator",
                        style: TextStyle(
                          fontSize: Sizes.fontSizeMd,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Sizes.spaceSm),
                      Text(
                        "Fill in the required details below to create your profile.",
                        style: TextStyle(
                          fontSize: 11,
                          color: appColors.gray800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Sizes.spaceMd),
                      PHPhoneInput(
                        phoneValue: phoneNumber,
                        onChanged: (phone) => phoneNumber = phone,
                      ),
                      const SizedBox(height: Sizes.spaceMd),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: Sizes.spaceMd),
                      PasswordField(
                        controller: passwordController,
                        hintText: 'Password',
                      ),
                      const SizedBox(height: Sizes.spaceMd),
                      PasswordField(
                        controller: confirmPassController,
                        hintText: 'Confirm Password',
                      ),
                      const SizedBox(height: Sizes.spaceMd),
                      termAndCondition(
                        context: context,
                        hasAcceptedTerms: hasAcceptedTerms,
                        onChanged: (value) {
                          setState(() {
                            hasAcceptedTerms = value ?? false;
                          });
                        },
                        key: 'auth_terms_and_conditions',
                      ),
                      const SizedBox(height: Sizes.spaceLg),
                      AppButton(
                        label: "Register",
                        onPressed: _handleRegister,
                        isDisabled: !hasAcceptedTerms,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    setState(() {
      isRegistering = true;
    });
    try {
      validateTeamCreatorFields(
        emailController: emailController,
        passwordController: passwordController,
        phoneNumber: phoneNumber,
        confirmPassController: confirmPassController,
      );

      final user = UserModel.create(
        email: emailController.text,
        contact_number: phoneNumber!,
        password_str: passwordController.text,
        account_type: AccountTypeEnum.TEAM_CREATOR,
      );

      final service = TeamCreatorServices();

      final response = await service.createNewTeamCreator(user);

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
        setState(() {
          isRegistering = false;
        });
      }
    }
  }
}
