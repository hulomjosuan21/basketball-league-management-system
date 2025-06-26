import 'package:bogoballers/core/enums/user_enum.dart';

enum NotificationAction {
  PLAYER_INVITATION('player_invitation');

  final String value;

  const NotificationAction(this.value);

  static NotificationAction? fromValue(String? value) {
    try {
      return NotificationAction.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }
}

abstract class NotificationModel {
  late final String notification_id;
  final String author;
  final String detail;
  final String? image;
  final AccountTypeEnum? accountType;
  Map<String, dynamic>? action;
  final DateTime timestamp;

  NotificationModel({
    required this.notification_id,
    required this.author,
    required this.detail,
    required this.timestamp,
    this.image,
    this.accountType,
    this.action,
  });

  static NotificationModel fromDynamicJson(Map<String, dynamic> json) {
    final type = json['account_type'];

    if (type == AccountTypeEnum.TEAM_CREATOR.value &&
        json.containsKey('team_id')) {
      return TeamNotificationModel.fromJson(json);
    }

    return BasicNotificationModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'detail': detail,
      'image': image,
      'timestamp': timestamp.toIso8601String(),
      'account_type': accountType?.value,
      'action': action,
    };
  }
}

class BasicNotificationModel extends NotificationModel {
  BasicNotificationModel({
    required super.notification_id,
    required super.author,
    required super.detail,
    required super.timestamp,
    super.image,
    super.accountType,
    super.action,
  });

  factory BasicNotificationModel.fromJson(Map<String, dynamic> json) {
    return BasicNotificationModel(
      notification_id: json['notification_id'],
      author: json['author'] ?? 'System',
      detail: json['detail'] ?? '',
      image: json['image'],
      timestamp: DateTime.parse(json['timestamp']),
      accountType: AccountTypeEnum.fromValue(json['account_type']),
      action: json['action'],
    );
  }
}

class TeamNotificationModel extends NotificationModel {
  final String teamId;
  final String? teamLogoUrl;
  final String teamName;

  TeamNotificationModel({
    required String notification_id,
    required String author,
    required String detail,
    required String? image,
    required AccountTypeEnum accountType,
    Map<String, dynamic>? action,
    required DateTime timestamp,
    required this.teamId,
    this.teamLogoUrl,
    required this.teamName,
  }) : super(
         author: author,
         detail: detail,
         image: image,
         accountType: accountType,
         action: action,
         timestamp: timestamp,
         notification_id: notification_id,
       );

  factory TeamNotificationModel.fromJson(Map<String, dynamic> json) {
    return TeamNotificationModel(
      notification_id: json['notification_id'],
      author: json['team_name'],
      detail: json['detail'],
      image: json['team_logo_url'],
      accountType: AccountTypeEnum.fromValue(json['account_type'])!,
      timestamp: DateTime.parse(json['timestamp']),
      action: json['action'],
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
