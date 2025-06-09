import 'package:flutter/material.dart';

class PlayerMainScreen extends StatelessWidget {
  const PlayerMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Dashboard')),
      body: Center(child: Text('Hello world')),
    );
  }
}
