// ignore_for_file: non_constant_identifier_names

import 'package:bogoballers/core/enums/user_enum.dart';

class UserModel {
  String? user_id;
  String email;
  String? password_str;
  AccountTypeEnum account_type;
  DateTime? created_at;
  DateTime? updated_at;

  UserModel({
    this.user_id,
    required this.email,
    this.password_str,
    required this.account_type,
    this.created_at,
    this.updated_at,
  });

  UserModel.create({
    required this.email,
    this.password_str,
    required this.account_type,
  });

  Map<String, dynamic> toJsonForCreation() {
    return {
      'email': email,
      'password_str': password_str,
      'account_type': account_type.name,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'email': email,
      'password_str': password_str,
      'account_type': account_type.name,
      'created_at': created_at?.toIso8601String(),
      'updated_at': updated_at?.toIso8601String(),
    };
  }
}
