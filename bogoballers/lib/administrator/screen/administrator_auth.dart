// ignore_for_file: non_constant_identifier_names

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/loading.dart';
import 'package:bogoballers/core/components/snackbars.dart';
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

Future<List<String>> getOrganizationTypes() async {
  final dioClient = DioClient();

  try {
    Response response = await dioClient.client.get('/organization-types');

    final apiResponse = ApiResponse<List<String>>.fromJson(
      response.data,
      (json) => List<String>.from(json),
    );
    return apiResponse.payload ?? [];
  } catch (e) {
    debugPrint('Error fetching organization types: $e');
    return [];
  }
}

Future<ApiResponse<LocationData>> getLocationData() async {
  final dioClient = DioClient();

  try {
    final response = await dioClient.client.get('/places');

    final apiResponse = ApiResponse<LocationData>.fromJson(
      response.data,
      (json) => LocationData.fromJson(json),
    );

    debugPrint(apiResponse.payload!.municipalities.toString());
    return apiResponse;
  } catch (e) {
    debugPrint('Error fetching location data: $e');
    return ApiResponse<LocationData>(
      status: false,
      message: 'Failed to fetch location data',
      payload: null,
    );
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
  bool isLoading = false;
  bool _isFetchingData = false;
  bool hasAcceptedTerms = false;
  late Future<String> _termsFuture;
  List<String> _organization_types = [];
  List<String> _municipalities = [];
  Map<String, List<String>> _barangaysMap = {};
  List<String> _filteredBarangays = [];

  String? _selectedMunicipality;
  String? _selectedBarangay;

  @override
  void initState() {
    super.initState();
    loadNetworkData();
    _termsFuture = _loadTermsAndConditions();
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
          future: _termsFuture, // Use the future we created
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text("Terms and Conditions"),
                content: CircularProgressIndicator(), // Show loading indicator
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
              // Data is loaded, display the dialog with the content
              return AlertDialog(
                title: Text(
                  "Terms and Conditions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                content: SingleChildScrollView(
                  // Add SingleChildScrollView for long text
                  child: Text(
                    snapshot.data!, // Use the loaded data
                  ),
                ),
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

  Future<void> loadNetworkData() async {
    setState(() {
      _isFetchingData = true;
    });

    try {
      _organization_types = await getOrganizationTypes();
      final locations = await getLocationData();

      if (locations.status && locations.payload != null) {
        _municipalities = locations.payload!.municipalities;
        _barangaysMap = locations.payload!.barangays;
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() {
        _isFetchingData = false;
      });
    }
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
    if (_isFetchingData) {
      return appFullScreenLoading(context);
    }

    Future<void> handleRegister() async {
      setState(() {
        isLoading = true;
      });
      try {
        final leagueAdministratorService = LeagueAdministratorService();
      } catch (e) {
        if (context.mounted) {
          handleDioError(context, e, (message) {
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
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownSearch<String>(
            key: ValueKey('org_dropdown'),
            items: (_, _) => _organization_types,
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

    final contactControlls = <Widget>[
      Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(labelText: "Email"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(labelText: "Password"),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(labelText: "Contact Number"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),
          ),
        ],
      ),
      const SizedBox(width: 24),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
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
                    placeControllers,
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
                                    color: context.appColors.accent900,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _showTermsDialog(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                        AppButton(label: "Test", onPressed: getLocationData),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
            title: "Welcome",
            contentType: ContentType.success,
          );
        }
      } catch (e) {
        if (context.mounted) {
          handleDioError(context, e, (message) {
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

    final loginControllers = Column(
      children: [
        TextField(
          decoration: InputDecoration(labelText: "Email"),
          controller: emailController,
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(labelText: "Password"),
          controller: passwordController,
          obscureText: true,
          obscuringCharacter: '*',
        ),
      ],
    );

    return Scaffold(body: Text("adsdds"));
  }
}
