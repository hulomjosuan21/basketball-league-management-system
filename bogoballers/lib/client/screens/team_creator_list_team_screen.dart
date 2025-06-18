import 'package:bogoballers/client/screens/team_creator_create_team_screen.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appColors.accent900,
        elevation: 1,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return TeamCreatorCreateTeamScreen();
              },
            ),
          );
        },
        child: Icon(Icons.add, color: appColors.gray100),
      ),
    );
  }
}
