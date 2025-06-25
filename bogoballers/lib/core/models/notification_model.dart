import 'package:bogoballers/core/enums/user_enum.dart';

class NotificationModel {
  final String author;
  final String detail;
  final String? image;
  final AccountTypeEnum accountType;
  final Map<String, dynamic>? extra;

  NotificationModel({
    required this.author,
    required this.detail,
    required this.accountType,
    this.extra,
    this.image,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      author: json['author'] ?? 'System',
      detail: json['detail'],
      image: json['image'] ?? null,
      accountType: AccountTypeEnum.fromValue(json['account_type'])!,
      extra: json['extra'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'detail': detail,
      'image': image,
      'account_type': accountType.value,
      if (extra != null) 'extra': extra,
    };
  }
}

class TeamNotificationModel extends NotificationModel {
  final String teamId;
  final String? teamLogoUrl;
  final String teamName;

  TeamNotificationModel({
    required String author,
    required String detail,
    required String? image,
    required AccountTypeEnum accountType,
    Map<String, dynamic>? extra,
    required this.teamId,
    this.teamLogoUrl,
    required this.teamName,
  }) : super(
         author: author,
         detail: detail,
         image: image,
         accountType: accountType,
         extra: extra,
       );

  factory TeamNotificationModel.fromJson(Map<String, dynamic> json) {
    return TeamNotificationModel(
      author: json['team_name'],
      detail: json['detail'],
      image: json['team_logo_url'],
      accountType: AccountTypeEnum.fromValue(json['account_type'])!,
      extra: json['extra'],
      teamId: json['team_id'],
      teamLogoUrl: json['team_logo_url'],
      teamName: json['team_name'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'team_id': teamId,
      'team_logo_url': teamLogoUrl,
      'team_name': teamName,
    };
  }
}
