import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/constants/image_strings.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdministratorDashboard extends StatefulWidget {
  const AdministratorDashboard({super.key});

  @override
  State<AdministratorDashboard> createState() => _AdministratorDashboardState();
}

class _AdministratorDashboardState extends State<AdministratorDashboard> {
  @override
  Widget build(BuildContext context) {
    final admin = context.watch<EntityState<LeagueAdministratorModel>>().entity;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroImageAndCards(context, admin),
            SizedBox(height: 80),
            Text(
              "Recent",
              style: TextStyle(
                fontSize: Sizes.fontSizeXl,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _buildHeroImageAndCards(
    BuildContext context,
    LeagueAdministratorModel? admin,
  ) {
    return SizedBox(
      height: 420,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: 320,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(ImageStrings.exampleCourt, fit: BoxFit.cover),
                Container(
                  color: context.appColors.gray1100.withAlpha(
                    (0.5 * 255).toInt(),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        admin?.organization_name ?? 'Test Organization',
                        style: TextStyle(
                          color: context.appColors.gray100,
                          fontSize: Sizes.fontSize4Xl,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        admin?.organization_address ??
                            'Brgy. Dakit, Bogo City, Cebu',
                        style: TextStyle(
                          color: context.appColors.gray100,
                          fontSize: Sizes.fontSizeSm,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -50,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 240,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.1, 0.9, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Center(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    shrinkWrap: true,
                    itemBuilder: (_, index) => _buildLearnMoreCards(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildLearnMoreCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        clipBehavior: Clip.hardEdge,
        width: 220,
        height: 240,
        decoration: BoxDecoration(
          color: context.appColors.gray100,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(width: 0.5, color: context.appColors.gray600),
        ),
        child: Column(
          children: [
            Container(
              height: 140,
              color: context.appColors.accent900,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Opacity(
                      opacity: 0.2,
                      child: Image.asset(
                        ImageStrings.appLogoGray,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: context.appColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Leagues',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Sizes.fontSizeMd,
              ),
              overflow: TextOverflow.fade,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppButton(
                label: "Learn More",
                onPressed: () {},
                size: ButtonSize.sm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
