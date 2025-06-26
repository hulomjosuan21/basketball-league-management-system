import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:bogoballers/core/widgets/index.dart';
import 'package:flutter/material.dart';

class TeamCreatorTeamPlayerScreen extends StatefulWidget {
  const TeamCreatorTeamPlayerScreen({super.key});

  @override
  State<TeamCreatorTeamPlayerScreen> createState() =>
      _TeamCreatorTeamPlayerScreenState();
}

class _TeamCreatorTeamPlayerScreenState
    extends State<TeamCreatorTeamPlayerScreen> {
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
              decoration: InputDecoration(
                label: Text("Invite Player"),
                helperText: "Player email or name",
              ),
            ),
          ),
          SizedBox(width: Sizes.spaceSm),
          AppButton(label: 'Invite', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildPlayerListCards() {
    return Expanded(
      child: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(
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
              mainAxisSize: MainAxisSize.min,
              children: [
                FlexibleNetworkImage(
                  imageUrl: null,
                  size: 40,
                  isCircular: true,
                ),
                SizedBox(width: Sizes.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Player name",
                        style: TextStyle(
                          fontSize: Sizes.fontSizeMd,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                      ),
                      Text(
                        "Player Details",
                        style: TextStyle(
                          fontSize: Sizes.fontSizeSm,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.fade,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
