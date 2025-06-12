import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: appColors.secondaryGradient),
          child: Center(child: Text("Login")),
        ),
      ),
    );
  }
}
