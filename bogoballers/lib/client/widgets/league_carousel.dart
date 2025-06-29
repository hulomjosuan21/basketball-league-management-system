import 'package:bogoballers/client/screens/client_join_league_screen.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/extensions/extensions.dart';
import 'package:bogoballers/core/models/league_model.dart';
import 'package:bogoballers/core/service_locator.dart';
import 'package:bogoballers/core/state/league_state.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:bogoballers/core/widgets/index.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shimmer/shimmer.dart';

class LeagueCarousel extends StatelessWidget {
  const LeagueCarousel({super.key, required this.future});

  final Future<void> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLeagueCarouselSkeleton(context);
        } else if (snapshot.hasError) {
          return _buildLeagueError(context, 'Failed to load leagues.');
        } else {
          return _buildLeagueCarousel(context);
        }
      },
    );
  }

  Widget _buildLeagueCarousel(BuildContext context) {
    final leagues = getIt<LeagueProvider>().leagues;
    final appColors = context.appColors;

    return CarouselSlider.builder(
      itemCount: leagues.length,
      itemBuilder: (context, index, realIdx) {
        final league = leagues[index];
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: GestureDetector(
            onTap: () {
              print("Tapped League index: ${league.league_id}");
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.radiusMd),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ViewOnlyNetworkImage(
                      imageUrl: league.banner_url ?? null,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(color: Colors.black.withAlpha(30)),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 16,
                    right: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              league.league_title.orNoData(),
                              style: TextStyle(
                                color: appColors.gray100,
                                fontSize: Sizes.fontSizeSm,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ),
                        AppButton(
                          label: 'Join now',
                          onPressed: () =>
                              _handleGotoJoinScreen(context, league),
                          size: ButtonSize.xs,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 200,
        viewportFraction: 0.85,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        scrollPhysics: const BouncingScrollPhysics(),
      ),
    );
  }

  Widget _buildLeagueCarouselSkeleton(BuildContext context) {
    final appColors = context.appColors;

    return CarouselSlider.builder(
      itemCount: 3,
      itemBuilder: (context, index, realIdx) {
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Shimmer.fromColors(
            baseColor: appColors.gray300,
            highlightColor: appColors.gray100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.radiusMd),
              child: Container(color: Colors.grey.shade300),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 200,
        viewportFraction: 0.85,
        enlargeCenterPage: true,
        scrollPhysics: const NeverScrollableScrollPhysics(),
      ),
    );
  }

  Widget _buildLeagueError(BuildContext context, String message) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.red.shade400,
            fontSize: Sizes.fontSizeSm,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleGotoJoinScreen(BuildContext context, LeagueModel league) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JoinLeagueScreen(league: league)),
    );
  }
}
