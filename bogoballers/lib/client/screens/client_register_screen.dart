import 'package:bogoballers/client/screens/client_login_screen.dart';
import 'package:bogoballers/client/screens/phone_number_input.dart';
import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/auth_navigator.dart';
import 'package:bogoballers/core/components/image_picker.dart';
import 'package:bogoballers/core/components/password_field.dart';
import 'package:bogoballers/core/components/snackbars.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/enums/gender_enum.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/services/player_services.dart';
import 'package:bogoballers/core/services/team_creator_services.dart';
import 'package:bogoballers/core/theme/datime_picker.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/utils/terms.dart';
import 'package:bogoballers/core/validations/auth_validations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final bdayController = TextEditingController();
  final jerseyNameController = TextEditingController();
  final addressController = TextEditingController();
  final jerseyNumberController = TextEditingController();

  String? phoneNumber;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();
  bool hasAcceptedTerms = false;
  AccountTypeEnum? selectedAccountType;

  bool isRegistering = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  Future<void> handleRegisterPlayer() async {
    if (selectedAccountType == null) return;

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
        addressController: addressController,
        jerseyNumberController: jerseyNumberController,
        selectedPositions: selectedPositions,
        emailController: emailController,
        passwordController: passwordController,
        confirmPassController: confirmPassController,
        fullPhoneNumber: phoneNumber,
      );
      final multipartFile = profileImageController.multipartFile;
      final user = UserModel.create(
        email: emailController.text,
        contact_number: phoneNumber!,
        password_str: passwordController.text,
        account_type: selectedAccountType!,
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
        player_address: addressController.text,
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
    if (selectedAccountType == null) return;
    setState(() {
      isRegistering = true;
    });
    try {
      validateTeamCreatorFields(
        emailController: emailController,
        passwordController: passwordController,
        confirmPassController: confirmPassController,
        fullPhoneNumber: phoneNumber,
      );

      final user = UserModel.create(
        email: emailController.text,
        contact_number: phoneNumber!,
        password_str: passwordController.text,
        account_type: selectedAccountType!,
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
        borderRadius: BorderRadius.circular(Sizes.radiusMd),
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
              const SizedBox(height: Sizes.spaceSm),
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
                const SizedBox(height: Sizes.spaceMd),
                buildAccountTypeItemCard("Player", Icons.sports_basketball, () {
                  selectedAccountType = AccountTypeEnum.PLAYER;
                }),
                const SizedBox(height: Sizes.spaceMd),
                buildAccountTypeItemCard("Team Creator", Icons.groups, () {
                  setState(() {
                    selectedAccountType = AccountTypeEnum.TEAM_CREATOR;
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
          borderRadius: BorderRadius.circular(Sizes.radiusSm),
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
                  const SizedBox(height: Sizes.spaceSm),
                  Text(
                    "Fill in the required details below to create your profile.",
                    style: TextStyle(fontSize: 11, color: appColors.gray800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sizes.spaceMd),
            AppImagePicker(controller: profileImageController, aspectRatio: 1),
            SizedBox(height: Sizes.spaceSm),
            AppButton(
              label: 'Select Image',
              onPressed: profileImageController.pickImage,
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
            ),
            SizedBox(height: Sizes.spaceXs),
            Center(
              child: Text(
                '* Please provide a valid and proper player profile image. This is required for league validation.',
                style: TextStyle(fontSize: 10, color: appColors.gray800),
              ),
            ),
            const SizedBox(height: Sizes.spaceMd),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(label: Text("First name")),
            ),
            const SizedBox(height: Sizes.spaceMd),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(label: Text("Last name")),
            ),
            const SizedBox(height: Sizes.spaceMd),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Gender",
                  style: TextStyle(
                    fontSize: Sizes.fontSizeMd,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Sizes.spaceSm),
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
                            Text(
                              "Male",
                              style: TextStyle(fontSize: Sizes.fontSizeSm),
                            ),
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
                            Text(
                              "Female",
                              style: TextStyle(fontSize: Sizes.fontSizeSm),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: Sizes.spaceMd),
            DateTimePickerField(
              controller: bdayController,
              labelText: 'Birthdate',
            ),
            const SizedBox(height: Sizes.spaceMd),
            TextField(
              controller: addressController,
              decoration: InputDecoration(label: Text("Address")),
            ),

            const SizedBox(height: Sizes.spaceMd),
            TextField(
              controller: jerseyNameController,
              decoration: InputDecoration(label: Text("Jersey name")),
            ),
            const SizedBox(height: Sizes.spaceMd),
            TextField(
              controller: jerseyNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(label: Text("Jersey number")),
            ),
            const SizedBox(height: Sizes.spaceMd),
            Center(
              child: Text(
                "Choose up to two positions",
                style: TextStyle(
                  fontSize: Sizes.fontSizeSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: Sizes.spaceSm),
            ValueListenableBuilder<Set<String>>(
              valueListenable: selectedPositions,
              builder: (context, selected, _) {
                return Column(
                  children: positions.map((position) {
                    return CheckboxListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        position,
                        style: TextStyle(fontSize: Sizes.fontSizeSm),
                      ),
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
            const SizedBox(height: Sizes.spaceMd),
            PHPhoneInput(
              onChanged: (phone) {
                phoneNumber = phone;
              },
            ),
            const SizedBox(height: Sizes.spaceMd),
            TextField(
              controller: emailController,
              decoration: InputDecoration(label: Text("Email")),
            ),
            const SizedBox(height: Sizes.spaceMd),
            PasswordField(controller: passwordController, hintText: 'Password'),
            const SizedBox(height: Sizes.spaceMd),
            PasswordField(
              controller: confirmPassController,
              hintText: 'Confirm Passowrd',
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
            SizedBox(height: Sizes.spaceLg),
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
              border: Border.all(
                width: Sizes.borderWidthSm,
                color: appColors.gray600,
              ),
              borderRadius: BorderRadius.circular(Sizes.radiusMd),
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Sizes.spaceMd),
                PHPhoneInput(
                  onChanged: (phone) {
                    phoneNumber = phone;
                  },
                ),
                const SizedBox(height: Sizes.spaceMd),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(label: Text("Email")),
                ),
                const SizedBox(height: Sizes.spaceMd),
                PasswordField(
                  controller: passwordController,
                  hintText: 'Password',
                ),
                const SizedBox(height: Sizes.spaceMd),
                PasswordField(
                  controller: confirmPassController,
                  hintText: 'Confirm Passowrd',
                ),
                SizedBox(height: Sizes.spaceMd),
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
                SizedBox(height: Sizes.spaceLg),
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
          child: selectedAccountType == AccountTypeEnum.PLAYER
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
                      padding: const EdgeInsets.symmetric(
                        vertical: Sizes.spaceSm,
                      ),
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
                          SizedBox(height: Sizes.spaceSm),
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
