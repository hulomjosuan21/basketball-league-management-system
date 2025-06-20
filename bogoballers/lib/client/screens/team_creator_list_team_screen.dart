import 'package:bogoballers/client/screens/team_creator_create_team_screen.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TeamCreatorTeamListScreen extends StatelessWidget {
  const TeamCreatorTeamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "My Teams",
          style: TextStyle(
            fontSize: Sizes.fontSizeLg,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return TeamCreatorCreateTeamScreen();
                },
              ),
            ),
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
