// ignore_for_file: constant_identifier_names

// enum AccountTypeEnum {
//   Player(),
//   Team_Creator(),
//   LOCAL_ADMINISTRATOR('League_Administrator:Local'),
//   City_Administrator(''),
// }

enum AccountTypeEnum {
  PLAYER("Player"),
  TEAM_CREATOR("Team_Creator"),
  LOCAL_ADMINISTRATOR("League_Administrator:Local"),
  LGU_ADMINISTRATOR("League_Administrator:LGU"),
  SYSTEM("System");

  final String value;
  const AccountTypeEnum(this.value);
}

extension AccountTypeEnumHelper on AccountTypeEnum {
  /// Convert string (e.g., from backend) to enum using .value
  static AccountTypeEnum? fromValue(String? value) {
    if (value == null) return null;
    return AccountTypeEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid account type value: $value'),
    );
  }

  /// Convert string (e.g., enum name) to enum
  static AccountTypeEnum? fromName(String? name) {
    if (name == null) return null;
    return AccountTypeEnum.values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Invalid account type name: $name'),
    );
  }

  /// Compare enum to a string (value or name)
  bool equalsString(String input) {
    return input == value || input == name;
  }
}
