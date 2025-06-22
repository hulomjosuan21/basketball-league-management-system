import 'package:bogoballers/client/screens/team_creator_create_team_screen.dart';
import 'package:bogoballers/core/constants/image_strings.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/theme/colors.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:flutter/material.dart';

class TeamCreatorTeamListScreen extends StatelessWidget {
  const TeamCreatorTeamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
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
                  builder: (context) => TeamCreatorCreateTeamScreen(),
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
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return _teamListItemCard(appColors);
        },
      ),
    );
  }

  Container _teamListItemCard(AppColors appColors) {
    return Container(
      clipBehavior: Clip.hardEdge,
      height: 200,
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: FlexibleNetworkImage(
              imageUrl: null,
              fallbackAsset: ImageStrings.exampleTeamLogo,
              isCircular: false,
              enableEdit: true,
              size: 120,
              radius: Sizes.radiusMd,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Team Name",
              style: TextStyle(color: appColors.gray1100),
            ),
          ),
        ],
      ),
    );
  }
}
