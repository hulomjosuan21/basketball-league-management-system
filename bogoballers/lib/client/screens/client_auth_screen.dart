import 'dart:convert';

import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/image_picker.dart';
import 'package:bogoballers/core/components/password_field.dart';
import 'package:bogoballers/core/components/snackbars.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/services/player_services.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/utils/validators.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({super.key});

  @override
  State<ClientRegisterScreen> createState() => _ClientRegisterScreenState();
}

enum Gender { Male, Female }

void validatePlayerFields({
  required TextEditingController firstNameController,
  required TextEditingController lastNameController,
  required ValueNotifier<Gender?> selectedGender,
  required TextEditingController birthdateController,
  required TextEditingController jerseyNameController,
  required TextEditingController jerseyNumberController,
  required ValueNotifier<Set<String>> selectedPositions,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required TextEditingController confirmPassController,
  required String? fullPhoneNumber,
}) {
  if (firstNameController.text.trim().isEmpty) {
    throw ValidationException("First name cannot be empty");
  }
  if (lastNameController.text.trim().isEmpty) {
    throw ValidationException("Last name cannot be empty");
  }
  if (selectedGender.value == null) {
    throw ValidationException("Gender must be selected");
  }
  if (birthdateController.text.trim().isEmpty) {
    throw ValidationException("Birthdate must be selected");
  }
  if (jerseyNameController.text.trim().isEmpty) {
    throw ValidationException("Jersey name cannot be empty");
  }
  if (jerseyNumberController.text.trim().isEmpty) {
    throw ValidationException("Jersey number cannot be empty");
  }
  if (double.tryParse(jerseyNumberController.text) == null) {
    throw ValidationException("Jersey number must be numeric");
  }
  if (selectedPositions.value.isEmpty) {
    throw ValidationException("At least one position must be selected");
  }
  if (selectedPositions.value.length > 2) {
    throw ValidationException("You can only select up to two positions");
  }
  if (emailController.text.trim().isEmpty) {
    throw ValidationException("Email cannot be empty");
  }
  if (passwordController.text.trim().isEmpty) {
    throw ValidationException("Password cannot be empty");
  }

  if (passwordController.text.trim() != confirmPassController.text.trim()) {
    throw ValidationException("Passwords do not match");
  }
  if (fullPhoneNumber == null || fullPhoneNumber.trim().isEmpty) {
    throw ValidationException("Phone number cannot be empty");
  }
  if (!isValidateContactNumber(fullPhoneNumber)) {
    throw ValidationException("Invalid Phone number");
  }
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ValueNotifier<Gender?> selectedGender = ValueNotifier(null);
  final TextEditingController birthdateController = TextEditingController();
  final List<String> positions = ["Guard", "Forward", "Center"];
  final ValueNotifier<Set<String>> selectedPositions = ValueNotifier({});
  AppImagePickerController profileImageController = AppImagePickerController();

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
    loadNetworkData();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> loadNetworkData() async {
    final t = await _loadTermsAndConditions();
    _termsFuture = Future.value(t);
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

  void _navigateToLogin() {
    debugPrint("Login");
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

  Future<void> handleRegister() async {
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
        jersey_name: jerseyNameController.text,
        jersey_number: double.parse(jerseyNumberController.text),
        position: selectedPositions.value.join(', '),
        user: user,
        profile_image_file: multipartFile,
      );

      final client = PlayerService();

      final response = await client.registerAccount(player);
      if (mounted) {
        showAppSnackbar(
          context,
          message: response,
          title: "Success",
          variant: SnackbarVariant.success,
        );

        setState(() {
          isRegistering = false;
        });
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
                    selectedAccountType = "Team_Account";
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
            SizedBox(height: 24),
            AppButton(
              label: "Register",
              onPressed: handleRegister,
              size: ButtonSize.sm,
              isDisabled: !hasAcceptedTerms,
            ),
          ],
        ),
      );
    }

    Widget buildTabTwoContent() {
      return SingleChildScrollView(
        child: Center(
          child: selectedAccountType == "Player"
              ? buildPlayerRegisterInputs()
              : Text("Register Team"),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: context.appColors.secondaryGradient,
          ),
          child: isRegistering
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
                          GestureDetector(
                            onTap: _navigateToLogin,
                            child: Text(
                              'Already have an account? Login',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.appColors.gray1100,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
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
