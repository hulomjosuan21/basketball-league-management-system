import 'package:bogoballers/core/enums/user_enum.dart';

class LoginResponse<T> {
  String? access_token;
  T entity;
  AccountTypeEnum account_type;

  LoginResponse({
    required this.access_token,
    required this.entity,
    required this.account_type,
  });

  factory LoginResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return LoginResponse(
      access_token: json['access_token'] ?? null,
      entity: fromJsonT(json['entity']),
      account_type: AccountTypeEnum.fromValue(json['account_type'])!,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'access_token': access_token,
      'entity': toJsonT(entity),
      'account_type': account_type.value,
    };
  }
}
