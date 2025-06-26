import 'package:bogoballers/client/screens/team_creator_create_team_screen.dart';
import 'package:bogoballers/client/screens/team_creator_team_screen.dart';
import 'package:bogoballers/core/constants/image_strings.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/extensions/extensions.dart';
import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/core/state/team_provider.dart';
import 'package:bogoballers/core/theme/colors.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:bogoballers/core/widgets/snackbars.dart';
import 'package:bogoballers/core/service_locator.dart';
import 'package:flutter/material.dart';

class TeamCreatorTeamListScreen extends StatefulWidget {
  const TeamCreatorTeamListScreen({super.key});

  @override
  State<TeamCreatorTeamListScreen> createState() =>
      _TeamCreatorTeamListScreenState();
}

class _TeamCreatorTeamListScreenState extends State<TeamCreatorTeamListScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  Future<void> _fetchTeams({bool refresh = false}) async {
    if (!refresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final entity = getIt<EntityState<UserModel>>().entity;

      if (entity == null) throw EntityNotFound(AccountTypeEnum.TEAM_CREATOR);

      final teamProvider = getIt<TeamProvider>();

      if (refresh) {
        await teamProvider.refreshTeams(entity.user_id);
      } else {
        await teamProvider.fetchTeamsOnce(entity.user_id);
      }
    } on EntityNotFound catch (e) {
      if (context.mounted) {
        showAppSnackbar(
          context,
          message: e.toString(),
          title: "Error",
          variant: SnackbarVariant.error,
        );
        Navigator.pushReplacementNamed(context, '/client/login/screen');
      }
    } catch (e) {
      _errorMessage = "Failed to load teams. Please try again.";
      if (context.mounted) {
        handleErrorCallBack(_errorMessage!, (message) {
          showAppSnackbar(
            context,
            message: message,
            title: "Error",
            variant: SnackbarVariant.error,
          );
        });
      }
    } finally {
      if (mounted && !refresh) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final teamProvider = getIt<TeamProvider>();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(color: appColors.gray200),
        elevation: 0,
        centerTitle: true,
        backgroundColor: appColors.gray200,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeamCreatorCreateTeamScreen(),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: appColors.accent100,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: Icon(Icons.add, color: appColors.gray1100),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: appColors.accent900,
        onRefresh: () => _fetchTeams(refresh: true),
        child: _isLoading
            ? ListView(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: appColors.accent900,
                      ),
                    ),
                  ),
                ],
              )
            : _errorMessage != null
            ? ListView(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            size: ButtonSize.sm,
                            label: 'Retry',
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                                _errorMessage = null;
                              });
                              await _fetchTeams(refresh: true);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : teamProvider.teams.isEmpty
            ? ListView(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        "No teams found",
                        style: TextStyle(color: appColors.gray800),
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: teamProvider.teams.length,
                itemBuilder: (context, index) {
                  final team = teamProvider.teams[index];
                  return _teamListItemCard(team);
                },
              ),
      ),
    );
  }

  Widget _teamListItemCard(TeamModel team) {
    final appColors = context.appColors;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamCreatorTeamScreen(team: team),
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        height: 120,
        padding: EdgeInsets.all(Sizes.spaceXs),
        margin: EdgeInsets.only(
          left: Sizes.spaceMd,
          right: Sizes.spaceMd,
          bottom: Sizes.spaceMd,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            width: Sizes.borderWidthSm,
            color: appColors.gray600,
          ),
          borderRadius: BorderRadius.circular(Sizes.radiusMd),
          color: appColors.gray100,
        ),
        child: Row(
          children: [
            FlexibleNetworkImage(
              imageUrl: team.team_logo_url,
              fallbackAsset: ImageStrings.exampleTeamLogo,
              isCircular: false,
              size: 100,
              radius: Sizes.radiusMd,
            ),
            const SizedBox(width: Sizes.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    team.team_name.orNoData(),
                    style: TextStyle(
                      color: appColors.gray1100,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.green, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Wins: ${team.total_wins}',
                        style: TextStyle(
                          color: appColors.gray900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.close, color: Colors.red, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Losses: ${team.total_losses}',
                        style: TextStyle(
                          color: appColors.gray900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
