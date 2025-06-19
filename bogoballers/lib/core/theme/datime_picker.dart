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
  final DateTime? selectedDate;
  final String labelText;
  final String? helperText;
  final bool includeTime;
  final bool enabled;
  final void Function(DateTime)? onChanged;

  const DateTimePickerField({
    super.key,
    required this.selectedDate,
    this.labelText = 'Select date',
    this.helperText,
    this.includeTime = false,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = enabled ? null : Theme.of(context).disabledColor;
    final displayText = selectedDate != null
        ? (includeTime
              ? selectedDate!.toLocal().toString().split('.').first
              : selectedDate!.toLocal().toString().split(' ')[0])
        : '';

    return InkWell(
      onTap: () async {
        if (!enabled) return;

        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(3000),
          builder: (BuildContext context, Widget? child) {
            return Theme(data: datePickerPopupTheme(context), child: child!);
          },
        );

        if (pickedDate != null && context.mounted) {
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
              pickedDate = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
            }
          }

          onChanged?.call(pickedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          suffixIcon: const Icon(Icons.calendar_today),
          helperText: helperText,
        ),
        child: Text(
          displayText.isNotEmpty ? displayText : 'Select a date',
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
