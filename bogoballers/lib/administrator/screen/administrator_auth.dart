// ignore_for_file: non_constant_identifier_names
import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:bogoballers/administrator/league_administrator.dart';
import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/error.dart';
import 'package:bogoballers/core/components/image_picker.dart';
import 'package:bogoballers/core/components/password_field.dart';
import 'package:bogoballers/core/components/snackbars.dart';
import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:bogoballers/core/providers/league_adminstrator_provider.dart';
import 'package:bogoballers/core/utils/validators.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:bogoballers/core/services/league_administrator_service.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bogoballers/core/models/location_data.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

RichText authNavigator(
  BuildContext context,
  String text,
  String textTo,
  void Function() callback,
) {
  return RichText(
    text: TextSpan(
      text: text,
      style: TextStyle(color: context.appColors.gray1100, fontSize: 12),
      children: [
        TextSpan(
          text: textTo,
          style: TextStyle(
            color: context.appColors.accent900,
            fontWeight: FontWeight.w600,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              callback();
            },
        ),
      ],
    ),
  );
}

Future<List<String>> getOrganizationTypes() async {
  final dioClient = DioClient();
  Response response = await dioClient.client.get('/organization-types');

  final apiResponse = ApiResponse<List<String>>.fromJson(
    response.data,
    (json) => List<String>.from(json),
  );
  return apiResponse.payload ?? [];
}

Future<LocationData> getLocationData() async {
  final dioClient = DioClient();
  final response = await dioClient.client.get('/places');

  final apiResponse = ApiResponse<LocationData>.fromJson(
    response.data,
    (json) => LocationData.fromJson(json),
  );

  debugPrint(apiResponse.payload!.municipalities.toString());
  return apiResponse.payload!;
}

void validateOrganizationFields({
  required TextEditingController orgNameController,
  required String? selectedOrgType,
  required String? selectedMunicipality,
  required String? selectedBarangay,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required String? fullPhoneNumber,
}) {
  if (orgNameController.text.trim().isEmpty) {
    throw ValidationException("Organization name cannot be empty");
  }
  if (selectedOrgType == null || selectedOrgType.trim().isEmpty) {
    throw ValidationException("Organization type must be selected");
  }
  if (selectedMunicipality == null || selectedMunicipality.trim().isEmpty) {
    throw ValidationException("Municipality must be selected");
  }
  if (selectedBarangay == null || selectedBarangay.trim().isEmpty) {
    throw ValidationException("Barangay must be selected");
  }
  if (emailController.text.trim().isEmpty) {
    throw ValidationException("Email cannot be empty");
  }
  if (passwordController.text.trim().isEmpty) {
    throw ValidationException("Password cannot be empty");
  }
  if (fullPhoneNumber == null || fullPhoneNumber.trim().isEmpty) {
    throw ValidationException("Phone number cannot be empty");
  }
  if (!isValidateContactNumber(fullPhoneNumber)) {
    throw ValidationException("Invalid Phone number");
  }
}

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

  String? fullPhoneNumber;
  bool isValidPhoneNumber = false;
  String initialCountry = 'PH';
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

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<String>(
          future: _termsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text("Terms and Conditions"),
                content: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text("Error"),
                content: Text("Error loading terms: ${snapshot.error}"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Close"),
                  ),
                ],
              );
            } else {
              return AlertDialog(
                title: Text(
                  "Terms and Conditions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                content: SingleChildScrollView(child: Text(snapshot.data!)),
                actions: [
                  MaterialButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Close"),
                  ),
                ],
              );
            }
          },
        );
      },
    );
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
      final leagueAdministratorService = LeagueAdministratorService();

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
        contact_number: fullPhoneNumber!,
        user: user,
        organization_logo_file: multipartFile,
      );

      final response = await leagueAdministratorService.registerAccount(
        leagueAdministrator: leagueAdministrator,
      );

      if (mounted) {
        showAppSnackbar(
          context,
          message: response,
          title: "Success",
          variant: SnackbarVariant.success
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdministratorLoginScreen(),
          ),
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
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
// ---------- Row 1: org name + org type ----------
    final infoControls = Row(
      children: [
        Expanded(
          child: TextField(
            controller: orgNameController,
            decoration: const InputDecoration(labelText: 'Organization Name'),
          ),
        ),
        const SizedBox(width: 16),
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
                  const SnackBar(content: Text('Please select municipality first')),
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
        const SizedBox(height: 8),
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
          const SizedBox(width: 16),
          Expanded(
            child: PasswordField(
              controller: passwordController,
              hintText: 'Password',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PasswordField(
              controller: confirmPassController,
              hintText: 'Confirm Password',
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
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
      const SizedBox(width: 24),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: context.appColors.primaryGradient,
          ),
          child: Center(
            child: FutureBuilder(
              future: _networkDataFuture,
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
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
                  padding: const EdgeInsets.all(24),
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: context.appColors.accent900,
                        )
                      : ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 550),
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
                                    "Register Organization",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                infoControls,
                                const SizedBox(height: 16),
                                logoWidget,
                                const SizedBox(height: 16),
                                placeControls,
                                const SizedBox(height: 16),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: "Email",
                                  ),
                                  controller: emailController,
                                ),
                                const SizedBox(height: 16),
                                ...contactControlls,
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: hasAcceptedTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          hasAcceptedTerms = value ?? false;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          text: 'I agree to the ',
                                          style: TextStyle(
                                            color: context.appColors.gray1100,
                                            fontSize: 11,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Terms and Conditions',
                                              style: TextStyle(
                                                color:
                                                    context.appColors.accent900,
                                                decoration:
                                                    TextDecoration.underline,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () =>
                                                    _showTermsDialog(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
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
    );
  }
}

void validateLoginFields({
  required TextEditingController emailController,
  required TextEditingController passwordController,
}) {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty) {
    throw ValidationException("Email cannot be empty");
  }

  if (!isValidEmail(email)) {
    throw ValidationException("Invalid email format");
  }

  if (password.isEmpty) {
    throw ValidationException("Password cannot be empty");
  }
}

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
        final leagueAdministratorService = LeagueAdministratorService();

        validateLoginFields(
          emailController: emailController,
          passwordController: passwordController,
        );

        final email = emailController.text.trim();
        final password = passwordController.text;
        if (email.isEmpty || password.isEmpty) {
          throw Exception('Email or password cannot be empty');
        }

        final user = UserModel.login(
          email: email,
          password_str: password,
        );

        final response = await leagueAdministratorService
            .loginAccount(user: user);

        if (response.payload != null && context.mounted) {
          final leagueAdministrator = await leagueAdministratorService
              .fetchLeagueAdministrator(user_id: response.payload!.user_id);

          if (leagueAdministrator.payload == null) {
            throw Exception('Failed to fetch administrator data');
          }

          scheduleMicrotask(() {
            if (context.mounted) {
              final leagueAdministratorProvider =
                  Provider.of<LeagueAdministratorProvider>(context, listen: false);
              leagueAdministratorProvider.setCurrentAdministrator(
                leagueAdministrator.payload!,
              );
            }
          });

          if (context.mounted) {
            showAppSnackbar(
              context,
              message: response.message ?? 'Login successful',
              title: "Success",
              variant: SnackbarVariant.success,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LeagueAdministratorMainScreen(),
              ),
            );
          }
        } else {
          throw Exception('Invalid login response');
        }
      } catch (e) {
        if (context.mounted) {
          handleErrorCallBack(e, (message) {
            showAppSnackbar(
              context,
              message: message ?? 'An unexpected error occurred',
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
        child: Container(
          decoration: BoxDecoration(
            gradient: context.appColors.primaryGradient,
          ),
          child: Center(
            child: isLoading
                ? CircularProgressIndicator(color: context.appColors.accent900)
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
    );
  }
}
