import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

ThemeData datePickerPopupTheme(BuildContext context) => ThemeData(
  dialogTheme: DialogThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  datePickerTheme: DatePickerThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    headerBackgroundColor: context.appColors.accent900,
    headerForegroundColor: context.appColors.gray100,
    todayBackgroundColor: WidgetStateProperty.all(context.appColors.accent900),
    todayForegroundColor: WidgetStateProperty.all(context.appColors.gray100),
    surfaceTintColor: Colors.transparent,
  ),
  colorScheme: ColorScheme.light(
    primary: context.appColors.accent900,
    onPrimary: context.appColors.gray100,
    onSurface: context.appColors.gray1100,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: context.appColors.accent900),
  ),
);

class DateTimePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool includeTime;
  final bool enabled;

  const DateTimePickerField({
    super.key,
    required this.controller,
    this.labelText = 'Select date',
    this.includeTime = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: const Icon(Icons.calendar_today),
        helperText: "You must be at least 4 years old to continue.",
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(3000),
          builder: (BuildContext context, Widget? child) {
            return Theme(data: datePickerPopupTheme(context), child: child!);
          },
        );

        if (pickedDate != null) {
          if (!context.mounted) return;

          if (includeTime) {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: datePickerPopupTheme(context),
                  child: child!,
                );
              },
            );

            if (pickedTime != null) {
              final combinedDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              controller.text = "${combinedDateTime.toLocal()}".split('.')[0];
            } else {
              // If time picker is canceled, just show the date
              controller.text = "${pickedDate.toLocal()}".split(' ')[0];
            }
          } else {
            controller.text = "${pickedDate.toLocal()}".split(' ')[0];
          }
        }
      },
    );
  }
}
