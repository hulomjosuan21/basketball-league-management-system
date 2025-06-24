import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:bogoballers/core/service_locator.dart';
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
    final appColors = context.appColors;
    final player = getIt<EntityState<PlayerModel>>().entity;

    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: true,
            stretch: true,
            backgroundColor: appColors.gray100,
            onStretchTrigger: () async {
              await Future.delayed(Duration(milliseconds: 500));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Stretch triggered')));
            },

            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlexibleNetworkImage(
                isCircular: true,
                imageUrl: null,
                enableEdit: false,
                onEdit: () async {
                  return null;
                },
                size: 40,
              ),
            ),

            actions: [
              IconButton(
                icon: Icon(Icons.notifications, color: appColors.gray1100),
                onPressed: () {},
              ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: appColors.gray100),
            ),
          ),
        ],
      ),
    );
  }
}
