import 'dart:async';

import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/image_picker.dart';
import 'package:bogoballers/core/widgets/labeled_text.dart';
import 'package:bogoballers/core/widgets/snackbars.dart';
import 'package:bogoballers/core/widgets/text_field.dart';
import 'package:bogoballers/core/enums/league_status_enum.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:bogoballers/core/models/league_model.dart';
import 'package:bogoballers/core/services/league_services.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/utils/league_utils.dart';
import 'package:bogoballers/core/validations/auth_validations.dart';
import 'package:bogoballers/core/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeagueContent extends StatefulWidget {
  const LeagueContent({super.key});

  @override
  State<LeagueContent> createState() => _LeagueContentState();
}

class _LeagueContentState extends State<LeagueContent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [CreateLeague()],
        ),
      ),
    );
  }
}

class CreateLeague extends StatefulWidget {
  const CreateLeague({super.key});

  @override
  State<CreateLeague> createState() => _CreateLeagueState();
}

class _CreateLeagueState extends State<CreateLeague> {
  final titleController = TextEditingController();
  final budgetController = TextEditingController();
  final registrationDeadlineController = TextEditingController();
  final openingDateController = TextEditingController();
  final startDateController = TextEditingController();

  final bannerController = AppImagePickerController();
  final tropyController = AppImagePickerController();

  final descriptionController = TextEditingController();
  final rulesController = TextEditingController();
  final sponsorsController = TextEditingController();

  List<DropdownMenuEntry<String>> allDropdownOptions = [];
  String? selectedCategory;
  Map<String, String> valueToLabelMap = {};
  List<String> allCategoryOptions = [];

  List<CategoryInputData> addedCategories = [];

  String selectedStatus = MatchStatus.scheduled.value;
  final List<String> statuses = MatchStatus.values.map((e) => e.value).toList();

  Future<void> loadLeagueCategories() async {
    final result = await getLeagueCategoryDropdownData(addedCategories);
    setState(() {
      allDropdownOptions = result['allDropdownOptions'];
      allCategoryOptions = result['allCategoryOptions'];
      valueToLabelMap = result['valueToLabelMap'];
    });
  }

  Widget removeCategory(CategoryInputData data) {
    return IconButton(
      onPressed: isLoading
          ? null
          : () async {
              final shouldRemove = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Remove Category',
                      style: dialogTitleStyle(context),
                    ),
                    content: Text(
                      'Are you sure you want to remove this category?',
                    ),
                    actions: [
                      AppButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        label: 'Cancel',
                        variant: ButtonVariant.ghost,
                        size: ButtonSize.sm,
                      ),
                      AppButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        label: 'Remove',
                        size: ButtonSize.sm,
                      ),
                    ],
                  );
                },
              );

              if (shouldRemove == true) {
                setState(() {
                  addedCategories.removeWhere(
                    (e) => e.category == data.category,
                  );
                  loadLeagueCategories();
                });
              }
            },
      icon: Icon(Icons.close, size: 14),
    );
  }

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadLeagueCategories();
  }

  Future<bool?> confirmDialog() => showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: Text(
        "Review New League Details",
        style: dialogTitleStyle(context),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabeledText(label: "Title", value: titleController.text),
            LabeledText(
              label: "Registration Deadline",
              value: registrationDeadlineController.text,
            ),
            LabeledText(
              label: "Opening Date",
              value: openingDateController.text,
            ),
            LabeledText(label: "Start Date", value: startDateController.text),
            LabeledText(
              label: "Description",
              value: descriptionController.text,
            ),
            LabeledText(label: "Rules", value: rulesController.text),
            budgetController.text.isNotEmpty
                ? LabeledText(
                    label: "Budget",
                    value: "₱ ${budgetController.text}",
                  )
                : LabeledText(label: "Budget", value: "Free"),
            if (sponsorsController.text.isNotEmpty)
              LabeledText(label: "Sponsors", value: sponsorsController.text),
            if (addedCategories.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text("Added Categories:"),
              ...addedCategories.map(
                (cat) => Text(
                  "- ${cat.category} | Format: ${cat.format} | Max Teams: ${cat.maxTeam}",
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        AppButton(
          onPressed: () => Navigator.of(context).pop(false),
          label: 'Cancel',
          variant: ButtonVariant.ghost,
          size: ButtonSize.sm,
        ),
        AppButton(
          onPressed: () => Navigator.of(context).pop(true),
          label: 'Confirm',
          size: ButtonSize.sm,
        ),
      ],
    ),
  );

  Future<void> handleCreateNewLeague() async {
    setState(() => isLoading = true);
    try {
      validateNewLeagueFields(
        titleController: titleController,
        registrationDeadlineController: registrationDeadlineController,
        openingDateController: openingDateController,
        startDateController: startDateController,
        descriptionController: descriptionController,
        rulesController: rulesController,
        addedCategories: addedCategories,
      );

      final confirm = await confirmDialog();

      if (confirm != true) return;
      if (!mounted) return;

      final currentAdmin =
          getIt<EntityState<LeagueAdministratorModel>>().entity;

      if (currentAdmin == null)
        throw EntityNotFound(AccountTypeEnum.LGU_ADMINISTRATOR);

      List<LeagueCategoryModel> categories = [];

      for (CategoryInputData cat in addedCategories) {
        categories.add(
          LeagueCategoryModel.create(
            category_name: cat.category,
            category_format: cat.format,
            max_team: int.parse(cat.maxTeam),
          ),
        );
      }

      final leagueModel = LeagueModel.create(
        league_administrator_id: currentAdmin.league_administrator_id,
        league_title: titleController.text,
        league_budget: double.parse(budgetController.text),
        registration_deadline: DateTime.parse(
          registrationDeadlineController.text,
        ),
        opening_date: DateTime.parse(openingDateController.text),
        start_date: DateTime.parse(startDateController.text),
        league_description: descriptionController.text,
        league_rules: rulesController.text,
        sponsors: sponsorsController.text,
        status: selectedStatus,
        categories: categories,
      );

      final service = LeagueServices();

      final response = await service.createNewLeague(leagueModel);

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

        Navigator.pushReplacementNamed(context, '/administrator/login/sreen');
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
        scheduleMicrotask(() => setState(() => isLoading = false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    Widget buildControllerTitle() {
      return TextField(
        enabled: !isLoading,
        controller: titleController,
        decoration: InputDecoration(label: Text("League title")),
      );
    }

    Widget buildControllerInfoAndImage() {
      return SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text("₱"),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          enabled: !isLoading,
                          controller: budgetController,
                          decoration: InputDecoration(label: Text("Budget")),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // DateTimePickerField(
                  //   enabled: !isLoading,
                  //   controller: registrationDeadlineController,
                  //   labelText: 'Team Registration Deadline',
                  //   includeTime: true,
                  // ),
                  // SizedBox(height: 16),
                  // DateTimePickerField(
                  //   enabled: !isLoading,
                  //   controller: openingDateController,
                  //   labelText: 'Opening Date',
                  //   includeTime: true,
                  // ),
                  // SizedBox(height: 16),
                  // DateTimePickerField(
                  //   enabled: !isLoading,
                  //   controller: startDateController,
                  //   labelText: 'Start Date',
                  //   includeTime: true,
                  // ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Wrap(
                  direction: Axis.horizontal,
                  spacing: 16,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "League Banner",
                          style: headerLabelStyleMd(context),
                        ),
                        SizedBox(height: 8),
                        AppImagePicker(
                          controller: bannerController,
                          aspectRatio: 16 / 9,
                          width: 320,
                        ),
                        SizedBox(height: 8),
                        AppButton(
                          label: "Select Image",
                          onPressed: () {},
                          size: ButtonSize.sm,
                          variant: ButtonVariant.ghost,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Championship trophy",
                          style: headerLabelStyleMd(context),
                        ),
                        SizedBox(height: 8),
                        AppImagePicker(controller: tropyController),
                        SizedBox(height: 8),
                        AppButton(
                          label: "Select Image",
                          onPressed: () {},
                          size: ButtonSize.sm,
                          variant: ButtonVariant.ghost,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildControllerDescriptionRules() {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  enabled: !isLoading,
                  controller: descriptionController,
                  decoration: InputDecoration(
                    label: Text("League description"),
                    hint: Text(""),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  enabled: !isLoading,
                  controller: rulesController,
                  decoration: InputDecoration(
                    label: Text("League rules"),
                    hint: Text(""),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            enabled: !isLoading,
            controller: sponsorsController,
            decoration: InputDecoration(label: Text("Sponsors (Optional)")),
          ),
        ],
      );
    }

    Widget buildCategoryCard(CategoryInputData data) {
      return Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: appColors.gray200,
          border: Border.all(width: 0.5, color: appColors.gray600),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LabeledText(label: "Category", value: data.category),
                SizedBox(width: 8),
                removeCategory(data),
              ],
            ),
            SizedBox(height: 8),
            Container(
              color: appColors.gray100,
              child: TextField(
                enabled: !isLoading,
                controller: data.formatController,
                decoration: InputDecoration(
                  labelText: "Format",
                  alignLabelWithHint: true,
                ),
                maxLines: 2,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 200,
                  color: appColors.gray100,
                  child: TextField(
                    enabled: !isLoading,
                    controller: data.maxTeamController,
                    decoration: InputDecoration(labelText: "Max Team"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildSelectCategory() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DropdownMenu<String>(
                width: 300,
                enableSearch: true,
                hintText: 'Select Category',
                initialSelection: selectedCategory,
                onSelected: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                dropdownMenuEntries: allDropdownOptions,
                textStyle: TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              AppButton(
                isDisabled: isLoading,
                onPressed: () {
                  if (selectedCategory != null &&
                      !addedCategories.any(
                        (e) => e.category == selectedCategory,
                      )) {
                    setState(() {
                      addedCategories.add(
                        CategoryInputData(category: selectedCategory!),
                      );
                      selectedCategory = null;
                      loadLeagueCategories();
                    });
                  }
                },
                label: "Add Category",
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(children: addedCategories.map(buildCategoryCard).toList()),
        ],
      );
    }

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appColors.gray100,
            border: Border.all(width: 0.5, color: appColors.gray600),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Text(
                    "New League",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: appColors.accent900,
                    ),
                  ),
                ),
                Divider(thickness: 0.5, color: appColors.gray600),
                SizedBox(height: 16),
                buildControllerTitle(),
                SizedBox(height: 16),
                buildControllerInfoAndImage(),
                SizedBox(height: 16),
                buildControllerDescriptionRules(),
                SizedBox(height: 16),
                buildSelectCategory(),
                SizedBox(height: 16),
                Divider(thickness: 0.5, color: appColors.gray600),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      hint: Text(
                        "Select Status",
                        style: TextStyle(fontSize: 12),
                      ),
                      value: selectedStatus,
                      items: statuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status, style: TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: null, // Disabled
                    ),
                    SizedBox(width: 16),
                    AppButton(
                      isDisabled: !addedCategories.isNotEmpty || isLoading,
                      label: isLoading ? "Creating League..." : "Create League",
                      onPressed: handleCreateNewLeague,
                      size: ButtonSize.lg,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: appColors.gray1000.withAlpha((0.2 * 255).toInt()),
                border: Border.all(width: 0.5, color: appColors.gray600),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: appColors.accent900),
                  SizedBox(height: 8),
                  Text("Creating League..."),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
