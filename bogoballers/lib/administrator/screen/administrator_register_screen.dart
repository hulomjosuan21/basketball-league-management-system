// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'package:bogoballers/administrator/screen/administrator_login_screen.dart';
import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/auth_navigator.dart';
import 'package:bogoballers/core/components/error.dart';
import 'package:bogoballers/core/components/image_picker.dart';
import 'package:bogoballers/core/components/password_field.dart';
import 'package:bogoballers/core/components/snackbars.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:bogoballers/core/utils/terms.dart';
import 'package:bogoballers/core/validations/auth_validations.dart';
import 'dart:convert';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/services/league_administrator_services.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bogoballers/core/models/location_data.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
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
  bool isLoading = false;
  bool hasAcceptedTerms = false;
  late Future<String> _termsFuture;
  List<String> _organization_types = [];
  List<String> _municipalities = [];
  Map<String, List<String>> _barangaysMap = {};
  List<String> _filteredBarangays = [];

  String? _selectedOrgType;
  String? _selectedMunicipality;
  String? _selectedBarangay;

  String initialCountry = 'PH';
  bool isValidPhoneNumber = false;
  String? fullPhoneNumber;
  PhoneNumber number = PhoneNumber(isoCode: 'PH');
  late Future<void> _networkDataFuture;

  AppImagePickerController logoController = AppImagePickerController();

  @override
  void initState() {
    super.initState();
    _networkDataFuture = loadNetworkData();
  }

  Future<void> loadNetworkData() async {
    try {
      final results = await Future.wait([
        getOrganizationTypes(),
        getLocationData(),
        _loadTermsAndConditions(),
      ]);

      _organization_types = results[0] as List<String>;
      LocationData? locations = results[1] as LocationData?;
      _termsFuture = Future.value(results[2] as String);

      if (locations != null) {
        _municipalities = locations.municipalities;
        _barangaysMap = locations.barangays;
      }
      setState(() {});
    } on DioException catch (_) {
      throw AppException("Network error!");
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _loadTermsAndConditions() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/data/terms_and_conditions.json',
      );
      Map<String, dynamic> data = jsonDecode(jsonString);
      return data['terms_and_conditions'] ??
          'Error: Terms and conditions not found.';
    } catch (e) {
      return 'Failed to load terms and conditions.';
    }
  }

  void _onOrgTypeChanged(String? orgtype) {
    setState(() {
      _selectedOrgType = orgtype;
    });
  }

  void _onMunicipalityChanged(String? muni) {
    setState(() {
      _selectedMunicipality = muni;
      _filteredBarangays = muni != null ? (_barangaysMap[muni] ?? []) : [];
      _selectedBarangay = null;
    });
  }

  void _onBarangayChanged(String? barangay) {
    setState(() {
      _selectedBarangay = barangay;
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
        selectedMunicipality: _selectedMunicipality,
        selectedBarangay: _selectedBarangay,
        emailController: emailController,
        passwordController: passwordController,
        fullPhoneNumber: fullPhoneNumber,
      );

      if (passwordController.text != confirmPassController.text) {
        throw ValidationException("Passwords don't match!");
      }

      final user = UserModel.create(
        email: emailController.text,
        password_str: passwordController.text,
        contact_number: fullPhoneNumber!,
        account_type: AccountTypeEnum.LOCAL_ADMINISTRATOR,
      );

      final multipartFile = logoController.multipartFile;
      if (multipartFile == null) {
        throw ValidationException("Please select an organization logo!");
      }

      final leagueAdministrator = LeagueAdministratorModel.create(
        organization_name: orgNameController.text,
        organization_type: _selectedOrgType!,
        municipality_name: _selectedMunicipality!,
        barangay_name: _selectedBarangay!,
        user: user,
        organization_logo_file: multipartFile,
      );

      final response = await leagueAdministratorService.registerAccount(
        leagueAdministrator: leagueAdministrator,
      );

      if (mounted &&
          response.redirect != null &&
          response.redirect! == "/administrator/login") {
        showAppSnackbar(
          context,
          message: response.message,
          title: "Success",
          variant: SnackbarVariant.success,
        );

        Navigator.pushNamed(context, response.redirect!);
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
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final infoControls = Row(
      children: [
        Expanded(
          child: TextField(
            controller: orgNameController,
            decoration: const InputDecoration(labelText: 'Organization Name'),
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

    final placeControls = Row(
      children: [
        Expanded(
          child: DropdownMenu<String>(
            key: const ValueKey('muni_dropdown'),
            initialSelection: _selectedMunicipality,
            onSelected: _onMunicipalityChanged,
            enableFilter: true,
            enableSearch: true,
            dropdownMenuEntries: _municipalities
                .map((m) => DropdownMenuEntry(value: m, label: m))
                .toList(),
            label: const Text('Select Municipality'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_selectedMunicipality == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select municipality first'),
                  ),
                );
              }
            },
            child: AbsorbPointer(
              absorbing: _selectedMunicipality == null,
              child: DropdownMenu<String>(
                key: const ValueKey('brgy_dropdown'),
                enabled: _selectedMunicipality != null,
                initialSelection: _selectedBarangay,
                onSelected: _onBarangayChanged,
                enableFilter: true,
                enableSearch: true,
                dropdownMenuEntries: _filteredBarangays
                    .map((b) => DropdownMenuEntry(value: b, label: b))
                    .toList(),
                label: const Text('Select Barangay'),
              ),
            ),
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
      InternationalPhoneNumberInput(
        countries: ['PH', 'US'],
        onInputChanged: (PhoneNumber number) {
          setState(() {
            fullPhoneNumber = number.phoneNumber ?? '';
          });
        },
        onInputValidated: (_) {
          setState(() {
            isValidPhoneNumber = true;
          });
        },
        ignoreBlank: false,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Phone number is required';
          }

          final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

          if (digitsOnly.length != 10) {
            return 'Phone number must be exactly 10 digits';
          }
          if (!digitsOnly.startsWith('9')) {
            return 'Phone number must start with 9';
          }
          return null;
        },
        autoValidateMode: AutovalidateMode.onUserInteraction,
        initialValue: number,
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
                                  infoControls,
                                  const SizedBox(height: Sizes.spaceMd),
                                  logoWidget,
                                  const SizedBox(height: Sizes.spaceMd),
                                  placeControls,
                                  const SizedBox(height: Sizes.spaceMd),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: "Email",
                                    ),
                                    controller: emailController,
                                  ),
                                  const SizedBox(height: Sizes.spaceMd),
                                  ...contactControlls,
                                  const SizedBox(height: Sizes.spaceMd),
                                  termAndCondition(
                                    context,
                                    hasAcceptedTerms,
                                    _termsFuture,
                                    (value) {
                                      setState(() {
                                        hasAcceptedTerms = value ?? false;
                                      });
                                    },
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
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const AdministratorLoginScreen(),
                                            ),
                                          );
                                        },
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
}
