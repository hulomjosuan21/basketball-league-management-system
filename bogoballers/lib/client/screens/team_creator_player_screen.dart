import 'dart:async';

import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/extensions/extensions.dart';
import 'package:bogoballers/core/helpers/helpers.dart';
import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/services/team_service.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:bogoballers/core/widgets/index.dart';
import 'package:bogoballers/core/widgets/snackbars.dart';
import 'package:flutter/material.dart';

class TeamCreatorTeamPlayerScreen extends StatefulWidget {
  const TeamCreatorTeamPlayerScreen({required this.team, super.key});

  final TeamModel team;

  @override
  State<TeamCreatorTeamPlayerScreen> createState() =>
      _TeamCreatorTeamPlayerScreenState();
}

class _TeamCreatorTeamPlayerScreenState
    extends State<TeamCreatorTeamPlayerScreen> {
  late TeamModel team;
  bool isInviting = false;

  final nameOrEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    team = widget.team;
    print(team.players.toList());
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColors.gray200,
        flexibleSpace: Container(color: appColors.gray200),
        iconTheme: IconThemeData(color: appColors.gray1100),
        centerTitle: true,
        title: Text(
          "Players",
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: Sizes.fontSizeMd,
            color: appColors.gray1100,
          ),
        ),
      ),
      body: Column(
        children: [_buildInvitePlayerInput(), _buildPlayerListCards()],
      ),
    );
  }

  Padding _buildInvitePlayerInput() {
    return Padding(
      padding: const EdgeInsets.all(Sizes.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: nameOrEmailController,
              decoration: InputDecoration(
                label: Text("Invite Player"),
                helperText: "Player email or name",
              ),
            ),
          ),
          SizedBox(width: Sizes.spaceSm),
          AppButton(
            label: 'Invite',
            onPressed: _handleInvitePlayer,
            isDisabled: isInviting,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerListCards() {
    return Expanded(
      child: ListView.builder(
        itemCount: team.players.length,
        itemBuilder: (context, index) {
          final player = team.players[index];
          return TeamPlayerCard(player: player);
        },
      ),
    );
  }

  Future<void> _handleInvitePlayer() async {
    setState(() => isInviting = true);
    try {
      if (nameOrEmailController.text.isEmpty) {
        throw Exception("Please enter a name or email to invite.");
      }
      final service = TeamService();
      final response = await service.invitePlayer(
        team_id: team.team_id,
        name_or_email: nameOrEmailController.text,
      );

      if (response.status) {
        if (context.mounted) {
          showAppSnackbar(
            context,
            message: "Player invited successfully.",
            title: "Success",
            variant: SnackbarVariant.success,
          );
          nameOrEmailController.clear();
        }
      } else {
        throw Exception(response.message);
      }
    } on EntityNotFound catch (e) {
      if (context.mounted) {
        showAppSnackbar(
          context,
          message: e.toString(),
          title: "Error",
          variant: SnackbarVariant.error,
        );

        Navigator.pushReplacementNamed(context, '/client/login/sreen');
      }
    } catch (e) {
      if (context.mounted) {
        handleErrorCallBack(e, (message) {
          showAppSnackbar(
            context,
            message: message,
            title: "Error",
            variant: SnackbarVariant.error,
          );
        });
      }
    } finally {
      if (context.mounted) {
        scheduleMicrotask(() => setState(() => isInviting = false));
      }
    }
  }
}

class TeamPlayerCard extends StatefulWidget {
  const TeamPlayerCard({super.key, required this.player});

  final PlayerTeamModel player;

  @override
  State<TeamPlayerCard> createState() => _TeamPlayerCardState();
}

class _TeamPlayerCardState extends State<TeamPlayerCard> {
  late PlayerTeamModel player; // mutable reference

  @override
  void initState() {
    super.initState();
    player = widget.player; // make a copy you can modify
  }

  void _showPlayerBottomSheet() {
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Sizes.radiusSm),
        ),
      ),
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: Sizes.spaceMd,
            right: Sizes.spaceMd,
            bottom: MediaQuery.of(context).viewInsets.bottom + Sizes.spaceMd,
            top: Sizes.spaceMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  player.full_name.orNoData(),
                  style: const TextStyle(
                    fontSize: Sizes.fontSizeMd,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: Sizes.spaceSm),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        labelText: "Send Message/feedback",
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: Sizes.spaceSm),

                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      // Handle message sending logic here
                      Navigator.pop(context);
                      showAppSnackbar(
                        context,
                        title: "Message Sent",
                        message:
                            "Your message has been sent to ${player.full_name}.",
                        variant: SnackbarVariant.success,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: Sizes.spaceMd),

              AppButton(
                label: "Make Team Captain",
                size: ButtonSize.sm,
                onPressed: () {
                  // // Simulate modification
                  // setState(() {
                  //   player.isCaptain = true; // assuming this exists
                  // });

                  Navigator.pop(context);

                  showAppSnackbar(
                    context,
                    title: "Updated",
                    message: "${player.full_name} is now the team captain.",
                    variant: SnackbarVariant.success,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPlayerBottomSheet,
      child: Container(
        margin: const EdgeInsets.only(
          right: Sizes.spaceMd,
          left: Sizes.spaceMd,
          bottom: Sizes.spaceSm,
        ),
        decoration: BoxDecoration(
          color: context.appColors.gray100,
          borderRadius: BorderRadius.circular(Sizes.radiusMd),
          border: Border.all(
            width: Sizes.borderWidthSm,
            color: context.appColors.gray600,
          ),
        ),
        padding: const EdgeInsets.all(Sizes.spaceSm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlexibleNetworkImage(
              imageUrl: player.profile_image_url,
              size: 40,
              isCircular: true,
            ),
            const SizedBox(width: Sizes.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.full_name.orNoData(),
                    style: const TextStyle(
                      fontSize: Sizes.fontSizeMd,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                  Text(
                    player.position.replaceAll(', ', ' or ').orNoData(),
                    style: const TextStyle(
                      fontSize: Sizes.fontSizeSm,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                  Text(
                    "Gender: ${player.gender.orNoData()}",
                    style: const TextStyle(
                      fontSize: Sizes.fontSizeSm,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                  Text(
                    "Jersey: ${player.jersey_name.orNoData()} • #${formatJerseyNumber(player.jersey_number)}",
                    style: const TextStyle(
                      fontSize: Sizes.fontSizeSm,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                  // if (player.isCaptain == true) // Show captain badge
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 4.0),
                  //     child: Text(
                  //       "🏅 Team Captain",
                  //       style: TextStyle(
                  //         color: context.appColors.primary,
                  //         fontWeight: FontWeight.w600,
                  //         fontSize: Sizes.fontSizeSm,
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
