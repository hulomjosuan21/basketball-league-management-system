import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/helpers/logout.dart';
import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppHeader extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggleSidebar;

  const AppHeader({
    super.key,
    required this.isCollapsed,
    required this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      color: appColors.accent900,
      constraints: BoxConstraints(maxHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, size: 18),
            color: appColors.accent100,
            onPressed: onToggleSidebar,
          ),
          Container(
            constraints: BoxConstraints(minWidth: 200, maxWidth: 400),
            decoration: BoxDecoration(
              border: BoxBorder.all(width: 0.5, color: appColors.gray600),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                context
                        .watch<EntityState<LeagueAdministratorModel>>()
                        .entity
                        ?.organization_name ??
                    'No data',
                style: TextStyle(
                  fontSize: Sizes.fontSizeSm,
                  color: appColors.gray100,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: appColors.accent100, size: 14),
            onSelected: (String value) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Selected: $value')));
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(child: Text('About Organization')),
              PopupMenuItem(child: Text('Settings')),
              PopupMenuItem(
                child: Text('Logout'),
                onTap: () => handleLogout(
                  context: context,
                  route: '/administrator/login/sreen',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
