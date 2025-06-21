import 'package:bogoballers/administrator/screen/league_content/widgets/bracket/bracket.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class BracketStructureContent extends StatelessWidget {
  const BracketStructureContent({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 42,
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: BoxDecoration(
              color: appColors.gray100,
              border: Border(
                bottom: BorderSide(width: 0.5, color: appColors.gray600),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    "Bracket Structure",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, size: 14),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Category", style: TextStyle(fontSize: 11)),
                          DropdownButton<String>(
                            icon: Icon(Icons.arrow_drop_down, size: 14),
                            iconSize: 14,
                            style: TextStyle(
                              fontSize: 11,
                              color: appColors.gray1100,
                            ),
                            underline: SizedBox(),
                            onChanged: (String? newValue) {},
                            items: ['A', 'B', 'C'].map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          SizedBox(width: 16),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.check, size: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<bool>(
              future: Future.delayed(Duration(milliseconds: 500), () => true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return TournamentHome();
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: appColors.accent900,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
