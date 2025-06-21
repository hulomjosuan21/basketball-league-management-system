import 'package:flutter/material.dart';

class EntityState<T> extends ChangeNotifier {
  T? _entity;
  T? get entity => _entity;

  void setEntity(T entity) {
    _entity = entity;
    notifyListeners();
  }

  void setSilentEntity(T entity) {
    _entity = entity;
  }

  void clear() {
    _entity = null;
    notifyListeners();
  }
}
