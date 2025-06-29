import 'package:bogoballers/administrator/screen/league_content/create_league.dart';
import 'package:bogoballers/administrator/screen/league_content/current_league.dart';
import 'package:flutter/material.dart';

class LeagueContent extends StatefulWidget {
  const LeagueContent({super.key});

  @override
  State<LeagueContent> createState() => _LeagueContentState();
}

class _LeagueContentState extends State<LeagueContent> {
  bool hasLeague = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [hasLeague ? CurrentLeague() : CreateLeague()],
        ),
      ),
    );
  }
}
