import 'package:bogoballers/core/enums/user_enum.dart';

class AuditLogModel<T> {
  late String audit_id;
  late DateTime timestamp;
  String audit_by_id;
  AccountTypeEnum audit_by_type;
  late T auditor_obj;
  String audit_to_id;
  AccountTypeEnum audit_to_type;
  String action;
  String? details;

  late bool is_read;
  late DateTime read_at;

  AuditLogModel({
    required this.audit_id,
    required this.timestamp,
    required this.audit_by_id,
    required this.audit_by_type,
    required this.auditor_obj,
    required this.audit_to_id,
    required this.audit_to_type,
    required this.action,
    required this.details,
    required this.is_read,
    required this.read_at,
  });

  Map<String, dynamic> toMap() {
    return {
      "audit_id": audit_id,
      "timestamp": timestamp.toIso8601String(),
      "audit_by_id": audit_by_id,
      "audit_by_type": audit_by_type.value,
      "audit_to_id": audit_to_id,
      "audit_to_type": audit_to_type.value,
      "action": action,
      "details": details,
      "is_read": is_read,
      "read_at": read_at.toIso8601String(),
    };
  }

  factory AuditLogModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return AuditLogModel<T>(
      audit_id: json['audit_id'],
      timestamp: DateTime.parse(json['timestamp']),
      audit_by_id: json['audit_by_id'],
      audit_by_type: AccountTypeEnum.fromValue(json['audit_by_type'])!,
      audit_to_id: json['audit_to_id'],
      audit_to_type: AccountTypeEnum.fromValue(json['audit_to_type'])!,
      auditor_obj: fromJsonT(json['auditor_obj']),
      action: json['action'],
      details: json['details'] ?? null,
      is_read: json['is_read'],
      read_at: DateTime.parse(json['read_at']),
    );
  }

  AuditLogModel.create({
    required this.audit_by_id,
    required this.audit_by_type,
    required this.audit_to_id,
    required this.audit_to_type,
    required this.action,
    required this.details,
  });

  Map<String, dynamic> toJsonForCreation() {
    return {
      "audit_by_id": audit_by_id,
      "audit_by_type": audit_by_type.value,
      "audit_to_id": audit_to_id,
      "audit_to_type": audit_to_type.value,
      "action": action,
      "details": details,
    };
  }
}
