import 'dart:convert';
import 'package:bogoballers/client/screens/client_login_screen.dart';
import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/auth_navigator.dart';
import 'package:bogoballers/core/components/error.dart';
import 'package:bogoballers/core/components/image_picker.dart';
import 'package:bogoballers/core/components/password_field.dart';
import 'package:bogoballers/core/components/snackbars.dart';
import 'package:bogoballers/core/enums/gender_enum.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/models/location_data.dart';
import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/services/player_services.dart';
import 'package:bogoballers/core/services/team_creator_services.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/utils/terms.dart';
import 'package:bogoballers/core/validations/auth_validations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({super.key});

  @override
  State<ClientRegisterScreen> createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ValueNotifier<Gender?> selectedGender = ValueNotifier(null);
  final TextEditingController birthdateController = TextEditingController();
  final List<String> positions = ["Guard", "Forward", "Center"];
  final ValueNotifier<Set<String>> selectedPositions = ValueNotifier({});
  AppImagePickerController profileImageController = AppImagePickerController();

  List<String> _municipalities = [];
  Map<String, List<String>> _barangaysMap = {};
  List<String> _filteredBarangays = [];

  String? _selectedMunicipality;
  String? _selectedBarangay;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final bdayController = TextEditingController();
  final jerseyNameController = TextEditingController();
  final jerseyNumberController = TextEditingController();

  String initialCountry = 'PH';
  bool isValidPhoneNumber = false;
  String? fullPhoneNumber;
  PhoneNumber number = PhoneNumber(isoCode: 'PH');

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();
  bool hasAcceptedTerms = false;
  late Future<String> _termsFuture;
  late Future<void> _networkDataFuture;
  String? selectedAccountType;

  bool isRegistering = false;

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

  @override
  void initState() {
    super.initState();
    _networkDataFuture = loadNetworkData();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> loadNetworkData() async {
    try {
      final results = await Future.wait([
        getLocationData(),
        _loadTermsAndConditions(),
      ]);
      LocationData? locations = results[0] as LocationData?;
      _termsFuture = Future.value(results[1] as String);
      if (locations != null) {
        _municipalities = locations.municipalities;
        _barangaysMap = locations.barangays;
      }
    } on DioException catch (_) {
      throw AppException("Network error!");
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToPreviousTab() {
    if (_tabController.index > 0) {
      setState(() {
        _tabController.index = _tabController.index - 1;
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

  Future<void> handleRegisterPlayer() async {
    setState(() {
      isRegistering = true;
    });

    try {
      validatePlayerFields(
        firstNameController: firstNameController,
        lastNameController: lastNameController,
        selectedGender: selectedGender,
        birthdateController: birthdateController,
        jerseyNameController: jerseyNameController,
        jerseyNumberController: jerseyNumberController,
        selectedPositions: selectedPositions,
        emailController: emailController,
        passwordController: passwordController,
        confirmPassController: confirmPassController,
        fullPhoneNumber: fullPhoneNumber,
        selectedMunicipality: _selectedMunicipality,
        selectedBarangay: _selectedBarangay,
      );
      final multipartFile = profileImageController.multipartFile;
      final user = UserModel.create(
        email: emailController.text,
        contact_number: fullPhoneNumber!,
        password_str: passwordController.text,
        account_type: AccountTypeEnum.values.byName(selectedAccountType!),
      );

      if (multipartFile == null) {
        throw ValidationException("Please select an organization logo!");
      }
      final player = PlayerModel.create(
        first_name: firstNameController.text,
        last_name: lastNameController.text,
        gender: selectedGender.value!.name,
        birth_date: DateTime.parse(birthdateController.text),
        barangay_name: _selectedBarangay!,
        municipality_name: _selectedMunicipality!,
        jersey_name: jerseyNameController.text,
        jersey_number: double.parse(jerseyNumberController.text),
        position: selectedPositions.value.join(', '),
        user: user,
        profile_image_file: multipartFile,
      );

      final service = PlayerServices();

      final response = await service.registerAccount(player);
      if (mounted) {
        showAppSnackbar(
          context,
          message: response,
          title: "Success",
          variant: SnackbarVariant.success,
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
          isRegistering = false;
        });
      }
    }
  }

  Future<void> handleRegisterTeamCreator() async {
    setState(() {
      isRegistering = true;
    });
    try {
      validateTeamCreatorFields(
        emailController: emailController,
        passwordController: passwordController,
        confirmPassController: confirmPassController,
        fullPhoneNumber: fullPhoneNumber,
      );

      final user = UserModel.create(
        email: emailController.text,
        contact_number: fullPhoneNumber!,
        password_str: passwordController.text,
      );

      final service = TeamCreatorServices();

      final response = await service.registerAccount(user);

      if (mounted) {
        showAppSnackbar(
          context,
          message: response,
          title: "Success",
          variant: SnackbarVariant.success,
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
          isRegistering = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    Widget buildAccountTypeItemCard(
      String text,
      IconData icon,
      VoidCallback onSelect,
    ) {
      return InkWell(
        onTap: () {
          setState(() {
            if (_tabController.index < 1) {
              _tabController.index = _tabController.index + 1;
            }
          });
          onSelect();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(12),
          width: 200,
          decoration: BoxDecoration(
            color: appColors.gray100,
            border: Border.all(width: 0.5, color: appColors.gray600),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: appColors.accent600),
              SizedBox(height: 8),
              Text(
                text,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildSelectAccountType() {
      return SingleChildScrollView(
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Are you a?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                buildAccountTypeItemCard("Player", Icons.sports_basketball, () {
                  selectedAccountType = "Player";
                }),
                SizedBox(height: 16),
                buildAccountTypeItemCard("Team Creator", Icons.groups, () {
                  setState(() {
                    selectedAccountType = "Team_Creator";
                  });
                }),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildPlayerRegisterInputs() {
      return Container(
        constraints: BoxConstraints(maxWidth: 350),
        margin: EdgeInsets.symmetric(vertical: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: appColors.gray100,
          border: Border.all(width: 0.5, color: appColors.gray600),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Register as a Player",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Fill in the required details below to create your profile.",
                    style: TextStyle(fontSize: 11, color: appColors.gray800),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            AppImagePicker(controller: profileImageController, aspectRatio: 1),
            SizedBox(height: 8),
            AppButton(
              label: 'Select Image',
              onPressed: profileImageController.pickImage,
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
            ),
            SizedBox(height: 4),
            Center(
              child: Text(
                '* Please provide a valid and proper player profile image. This is required for league validation.',
                style: TextStyle(fontSize: 10, color: appColors.gray800),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(label: Text("First name")),
            ),
            SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(label: Text("Last name")),
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Gender",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ValueListenableBuilder<Gender?>(
                  valueListenable: selectedGender,
                  builder: (context, gender, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Radio<Gender>(
                              value: Gender.Male,
                              groupValue: gender,
                              onChanged: (Gender? value) {
                                selectedGender.value = value;
                              },
                            ),
                            Text("Male", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        SizedBox(width: 16),
                        Row(
                          children: [
                            Radio<Gender>(
                              value: Gender.Female,
                              groupValue: gender,
                              onChanged: (Gender? value) {
                                selectedGender.value = value;
                              },
                            ),
                            Text("Female", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: birthdateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Birthdate",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  birthdateController.text = "${pickedDate.toLocal()}".split(
                    ' ',
                  )[0];
                }
              },
            ),
            SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: double.infinity,
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
            ),
            SizedBox(height: 16),
            GestureDetector(
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
                child: SizedBox(
                  width: double.infinity,
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
            SizedBox(height: 16),
            TextField(
              controller: jerseyNameController,
              decoration: InputDecoration(label: Text("Jersey name")),
            ),
            SizedBox(height: 16),
            TextField(
              controller: jerseyNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(label: Text("Jersey number")),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                "Choose up to two positions",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 8),
            ValueListenableBuilder<Set<String>>(
              valueListenable: selectedPositions,
              builder: (context, selected, _) {
                return Column(
                  children: positions.map((position) {
                    return CheckboxListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text(position, style: TextStyle(fontSize: 12)),
                      value: selected.contains(position),
                      onChanged: (bool? checked) {
                        if (checked == true && selected.length >= 2) {
                          showAppSnackbar(
                            context,
                            message:
                                "You can only select two positions. Deselect one to choose another.",
                            title: "Selection Limit Reached",
                            variant: SnackbarVariant.warning,
                          );
                          return;
                        }
                        selectedPositions.value = Set.from(selected)
                          ..toggle(position, checked);
                      },
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 16),
            InternationalPhoneNumberInput(
              countries: ['PH'],
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
                  return 'Phone number\nis required';
                }

                final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

                if (digitsOnly.length != 10) {
                  return 'Phone number must\nbe exactly 10 digits';
                }
                if (!digitsOnly.startsWith('9')) {
                  return 'Phone number must\nstart with 9';
                }
                return null;
              },
              autoValidateMode: AutovalidateMode.onUserInteraction,
              initialValue: number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(label: Text("Email")),
            ),
            SizedBox(height: 16),
            PasswordField(controller: passwordController, hintText: 'Password'),
            SizedBox(height: 16),
            PasswordField(
              controller: confirmPassController,
              hintText: 'Confirm Passowrd',
            ),
            SizedBox(height: 16),
            termAndCondition(context, hasAcceptedTerms, _termsFuture, (value) {
              setState(() {
                hasAcceptedTerms = value ?? false;
              });
            }),
            SizedBox(height: 24),
            AppButton(
              label: "Register",
              onPressed: handleRegisterPlayer,
              size: ButtonSize.sm,
              isDisabled: !hasAcceptedTerms,
            ),
          ],
        ),
      );
    }

    Widget buildTeamCreatorRegisterInputs() {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 350),
            margin: EdgeInsets.symmetric(vertical: 16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: appColors.gray100,
              border: Border.all(width: 0.5, color: appColors.gray600),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Register as a Team Creator",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Fill in the required details below to create your profile.",
                        style: TextStyle(
                          fontSize: 11,
                          color: appColors.gray800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                InternationalPhoneNumberInput(
                  countries: ['PH'],
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
                      return 'Phone number\nis required';
                    }

                    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

                    if (digitsOnly.length != 10) {
                      return 'Phone number must\nbe exactly 10 digits';
                    }
                    if (!digitsOnly.startsWith('9')) {
                      return 'Phone number must\nstart with 9';
                    }
                    return null;
                  },
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  initialValue: number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(label: Text("Email")),
                ),
                SizedBox(height: 16),
                PasswordField(
                  controller: passwordController,
                  hintText: 'Password',
                ),
                SizedBox(height: 16),
                PasswordField(
                  controller: confirmPassController,
                  hintText: 'Confirm Passowrd',
                ),
                SizedBox(height: 16),
                termAndCondition(context, hasAcceptedTerms, _termsFuture, (
                  value,
                ) {
                  setState(() {
                    hasAcceptedTerms = value ?? false;
                  });
                }),
                SizedBox(height: 24),
                AppButton(
                  label: "Register",
                  onPressed: handleRegisterTeamCreator,
                  size: ButtonSize.sm,
                  isDisabled: !hasAcceptedTerms,
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildTabTwoContent() {
      return SingleChildScrollView(
        child: Center(
          child: selectedAccountType == "Player"
              ? buildPlayerRegisterInputs()
              : buildTeamCreatorRegisterInputs(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: context.appColors.secondaryGradient,
          ),
          child: FutureBuilder(
            future: _networkDataFuture,
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: context.appColors.accent900,
                  ),
                );
              } else if (asyncSnapshot.hasError) {
                return Center(
                  child: retryError(context, asyncSnapshot.error, () {
                    setState(() {
                      _networkDataFuture = loadNetworkData();
                    });
                  }),
                );
              }

              return isRegistering
                  ? Center(
                      child: CircularProgressIndicator(
                        color: context.appColors.accent900,
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                context.appColors.gray100.withAlpha(255),
                                context.appColors.gray100.withAlpha(0),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              buildSelectAccountType(),
                              buildTabTwoContent(),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              if (_tabController.index > 0)
                                GestureDetector(
                                  onTap: _goToPreviousTab,
                                  child: Text(
                                    'Back',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.appColors.gray1100,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 8),
                              authNavigator(
                                context,
                                "Already have an account?",
                                " Login",
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ClientLoginScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}

extension ToggleSet<T> on Set<T> {
  void toggle(T item, bool? state) {
    state == true ? add(item) : remove(item);
  }
}
