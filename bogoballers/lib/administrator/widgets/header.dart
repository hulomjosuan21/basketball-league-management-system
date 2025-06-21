import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppHeader extends StatelessWidget {
  final bool showSidebar;
  final VoidCallback onToggleSidebar;

  const AppHeader({
    super.key,
    required this.showSidebar,
    required this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      height: 34,
      width: double.infinity,
      color: appColors.accent900,
      padding: EdgeInsets.all(Sizes.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                  border: Border.all(
                    width: Sizes.borderWidthSm,
                    color: appColors.gray100,
                  ),
                  borderRadius: BorderRadius.circular(Sizes.radiusSm),
                ),
                child: Text(
                  context
                          .watch<EntityState<LeagueAdministratorModel>>()
                          .entity
                          ?.organization_name ??
                      'No data',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 11, color: appColors.accent100),
                ),
              ),
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: appColors.accent100, size: 14),
            onSelected: (String value) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Selected: $value')));
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(child: Text('About Organization')),
              const PopupMenuItem(child: Text('Settings')),
              const PopupMenuItem(child: Text('Logout')),
            ],
          ),
        ],
      ),
    );
  }
}
