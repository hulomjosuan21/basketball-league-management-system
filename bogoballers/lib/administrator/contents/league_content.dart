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

class LeagueControl extends StatelessWidget {
  LeagueControl({super.key});

  final imageController = AppImagePickerController();

  final statusSelectController = BsSelectBoxController(
    selected: [BsSelectBoxOption(value: "Scheduled", text: Text('Scheduled'))],
  );

  final categorySelectController = BsSelectBoxController(multiple: true);

  final registrationDeadlineController = TextEditingController();
  final openingDateController = TextEditingController();
  final startDateController = TextEditingController();

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

    Widget buildSelects() {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: BsSelectBox(
              hintText: 'Select Category',
              controller: categorySelectController,
              serverSide: selectLeagueCategoriesFromJson,
              searchable: true,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: BsSelectBox(
              disabled: true,
              hintText: 'Status',
              controller: statusSelectController,
              serverSide: selectLeagueCategoriesStatus,
            ),
          ),
        ],
      );
    }

    Widget buildControllerDescriptionRules() {
      return Column(
        children: [
          TextField(
            decoration: InputDecoration(
              label: Text("League Description"),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    label: Text("League Rules"),
                    hint: Text(""),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 2,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    label: Text("League Format"),
                    hint: Text(""),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 2,
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
            buildSelects(),
            SizedBox(height: 16),
            buildControllerDescriptionRules(),
          ],
        ),
      ),
    );
  }
}
