import 'package:flutter/material.dart';

class AppShadows {
  static const List<BoxShadow> primary = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 0,
      spreadRadius: 1,
      offset: Offset(0, 0),
    ),
  ];
}
