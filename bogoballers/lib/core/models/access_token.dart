// ignore_for_file: non_constant_identifier_names
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:hive/hive.dart';

part 'access_token.g.dart';

@HiveType(typeId: 0)
class AccessToken {
  @HiveField(0)
  final String access_token;

  AccessToken({required this.access_token});

  bool get isExpired => JwtDecoder.isExpired(access_token);

  String get user_id => JwtDecoder.decode(access_token)['sub'];

  factory AccessToken.fromJson(Map<String, dynamic> json) {
    return AccessToken(access_token: json['access_token']);
  }
}
