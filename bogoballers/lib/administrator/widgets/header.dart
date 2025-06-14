import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final bool showSidebar;
  final VoidCallback onToggleSidebar;
  final LeagueAdministratorModel leagueAdministrator;

  const AppHeader({
    super.key,
    required this.showSidebar,
    required this.onToggleSidebar,
    required this.leagueAdministrator,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      height: 34,
      width: double.infinity,
      color: appColors.accent900,
      padding: EdgeInsets.all(4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: appColors.accent100, size: 14),
            onPressed: onToggleSidebar,
          ),
          const Spacer(),
          Expanded(
            child: Center(
              child: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(minWidth: 200),
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: appColors.gray100),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  leagueAdministrator.organization_name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 11, color: appColors.accent100),
                ),
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}
