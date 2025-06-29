import 'package:bogoballers/core/helpers/helpers.dart';
import 'package:flutter/material.dart';

class CategoryInputData {
  final String category;
  final TextEditingController formatController;
  final TextEditingController maxTeamController;
  final TextEditingController entranceFeeController;

  CategoryInputData({
    required this.category,
    String? initialFormat,
    String? initialMaxTeam,
    String? initialEntranceFee,
  }) : formatController = TextEditingController(text: initialFormat ?? ''),
       maxTeamController = TextEditingController(text: initialMaxTeam ?? ''),
       entranceFeeController = TextEditingController(
         text: initialEntranceFee ?? '',
       );

  String get format => formatController.text;
  String get maxTeam => maxTeamController.text;
  String get entranceFee => entranceFeeController.text;
}

Future<Map<String, dynamic>> getLeagueCategoryDropdownData(
  List<CategoryInputData> addedCategories,
) async {
  try {
    final List<String> apiCategories = await leagueCategories();

    final Map<String, String> valueToLabelMap = {
      for (var value in apiCategories) value: value,
    };

    final List<DropdownMenuEntry<String>> allDropdownOptions = apiCategories
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
      'allCategoryOptions': apiCategories,
      'valueToLabelMap': valueToLabelMap,
    };
  } catch (e, stack) {
    debugPrint("Error building dropdown data: $e\n$stack");
    return {
      'allDropdownOptions': <DropdownMenuEntry<String>>[],
      'allCategoryOptions': <String>[],
      'valueToLabelMap': <String, String>{},
    };
  }
}
