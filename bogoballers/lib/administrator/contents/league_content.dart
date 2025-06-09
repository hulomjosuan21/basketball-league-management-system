import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class LeagueContent extends StatelessWidget {
  LeagueContent({super.key});

  static const columns = <DataColumn>[
    DataColumn(label: Text('ID')),
    DataColumn(label: Text('Player Name')),
    DataColumn(label: Text('Age')),
  ];

  // --- Generate 50 rows of demo data ---
  final rows = List<DataRow>.generate(
    50,
    (index) => DataRow(
      cells: [
        DataCell(Text('${index + 1}')), // ID
        DataCell(Text('Player ${index + 1}')), // Name
        DataCell(Text('${18 + (index % 15)}')), // Age 18-32
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(child: Text("Create League")),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: appColors.gray100,
              borderRadius: BorderRadius.circular(8),
              border: BoxBorder.all(width: 0.5, color: appColors.gray600),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: const [
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "League Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "League Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: appColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DataTable(columns: columns, rows: rows),
          ),
        ],
      ),
    );
  }
}
