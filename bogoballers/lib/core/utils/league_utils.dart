import 'dart:convert';

import 'package:bs_flutter_selectbox/bs_flutter_selectbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<BsSelectBoxResponse> selectLeagueCategoriesFromJson(
  Map<String, String> params,
) async {
  final String response = await rootBundle.loadString(
    'assets/json/league_categories.json',
  );
  final List<dynamic> data = jsonDecode(response);

  final List<BsSelectBoxOption> options = data.map((item) {
    return BsSelectBoxOption(value: item['value'], text: Text(item['label']));
  }).toList();

  return BsSelectBoxResponse(options: options);
}

Future<BsSelectBoxResponse> selectLeagueCategoriesStatus(
  Map<String, String> params,
) async {
  final String response = await rootBundle.loadString(
    'assets/json/league_status.json',
  );
  final List<dynamic> data = jsonDecode(response);

  final List<BsSelectBoxOption> options = data.map((item) {
    return BsSelectBoxOption(value: item['value'], text: Text(item['label']));
  }).toList();

  return BsSelectBoxResponse(options: options);
}
