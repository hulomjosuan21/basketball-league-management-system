import 'package:bogoballers/core/models/notification_model.dart';
import 'package:bogoballers/core/services/notification_model_serices.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  final List<NotificationModel> _notificationList = [];

  List<NotificationModel> get notifications => _notificationList;

  bool _hasFetchedNotifications = false;

  /// Fetch once from backend, only if not yet fetched
  Future<void> fetchNotificationsOnce(String userId) async {
    if (_hasFetchedNotifications) return;

    final service = NotificationModelSerices();
    final response = await service.fetchNotifications(userId);

    _notificationList
      ..clear()
      ..addAll(response?.payload ?? []);
    _hasFetchedNotifications = true;
    notifyListeners();
  }

  /// Reset flag to allow refetching
  void resetFetchedFlag() {
    _hasFetchedNotifications = false;
  }

  /// Add a new notification at the top (index 0)
  void addNotification(NotificationModel notification) {
    _notificationList.insert(0, notification);
    notifyListeners();
  }

  /// Optional: clear all notifications
  void clearNotifications() {
    _notificationList.clear();
    notifyListeners();
  }
}
