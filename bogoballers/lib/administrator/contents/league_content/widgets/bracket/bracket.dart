import 'package:flutter/material.dart';
import 'package:flutter_tournament_bracket/flutter_tournament_bracket.dart';

final List<Tournament> _tournaments = [
  Tournament(
    matches: [
      TournamentMatch(
        id: "1",
        teamA: "Real Madrid",
        teamB: "Barcelona",
        scoreTeamA: "3",
        scoreTeamB: "1",
      ),
      TournamentMatch(
        id: "2",
        teamA: "Chelsea",
        teamB: "Liverpool",
        scoreTeamA: "0",
        scoreTeamB: "1",
      ),
      TournamentMatch(
        id: "3",
        teamA: "Juventus",
        teamB: "Paris Saint-Germain",
        scoreTeamA: "0",
        scoreTeamB: "2",
      ),
      TournamentMatch(
        id: "4",
        teamA: "Manchester City",
        teamB: "Inter Milan",
        scoreTeamA: "4",
        scoreTeamB: "2",
      ),
    ],
  ),
  Tournament(
    matches: [
      TournamentMatch(
        id: "1",
        teamA: "AC Milan",
        teamB: "Atletico Madrid",
        scoreTeamA: "4",
        scoreTeamB: "0",
      ),
      TournamentMatch(
        id: "2",
        teamA: "Borussia Dortmund",
        teamB: "Tottenham Hotspur",
        scoreTeamA: "2",
        scoreTeamB: "1",
      ),
    ],
  ),
  Tournament(
    matches: [
      TournamentMatch(
        id: "1",
        teamA: "Ajax",
        teamB: "Sevilla",
        scoreTeamA: "4",
        scoreTeamB: "3",
      ),
    ],
  ),
];

class _MatchPosition {
  final int tournamentIndex;
  final int matchIndex;
  _MatchPosition(this.tournamentIndex, this.matchIndex);
}

class TournamentHome extends StatefulWidget {
  const TournamentHome({super.key});

  @override
  State<TournamentHome> createState() => _TournamentHomeState();
}

class _TournamentHomeState extends State<TournamentHome> {
  late List<Tournament> tournaments;

  @override
  void initState() {
    super.initState();
    tournaments = List.from(_tournaments);
  }

  void _swapMatches(_MatchPosition source, _MatchPosition target) {
    setState(() {
      final sourceMatch =
          tournaments[source.tournamentIndex].matches[source.matchIndex];
      final targetMatch =
          tournaments[target.tournamentIndex].matches[target.matchIndex];
      tournaments[source.tournamentIndex].matches[source.matchIndex] =
          targetMatch;
      tournaments[target.tournamentIndex].matches[target.matchIndex] =
          sourceMatch;
    });
  }

  void _removeMatch(int tournamentIndex, int matchIndex) {
    setState(() {
      tournaments[tournamentIndex].matches.removeAt(matchIndex);
      if (tournaments[tournamentIndex].matches.isEmpty) {
        tournaments.removeAt(tournamentIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TournamentBracket(
            list: tournaments,
            card: (item) => _buildDraggableMatchCard(item),
            itemsMarginVertical: 20.0,
            cardWidth: 220.0,
            cardHeight: 100,
            lineWidth: 80,
            lineThickness: 2,
            lineBorderRadius: 12,
            lineColor: Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableMatchCard(TournamentMatch item) {
    final tournamentIndex = tournaments.indexWhere(
      (t) => t.matches.contains(item),
    );
    final matchIndex = tournaments[tournamentIndex].matches.indexOf(item);
    final position = _MatchPosition(tournamentIndex, matchIndex);

    return LongPressDraggable<_MatchPosition>(
      data: position,
      // Increase delay for better control, adjust as needed
      delay: const Duration(milliseconds: 100),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 220.0,
          height: 100,
          child: customMatchCard(item),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: customMatchCard(item)),
      onDragStarted: () {
        // Provide haptic feedback when drag starts
        debugPrint("Dragging match card");
      },
      child: DragTarget<_MatchPosition>(
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: [
              GestureDetector(
                onDoubleTap: () => _removeMatch(tournamentIndex, matchIndex),
                child: customMatchCard(item),
              ),
              if (candidateData.isNotEmpty)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Drop Here',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        onWillAcceptWithDetails: (details) =>
            true, // Accept drags from any position
        onAcceptWithDetails: (details) {
          _swapMatches(details.data, position);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Match swapped!')));
        },
      ),
    );
  }

  Container customMatchCard(TournamentMatch item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 0.5, color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  item.teamA ?? "No Info",
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  item.teamB ?? "No Info",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
          const VerticalDivider(color: Colors.black),
          const SizedBox(width: 5),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                item.scoreTeamA ?? "",
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                item.scoreTeamB ?? "",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}
