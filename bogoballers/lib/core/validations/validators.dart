import 'package:bogoballers/core/constants/validation_patterns.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:flutter/material.dart';

bool isValidateContactNumber(String? value) {
  if (value == null) return false;

  if (!value.startsWith('+63')) return false;

  final phoneNumberPart = value.substring(3);

  final digitsOnly = phoneNumberPart.replaceAll(RegExp(r'\D'), '');

  if (digitsOnly.length != 10) return false;

  if (!digitsOnly.startsWith('9')) return false;

  if (value.length != 13) return false;

  return true;
}

bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );
  return emailRegex.hasMatch(email);
}

void validateCreateTeamFields({
  required TextEditingController teamNameController,
  required TextEditingController teamAddressController,
  required String? fullPhoneNumber,
  required TextEditingController teamMotoController,
  required TextEditingController coachNameController,
  required TextEditingController assistantCoachNameController,
  required bool hasAcceptedTerms,
}) {
  final teamName = teamNameController.text.trim();
  final teamAddress = teamAddressController.text.trim();
  final teamMoto = teamMotoController.text.trim();
  final coachName = coachNameController.text.trim();
  final assistantCoachName = assistantCoachNameController.text.trim();

  if (teamName.isEmpty) {
    throw ValidationException("Team name cannot be empty");
  }
  if (!RegExPatterns.teamName.hasMatch(teamName)) {
    throw ValidationException("Invalid team name format");
  }

  if (teamAddress.isEmpty) {
    throw ValidationException("Team address cannot be empty");
  }
  if (!RegExPatterns.address.hasMatch(teamAddress)) {
    throw ValidationException(
      "Invalid address format\nExample: Brgy. Sample, Sample City, Sample Province",
    );
  }

  if (fullPhoneNumber == null || fullPhoneNumber.trim().isEmpty) {
    throw ValidationException("Phone number cannot be empty");
  }
  if (!isValidateContactNumber(fullPhoneNumber)) {
    throw ValidationException("Invalid Phone number");
  }

  if (teamMoto.isEmpty) {
    throw ValidationException("Team moto cannot be empty");
  }

  if (coachName.isEmpty) {
    throw ValidationException("Coach full name cannot be empty");
  }
  if (!RegExPatterns.fullName.hasMatch(coachName)) {
    throw ValidationException(
      "Invalid coach name format\nUse: Firstname Lastname",
    );
  }

  if (!RegExPatterns.fullName.hasMatch(assistantCoachName)) {
    throw ValidationException(
      "Invalid assistant coach name format\nUse: Firstname Lastname",
    );
  }

  if (!hasAcceptedTerms) {
    throw ValidationException("You must accept the terms and conditions");
  }
}
