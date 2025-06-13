bool isValidateContactNumber(String? value) {
  if (value == null) return false;

  if (!value.startsWith('+63')) return false;

  final phoneNumberPart = value.substring(3);

  final digitsOnly = phoneNumberPart.replaceAll(RegExp(r'\D'), '');

  if (digitsOnly.length != 10) return false;

  if (!digitsOnly.startsWith('9')) return false;

  if (value.length != 13) return false;

  return true;
}

bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );
  return emailRegex.hasMatch(email);
}
