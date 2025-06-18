import 'dart:convert';

import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/error.dart';
import 'package:bogoballers/core/components/image_picker.dart';
import 'package:bogoballers/core/components/snackbars.dart';
import 'package:bogoballers/core/constants/image_strings.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/services/team_creator_services.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/utils/terms.dart';
import 'package:bogoballers/core/validations/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class TeamCreatorCreateTeamScreen extends StatefulWidget {
  const TeamCreatorCreateTeamScreen({super.key});

  @override
  State<TeamCreatorCreateTeamScreen> createState() =>
      _TeamCreatorCreateTeamScreenState();
}

class _TeamCreatorCreateTeamScreenState
    extends State<TeamCreatorCreateTeamScreen> {
  AppImagePickerController logoController = AppImagePickerController();

  String? fullPhoneNumber;
  PhoneNumber number = PhoneNumber(isoCode: 'PH');
  bool isValidPhoneNumber = false;

  bool hasAcceptedTerms = false;
  late Future<void> _networkDataFuture;
  late Future<String> _termsFuture;

  final teamNameController = TextEditingController();
  final teamAddressController = TextEditingController();
  final teamMotoController = TextEditingController();
  final teamCoachController = TextEditingController();
  final teamAssistantCoachController = TextEditingController();

  bool isCreating = false;

  @override
  void initState() {
    super.initState();
    _networkDataFuture = _loadNetworkData();
  }

  Future<void> _loadNetworkData() async {
    _termsFuture = Future.value(_loadTermsAndConditions());
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

  Future<void> handleCreateTeam() async {
    setState(() {
      isCreating = true;
    });
    try {
      validateCreateTeamFields(
        teamNameController: teamNameController,
        teamAddressController: teamAddressController,
        teamMotoController: teamMotoController,
        hasAcceptedTerms: hasAcceptedTerms,
        fullPhoneNumber: fullPhoneNumber,
        coachNameController: teamCoachController,
        assistantCoachNameController: teamAssistantCoachController,
      );

      String testUserId = "user-02f28a11-cd42-4e6c-b753-2f493d88cbb6";

      final multipartFile = logoController.multipartFile;
      if (multipartFile == null) {
        throw ValidationException("Please select a team logo!");
      }

      final team = TeamModel.create(
        user_id: testUserId,
        team_name: teamNameController.text,
        team_address: teamAddressController.text,
        contact_number: fullPhoneNumber!,
        team_motto: teamMotoController.text,
        coach_name: teamCoachController.text,
        team_logo_image: multipartFile,
      );

      final service = TeamCreatorServices();

      final response = await service.createNewTeam(team);

      if (mounted) {
        showAppSnackbar(
          context,
          message: response.message,
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
          isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> onBackPressed() async {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Leave Screen?'),
          content: const Text(
            'Are you sure you want to go back? Unsaved changes may be lost.',
          ),
          actions: [
            AppButton(
              label: "Stay",
              onPressed: () => Navigator.of(context).pop(false),
              size: ButtonSize.sm,
              variant: ButtonVariant.ghost,
            ),
            AppButton(
              label: "Leave",
              onPressed: () => Navigator.of(context).pop(true),
              size: ButtonSize.sm,
            ),
          ],
        ),
      );

      if (shouldLeave == true) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
      }
    }

    final createTeamController = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImagePicker(
              controller: logoController,
              aspectRatio: 1,
              assetPath: ImageStrings.exampleTeamLogo,
            ),
            AppButton(
              label: 'Select team logo',
              onPressed: logoController.pickImage,
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
            ),
            SizedBox(height: Sizes.spaceMd),
            TextField(
              controller: teamNameController,
              decoration: InputDecoration(
                label: Text("Team name"),
                helperText: 'Format: [Team Name]',
              ),
            ),
            SizedBox(height: Sizes.spaceMd),
            TextField(
              controller: teamAddressController,
              decoration: InputDecoration(
                label: Text("Team address"),
                helperText:
                    "Format: Brgy. [Barangay], [City/Municipality], [Province]",
              ),
            ),
            SizedBox(height: Sizes.spaceMd),
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
            SizedBox(height: Sizes.spaceMd),
            TextField(
              controller: teamMotoController,
              decoration: InputDecoration(
                label: Text("Team moto"),
                alignLabelWithHint: true,
                helperText: "Example: One team, one dream",
              ),
              maxLines: 2,
            ),
            SizedBox(height: Sizes.spaceMd),
            TextField(
              controller: teamCoachController,
              decoration: InputDecoration(
                label: Text("Coach full name"),
                helperText: 'Format: [First Name] [Last Name]',
              ),
            ),
            SizedBox(height: Sizes.spaceMd),
            TextField(
              controller: teamAssistantCoachController,
              decoration: InputDecoration(
                helperText:
                    'Format: [First Name] [Last Name] (You can set this later)',
                label: Text("Assistant Coach full name (optional)"),
              ),
            ),
            termAndCondition(context, hasAcceptedTerms, _termsFuture, (value) {
              setState(() {
                hasAcceptedTerms = value ?? false;
              });
            }),
            SizedBox(height: Sizes.spaceLg),
            AppButton(
              isDisabled: !hasAcceptedTerms,
              width: double.infinity,
              label: "Create",
              onPressed: handleCreateTeam,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Create New Team",
          style: TextStyle(
            fontSize: Sizes.fontSizeLg,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackPressed,
        ),
      ),
      body: isCreating
          ? Center(
              child: CircularProgressIndicator(
                color: context.appColors.accent900,
              ),
            )
          : FutureBuilder(
              future: _networkDataFuture,
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    color: context.appColors.accent900,
                  );
                } else if (asyncSnapshot.hasError) {
                  return retryError(context, asyncSnapshot.error, () {
                    setState(() {
                      _networkDataFuture = _loadNetworkData();
                    });
                  });
                } else {
                  return createTeamController;
                }
              },
            ),
    );
  }
}
