import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/image_picker.dart';
import 'package:bogoballers/core/components/text_field.dart';
import 'package:bogoballers/core/theme/datime_picker.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/league_utils.dart';
import 'package:bs_flutter_selectbox/bs_flutter_selectbox.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LeagueContent extends StatefulWidget {
  const LeagueContent({super.key});

  @override
  State<LeagueContent> createState() => _LeagueContentState();
}

class _LeagueContentState extends State<LeagueContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [LeagueControl()],
      ),
    );
  }
}

class CategoryChipData {
  final String category;
  final TextEditingController formatController;

  CategoryChipData({required this.category, String? initialFormat})
    : formatController = TextEditingController(text: initialFormat ?? '');

  String get format => formatController.text;
}

class LeagueControl extends StatefulWidget {
  const LeagueControl({super.key});

  @override
  State<LeagueControl> createState() => _LeagueControlState();
}

class _LeagueControlState extends State<LeagueControl> {
  final imageController = AppImagePickerController();

  final statusSelectController = BsSelectBoxController(
    selected: [BsSelectBoxOption(value: "Scheduled", text: Text('Scheduled'))],
  );

  List<DropdownMenuEntry<String>> allDropdownOptions = [];
  String? selectedCategory;
  List<CategoryChipData> addedCategories = [];
  Map<String, String> valueToLabelMap = {};
  List<String> allCategoryOptions = [];

  Future<void> loadLeagueCategories() async {
    final String response = await rootBundle.loadString(
      'assets/json/league_categories.json',
    );
    final List<dynamic> data = jsonDecode(response);

    allCategoryOptions = data
        .map<String>((item) => item['value'] as String)
        .toList();

    valueToLabelMap = {
      for (var item in data) item['value'] as String: item['label'] as String,
    };

    setState(() {
      allDropdownOptions = allCategoryOptions
          .where(
            (value) => !addedCategories.any((cat) => cat.category == value),
          )
          .map(
            (value) => DropdownMenuEntry<String>(
              value: value,
              label: valueToLabelMap[value] ?? value,
            ),
          )
          .toList();
    });
  }

  void printAllCategoriesWithFormats() {
    for (var cat in addedCategories) {
      debugPrint('Category: ${cat.category}, Format: ${cat.format}');
    }
  }

  final registrationDeadlineController = TextEditingController();

  final openingDateController = TextEditingController();

  final startDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadLeagueCategories();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

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
                  TextField(
                    decoration: InputDecoration(label: Text("League title")),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text("₱"),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          decoration: InputDecoration(label: Text("Budget")),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  DateTimePickerField(
                    controller: registrationDeadlineController,
                    labelText: 'Team Registration Deadline',
                    includeTime: true,
                  ),
                  SizedBox(height: 16),
                  DateTimePickerField(
                    controller: openingDateController,
                    labelText: 'Opening Date',
                    includeTime: true,
                  ),
                  SizedBox(height: 16),
                  DateTimePickerField(
                    controller: startDateController,
                    labelText: 'Start Date',
                    includeTime: true,
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: BsSelectBox(
                      disabled: true,
                      hintText: 'Status',
                      controller: statusSelectController,
                      serverSide: selectLeagueCategoriesStatus,
                    ),
                  ),
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
                          controller: imageController,
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
                        AppImagePicker(controller: imageController),
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

    Widget buildCategoryChip(CategoryChipData data) {
      return Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: appColors.gray600),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(
                      context,
                    ).style.copyWith(fontSize: 14),
                    children: [
                      const TextSpan(
                        text: "Category name: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: data.category,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      addedCategories.removeWhere(
                        (e) => e.category == data.category,
                      );
                      loadLeagueCategories();
                    });
                  },
                  icon: Icon(Icons.close, size: 14),
                ),
              ],
            ),
            SizedBox(height: 8),
            TextField(
              controller: data.formatController,
              decoration: InputDecoration(labelText: "Format"),
              maxLines: 2,
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
              Container(
                width: 350,
                constraints: BoxConstraints(minWidth: 350),
                child: DropdownMenu<String>(
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
              ),
              const SizedBox(width: 16),
              AppButton(
                onPressed: () {
                  if (selectedCategory != null &&
                      !addedCategories.any(
                        (e) => e.category == selectedCategory,
                      )) {
                    setState(() {
                      addedCategories.add(
                        CategoryChipData(category: selectedCategory!),
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
          Column(children: addedCategories.map(buildCategoryChip).toList()),
        ],
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
            decoration: InputDecoration(label: Text("Sponsors (Optional)")),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.gray100,
        border: BoxBorder.all(width: 0.5, color: appColors.gray600),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildControllerInfoAndImage(),
            SizedBox(height: 16),
            buildControllerDescriptionRules(),
            SizedBox(height: 16),
            buildSelectCategory(),
            SizedBox(height: 16),
            Row(
              children: [
                AppButton(
                  isDisabled: !addedCategories.isNotEmpty,
                  label: "Test",
                  onPressed: printAllCategoriesWithFormats,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
