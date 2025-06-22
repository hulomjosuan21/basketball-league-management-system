// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'package:bogoballers/core/widgets/phone_number_input.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/auth_navigator.dart';
import 'package:bogoballers/core/widgets/error.dart';
import 'package:bogoballers/core/widgets/image_picker.dart';
import 'package:bogoballers/core/widgets/password_field.dart';
import 'package:bogoballers/core/widgets/snackbars.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/helpers/helpers.dart';
import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:bogoballers/core/utils/terms.dart';
import 'package:bogoballers/core/validations/auth_validations.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/services/league_administrator_services.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdministratorRegisterScreen extends StatefulWidget {
  const AdministratorRegisterScreen({super.key});

  @override
  State<AdministratorRegisterScreen> createState() =>
      _AdministratorRegisterScreenState();
}

class _AdministratorRegisterScreenState
    extends State<AdministratorRegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();
  final orgNameController = TextEditingController();
  final orgAddressController = TextEditingController();
  bool isLoading = false;
  bool hasAcceptedTerms = false;

  String? _selectedOrgType;
  String? phoneNumber;
  late Future<void> _networkDataFuture;

  AppImagePickerController logoController = AppImagePickerController();

  List<String> _organization_types = [];
  @override
  void initState() {
    super.initState();
    _networkDataFuture = loadNetworkData();
  }

  Future<void> loadNetworkData() async {
    try {
      final types = await organizationTypeList();
      setState(() {
        _organization_types = types;
      });
    } on DioException catch (_) {
      throw AppException("Network error!");
    } catch (e) {
      rethrow;
    }
  }

  void _onOrgTypeChanged(String? orgtype) {
    setState(() {
      _selectedOrgType = orgtype;
    });
  }

  Future<void> handleRegister() async {
    setState(() {
      isLoading = true;
    });
    try {
      final leagueAdministratorService = LeagueAdministratorServices();

      validateOrganizationFields(
        orgNameController: orgNameController,
        selectedOrgType: _selectedOrgType,
        addressController: orgAddressController,
        emailController: emailController,
        passwordController: passwordController,
        fullPhoneNumber: phoneNumber,
      );

      if (passwordController.text != confirmPassController.text) {
        throw ValidationException("Passwords don't match!");
      }

      final user = UserModel.create(
        email: emailController.text,
        password_str: passwordController.text,
        contact_number: phoneNumber!,
        account_type: AccountTypeEnum.LOCAL_ADMINISTRATOR,
      );

      final multipartFile = logoController.multipartFile;
      if (multipartFile == null) {
        throw ValidationException("Please select an organization logo!");
      }

      final leagueAdministrator = LeagueAdministratorModel.create(
        organization_name: orgNameController.text,
        organization_type: _selectedOrgType!,
        organization_address: orgAddressController.text,
        user: user,
        organization_logo: multipartFile,
      );

      final response = await leagueAdministratorService.createNewAdministrator(
        leagueAdministrator: leagueAdministrator,
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
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressAndOrgType = Row(
      children: [
        Expanded(
          child: TextField(
            controller: orgAddressController,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
        ),
        const SizedBox(width: Sizes.spaceMd),
        Expanded(
          child: DropdownMenu<String>(
            key: const ValueKey('org_dropdown'),
            initialSelection: _selectedOrgType,
            onSelected: _onOrgTypeChanged,
            enableFilter: true,
            dropdownMenuEntries: _organization_types
                .map((o) => DropdownMenuEntry(value: o, label: o))
                .toList(),
            label: const Text('Organization Type'),
          ),
        ),
      ],
    );

    final logoWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppImagePicker(controller: logoController, aspectRatio: 1),
        const SizedBox(height: Sizes.spaceSm),
        AppButton(
          label: 'Select Organization Logo/Image',
          onPressed: logoController.pickImage,
          variant: ButtonVariant.outline,
          size: ButtonSize.sm,
        ),
      ],
    );

    final contactControlls = <Widget>[
      Row(
        children: [
          const SizedBox(width: Sizes.spaceMd),
          Expanded(
            child: PasswordField(
              controller: passwordController,
              hintText: 'Password',
            ),
          ),
          const SizedBox(width: Sizes.spaceMd),
          Expanded(
            child: PasswordField(
              controller: confirmPassController,
              hintText: 'Confirm Password',
            ),
          ),
        ],
      ),
      const SizedBox(height: Sizes.spaceMd),
      PHPhoneInput(
        phoneValue: phoneNumber,
        onChanged: (phone) {
          phoneNumber = phone;
        },
      ),
      const SizedBox(width: Sizes.spaceLg),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: (note, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                handleRegister();
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
              child: FutureBuilder(
                future: _networkDataFuture,
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator(
                      color: context.appColors.accent900,
                    );
                  } else if (asyncSnapshot.hasError) {
                    return retryError(context, asyncSnapshot.error, () {
                      setState(() {
                        _networkDataFuture = loadNetworkData();
                      });
                    });
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(Sizes.spaceLg),
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: context.appColors.accent900,
                          )
                        : ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 550),
                            child: Container(
                              padding: const EdgeInsets.all(Sizes.spaceMd),
                              decoration: BoxDecoration(
                                color: context.appColors.gray100,
                                borderRadius: BorderRadius.circular(
                                  Sizes.radiusMd,
                                ),
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
                                      "Register Organization",
                                      style: TextStyle(
                                        fontSize: Sizes.fontSizeXl,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: Sizes.spaceMd),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: "Organization Name",
                                    ),
                                    controller: orgNameController,
                                  ),
                                  const SizedBox(height: Sizes.spaceMd),
                                  logoWidget,
                                  const SizedBox(height: Sizes.spaceMd),
                                  addressAndOrgType,
                                  const SizedBox(height: Sizes.spaceMd),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: "Email",
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                    controller: emailController,
                                  ),
                                  const SizedBox(height: Sizes.spaceMd),
                                  ...contactControlls,
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
                                  const SizedBox(height: Sizes.spaceMd),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      authNavigator(
                                        context,
                                        "Already have an account?",
                                        " Login",
                                        () => Navigator.pushReplacementNamed(
                                          context,
                                          '/administrator/login/sreen',
                                        ),
                                      ),
                                      AppButton(
                                        label: "Register",
                                        onPressed: handleRegister,
                                        isDisabled: !hasAcceptedTerms,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
