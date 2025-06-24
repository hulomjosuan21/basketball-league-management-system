import 'package:bogoballers/core/models/audit_log_model.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  final List<AuditLogModel> _auditLogs = [];
  List<AuditLogModel> get auditLogs => _auditLogs;

  bool _hasFetchedAuditLogs = false;

  Future<void> fetchAuditLogsOnce(String id) async {
    if (_hasFetchedAuditLogs) return;

    _auditLogs
      ..clear()
      ..addAll([]);
    _hasFetchedAuditLogs = true;
    notifyListeners();
  }

  void resetFetchedFlag() {
    _hasFetchedAuditLogs = false;
  }
}
