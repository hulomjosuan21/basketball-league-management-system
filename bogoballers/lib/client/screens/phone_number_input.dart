import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PHPhoneInput extends StatefulWidget {
  final void Function(String phone)? onChanged;

  const PHPhoneInput({super.key, this.onChanged});

  @override
  State<PHPhoneInput> createState() => _PHPhoneInputState();
}

class _PHPhoneInputState extends State<PHPhoneInput> {
  final TextEditingController _controller = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'PH');
  bool isValid = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final digitsOnly = value?.replaceAll(RegExp(r'\D'), '') ?? '';

    if (value == null || value.isEmpty) {
      isValid = false;
      return 'Phone number is required';
    }
    if (digitsOnly.length != 10) {
      isValid = false;
      return 'Phone number must be exactly 10 digits';
    }
    if (!digitsOnly.startsWith('9')) {
      isValid = false;
      return 'Phone number must start with 9';
    }

    isValid = true;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return InternationalPhoneNumberInput(
      countries: ['PH'],
      onInputChanged: (PhoneNumber newNumber) {
        widget.onChanged?.call(newNumber.phoneNumber ?? '');
      },
      onInputValidated: (bool _) {},
      ignoreBlank: false,
      validator: _validate,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      initialValue: number,
      textFieldController: _controller,
      selectorConfig: SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        showFlags: true,
        trailingSpace: false,
      ),
    );
  }
}
