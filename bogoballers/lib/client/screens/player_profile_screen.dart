import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/extensions/extensions.dart';
import 'package:bogoballers/core/helpers/logout.dart';
import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:bogoballers/core/widgets/setting_menu_list.dart';
import 'package:bogoballers/service_locator.dart';
import 'package:flutter/material.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final player = getIt<EntityState<PlayerModel>>().entity;

    return Scaffold(
      appBar: AppBar(backgroundColor: appColors.gray200),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              FlexibleNetworkImage(
                enableViewImageFull: true,
                isCircular: true,
                imageUrl: player?.profile_image_url,
                enableEdit: true,
                onEdit: _handleEdit,
                size: 120,
              ),
              const SizedBox(height: Sizes.spaceMd),
              SizedBox(
                child: Text(
                  player?.full_name ?? orNoData,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: Sizes.fontSizeMd,
                  ),
                ),
              ),
              const SizedBox(height: Sizes.spaceMd),
              SizedBox(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Sizes.spaceLg,
                      vertical: Sizes.spaceSm,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.accent400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      player?.user.email ?? orNoData,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appColors.accent900,
                        fontWeight: FontWeight.w400,
                        fontSize: Sizes.fontSizeSm,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Sizes.spaceLg),
              Padding(
                padding: const EdgeInsets.all(Sizes.spaceSm),
                child: SettingsMenuList(
                  items: [
                    SettingsMenuItem(
                      icon: Icons.person,
                      label: 'Profile',
                      content: const Text('Edit your profile details here.'),
                    ),
                    SettingsMenuItem(
                      icon: Icons.notifications,
                      label: 'Notifications',
                      content: const Text('Manage your notifications here.'),
                    ),
                    SettingsMenuItem(
                      icon: Icons.settings,
                      label: 'Account Settings',
                      onTap: () {
                        // Navigate to another screen
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.all(Sizes.spaceSm),
                child: AppButton(
                  label: "Logout",
                  onPressed: () => handleLogout(
                    context: context,
                    route: '/administrator/login/sreen',
                  ),
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _handleEdit() async {
    return null;
  }
}
