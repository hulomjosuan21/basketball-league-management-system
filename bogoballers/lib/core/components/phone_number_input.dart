import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PHPhoneInput extends StatefulWidget {
  final void Function(String phone)? onChanged;
  final String? phoneValue;

  const PHPhoneInput({super.key, this.onChanged, this.phoneValue});

  @override
  State<PHPhoneInput> createState() => _PHPhoneInputState();
}

class _PHPhoneInputState extends State<PHPhoneInput> {
  late final TextEditingController _controller;
  late final PhoneNumber _initialNumber;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _initialNumber = PhoneNumber(isoCode: 'PH', phoneNumber: widget.phoneValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final digitsOnly = value?.replaceAll(RegExp(r'\D'), '') ?? '';

    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (digitsOnly.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    if (!digitsOnly.startsWith('9')) {
      return 'Phone number must start with 9';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return InternationalPhoneNumberInput(
      countries: const ['PH'],
      onInputChanged: (PhoneNumber newNumber) {
        widget.onChanged?.call(newNumber.phoneNumber ?? '');
      },
      onInputValidated: (_) {},
      ignoreBlank: false,
      validator: _validate,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      initialValue: _initialNumber,
      textFieldController: _controller,
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        showFlags: true,
        trailingSpace: false,
      ),
    );
  }
}
