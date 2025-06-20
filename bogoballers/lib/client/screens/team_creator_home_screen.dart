import 'package:bogoballers/core/components/index.dart';
import 'package:bogoballers/core/hive/app_box.dart';
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
        child: AppButton(label: "Logut", onPressed: _handleLogout),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await AppBox.clearAccessToken();
    Navigator.pushReplacementNamed(context, '/client/login');
  }
}
