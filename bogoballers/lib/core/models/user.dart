// ignore_for_file: non_constant_identifier_names

import 'package:bogoballers/core/enums/user_enum.dart';

AccountTypeEnum? accountTypeFromString(String? type) {
  if (type == null) return null;
  return AccountTypeEnum.values.firstWhere(
    (e) => e.name == type,
    orElse: () => AccountTypeEnum.Player,
  );
}

class UserModel {
  String? user_id;
  String email;
  String? password_str;
  AccountTypeEnum? account_type;
  bool? is_verified;
  late DateTime created_at;
  late DateTime updated_at;

  UserModel.set({
    this.user_id,
    required this.email,
    required this.account_type,
    required this.is_verified,
    required this.created_at,
    required this.updated_at,
  });

  UserModel.create({
    required this.email,
    required this.password_str,
    this.account_type = AccountTypeEnum.League_Administrator,
  });

  UserModel.login({required this.email, required this.password_str});

  Map<String, dynamic> toJsonForLogin() {
    return {'email': email, 'password_str': password_str};
  }

  Map<String, dynamic> toJsonForCreation() {
    return {
      'email': email,
      'password_str': password_str,
      'account_type': account_type?.name,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.set(
      user_id: json['user_id'],
      email: json['email'],
      account_type: accountTypeFromString(json['account_type']),
      is_verified: json['is_verified'],
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'email': email,
      'account_type': account_type?.name,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }
}
