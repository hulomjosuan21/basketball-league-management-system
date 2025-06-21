import 'package:bogoballers/core/components/index.dart';
import 'package:bogoballers/core/helpers/logout.dart';
import 'package:flutter/material.dart';

class TeamCreatorHomeScreen extends StatefulWidget {
  const TeamCreatorHomeScreen({super.key});

  @override
  State<TeamCreatorHomeScreen> createState() => _TeamCreatorHomeScreenState();
}

class _TeamCreatorHomeScreenState extends State<TeamCreatorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AppButton(
          label: "Logut",
          onPressed: () =>
              handleLogout(context: context, route: '/client/login'),
        ),
      ),
    );
  }
}
