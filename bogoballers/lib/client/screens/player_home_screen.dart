import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/service_locator.dart';
import 'package:flutter/material.dart';

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  final List<String> items = List.generate(50, (index) => 'Item ${index + 1}');

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(viewportFraction: 0.9);

    final player = getIt<EntityState<PlayerModel>>().entity;

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(height: 16),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: PageView.builder(
              controller: controller,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: items.length > 1
                        ? EdgeInsets.only(right: 10)
                        : null,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      player?.full_name ?? 'No data',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withAlpha((0.5 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: EdgeInsets.only(bottom: 8),
                    child: Center(
                      child: Text(
                        player?.full_name ?? 'No data',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
