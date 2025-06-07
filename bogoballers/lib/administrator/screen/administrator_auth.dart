// ignore_for_file: non_constant_identifier_names

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:bogoballers/administrator/league_administrator.dart';
import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/error.dart';
import 'package:bogoballers/core/components/image_picker.dart';
import 'package:bogoballers/core/components/password_field.dart';
import 'package:bogoballers/core/components/snackbars.dart';
import 'package:bogoballers/core/models/league_administrator.dart';
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
import 'package:dropdown_search/dropdown_search.dart';
import 'package:bogoballers/core/models/location_data.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

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

  AppImagePickerController controller = AppImagePickerController();

  @override
  void initState() {
    super.initState();
    _networkDataFuture = loadNetworkData();
  }

  Future<void> loadNetworkData() async {
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

  @override
  Widget build(BuildContext context) {
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
          throw ValidationException("Password don't match!");
        }

        final user = UserModel.create(
          email: emailController.text,
          password_str: passwordController.text,
        );

        final leagueAdministrator = LeagueAdministratorModel.create(
          organization_name: orgNameController.text,
          organization_type: _selectedOrgType as String,
          municipality_name: _selectedMunicipality as String,
          barangay_name: _selectedBarangay as String,
          contact_number: fullPhoneNumber as String,
          user: user,
        );

        // final response = await leagueAdministratorService.registerAccount(
        //   newAdministrator: leagueAdministrator,
        // );

        // if (context.mounted) {
        //   showAppSnackbar(
        //     context,
        //     message: response,
        //     title: "Success",
        //     contentType: ContentType.success,
        //   );

        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => const AdministratorLoginScreen(),
        //     ),
        //   );
        // }
      } catch (e) {
        if (context.mounted) {
          handleErrorCallBack(e, (message) {
            showAppSnackbar(
              context,
              message: message,
              title: "Error",
              contentType: ContentType.failure,
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

    final infoControlls = Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(labelText: "Organization Name"),
            controller: orgNameController,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownSearch<String>(
            key: ValueKey('org_dropdown'),
            items: (_, _) => _organization_types,
            selectedItem: _selectedOrgType,
            onChanged: _onOrgTypeChanged,
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(labelText: 'Organization Type'),
            ),
            popupProps: PopupProps.menu(fit: FlexFit.loose),
          ),
        ),
      ],
    );

    final placeControllers = Row(
      children: [
        Expanded(
          child: DropdownSearch<String>(
            key: ValueKey('muni_dropdown'),
            items: (_, _) => _municipalities,
            selectedItem: _selectedMunicipality,
            onChanged: _onMunicipalityChanged,
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(labelText: 'Select Municipality'),
            ),
            popupProps: PopupProps.menu(
              fit: FlexFit.loose,
              showSearchBox: true,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_selectedMunicipality == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select municipality first')),
                );
              }
            },
            child: AbsorbPointer(
              absorbing: _selectedMunicipality == null,
              child: DropdownSearch<String>(
                key: ValueKey('brgy_dropdown'),
                items: (_, _) => _filteredBarangays,
                selectedItem: _selectedBarangay,
                onChanged: _onBarangayChanged,
                enabled: _selectedMunicipality != null,
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(labelText: 'Select Barangay'),
                ),
                popupProps: PopupProps.menu(
                  fit: FlexFit.loose,
                  showSearchBox: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final logoController = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppImagePicker(controller: controller, aspectRatio: 1),
        const SizedBox(height: 8),
        AppButton(
          label: 'Select Organization Logo/Image',
          onPressed: controller.pickImage,
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
                                infoControlls,
                                const SizedBox(height: 16),
                                logoController,
                                const SizedBox(height: 16),
                                placeControllers,
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
      setState(() {
        isLoading = true;
      });
      try {
        final leagueAdministratorService = LeagueAdministratorService();

        validateLoginFields(
          emailController: emailController,
          passwordController: passwordController,
        );

        final user = UserModel.login(
          email: emailController.text,
          password_str: passwordController.text,
        );

        final response = await leagueAdministratorService.loginAccount(
          user: user,
        );

        if (context.mounted) {
          showAppSnackbar(
            context,
            message: response.message,
            title: "Success",
            contentType: ContentType.success,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LeagueAdministratorMainScreen(),
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
              contentType: ContentType.failure,
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
