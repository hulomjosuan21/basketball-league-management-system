import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<List<String>> selectLeagueCategoriesStatus() async {
  final String response = await rootBundle.loadString(
    'assets/json/league_status.json',
  );
  final List<dynamic> data = jsonDecode(response);
  return data.cast<String>();
}

class CategoryInputData {
  final String category;
  final TextEditingController formatController;
  final TextEditingController maxTeamController;

  CategoryInputData({
    required this.category,
    String? initialFormat,
    String? initialMaxTeam,
  }) : formatController = TextEditingController(text: initialFormat ?? ''),
       maxTeamController = TextEditingController(text: initialMaxTeam ?? '');

  String get format => formatController.text;
  String get maxTeam => maxTeamController.text;
}

Future<Map<String, dynamic>> getLeagueCategoryDropdownData(
  List<CategoryInputData> addedCategories,
) async {
  final String response = await rootBundle.loadString(
    'assets/json/league_categories.json',
  );
  final List<dynamic> data = jsonDecode(response);

  final List<String> allCategoryOptions = data
      .map<String>((item) => item['value'] as String)
      .toList();

  final Map<String, String> valueToLabelMap = {
    for (var item in data) item['value'] as String: item['label'] as String,
  };

  final List<DropdownMenuEntry<String>> allDropdownOptions = allCategoryOptions
      .where((value) => !addedCategories.any((cat) => cat.category == value))
      .map(
        (value) => DropdownMenuEntry<String>(
          value: value,
          label: valueToLabelMap[value] ?? value,
        ),
      )
      .toList();

  return {
    'allDropdownOptions': allDropdownOptions,
    'allCategoryOptions': allCategoryOptions,
    'valueToLabelMap': valueToLabelMap,
  };
}
