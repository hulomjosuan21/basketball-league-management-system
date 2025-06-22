import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/core/widgets/phone_number_input.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/image_picker.dart';
import 'package:bogoballers/core/widgets/snackbars.dart';
import 'package:bogoballers/core/constants/image_strings.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/services/team_creator_services.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/utils/terms.dart';
import 'package:bogoballers/core/validations/validators.dart';
import 'package:bogoballers/service_locator.dart';
import 'package:flutter/material.dart';

class TeamCreatorCreateTeamScreen extends StatefulWidget {
  const TeamCreatorCreateTeamScreen({super.key});

  @override
  State<TeamCreatorCreateTeamScreen> createState() =>
      _TeamCreatorCreateTeamScreenState();
}

class _TeamCreatorCreateTeamScreenState
    extends State<TeamCreatorCreateTeamScreen> {
  AppImagePickerController logoController = AppImagePickerController();

  String? phoneNumber;

  bool hasAcceptedTerms = false;

  final teamNameController = TextEditingController();
  final teamAddressController = TextEditingController();
  final teamMotoController = TextEditingController();
  final teamCoachController = TextEditingController();
  final teamAssistantCoachController = TextEditingController();

  bool isCreating = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> handleCreateTeam() async {
    setState(() {
      isCreating = true;
    });
    try {
      final teamCreator = getIt<EntityState<UserModel>>().entity;

      if (teamCreator == null) {
        throw EntityNotFound(AccountTypeEnum.TEAM_CREATOR);
      }

      validateCreateTeamFields(
        teamNameController: teamNameController,
        teamAddressController: teamAddressController,
        teamMotoController: teamMotoController,
        hasAcceptedTerms: hasAcceptedTerms,
        fullPhoneNumber: phoneNumber,
        coachNameController: teamCoachController,
        assistantCoachNameController: teamAssistantCoachController,
      );

      final multipartFile = logoController.multipartFile;
      if (multipartFile == null) {
        throw ValidationException("Please select a team logo!");
      }

      final team = TeamModel.create(
        user_id: teamCreator.user_id,
        team_name: teamNameController.text,
        team_address: teamAddressController.text,
        contact_number: phoneNumber!,
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
    } on EntityNotFound catch (e) {
      if (context.mounted) {
        showAppSnackbar(
          context,
          message: e.toString(),
          title: "Error",
          variant: SnackbarVariant.error,
        );

        Navigator.pushReplacementNamed(context, '/client/login');
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
            PHPhoneInput(
              phoneValue: phoneNumber,
              onChanged: (phone) {
                phoneNumber = phone;
              },
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
            termAndCondition(
              context: context,
              hasAcceptedTerms: hasAcceptedTerms,
              onChanged: (value) {
                setState(() {
                  hasAcceptedTerms = value ?? false;
                });
              },
              key: 'team_creation_terms_and_conditions',
            ),
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
          : createTeamController,
    );
  }
}
