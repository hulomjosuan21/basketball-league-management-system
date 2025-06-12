import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/image_picker.dart';
import 'package:bogoballers/core/components/text_field.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bs_flutter_selectbox/bs_flutter_selectbox.dart';
import 'package:flutter/material.dart';

class LeagueContent extends StatefulWidget {
  LeagueContent({super.key});

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

  final BsSelectBoxController categorySelectController = BsSelectBoxController(
    multiple: true,
    options: [
      BsSelectBoxOption(value: 1, text: Text('Round Robin')),
      BsSelectBoxOption(value: 2, text: Text('Knock Out')),
    ],
  );

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
                  SizedBox(
                    width: 200,
                    child: TextField(
                      decoration: InputDecoration(label: Text("Budget")),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      label: Text("Registration deadline"),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(label: Text("Start date")),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    direction: Axis.horizontal,
                    spacing: 16,
                    children: [
                      SizedBox(
                        width: 180,
                        child: BsSelectBox(
                          hintText: 'Select Category',
                          controller: categorySelectController,
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: BsSelectBox(
                          hintText: 'Select Category',
                          controller: categorySelectController,
                        ),
                      ),
                    ],
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
                    hint: Text(
                      "Explain By lorem epsom dolor it asdaj asdasdhsajdgjh",
                    ),
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
                    hint: Text(
                      "Explain By lorem epsom dolor it asdaj asdasdhsajdgjh",
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
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
          ],
        ),
      ),
    );
  }
}
