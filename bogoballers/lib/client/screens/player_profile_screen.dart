import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/helpers/logout.dart';
import 'package:flutter/material.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
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
