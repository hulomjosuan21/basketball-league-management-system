class RegExPatterns {
  /// Allows letters, numbers, and spaces. Minimum 3 characters.
  static final RegExp teamName = RegExp(r'^[A-Za-z0-9 ]{3,}$');

  /// Must follow: Brgy. [Barangay], [City/Municipality], [Province]
  static final RegExp address = RegExp(
    r'^Brgy\. [A-Za-z ]+, [A-Za-z ]+, [A-Za-z ]+$',
  );

  /// Must be in format: Firstname Lastname (capitalized, at least 2 words)
  static final RegExp fullName = RegExp(r'^[A-Z][a-z]+( [A-Z][a-z]+)+$');

  static final teamNameRegex = RegExp(r'^[A-Za-z0-9 ]{3,}$');
}
