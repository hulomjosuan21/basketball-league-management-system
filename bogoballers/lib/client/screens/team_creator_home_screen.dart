import 'package:bogoballers/client/widgets/league_carousel.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/helpers/logout.dart';
import 'package:bogoballers/core/service_locator.dart';
import 'package:bogoballers/core/state/league_state.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class TeamCreatorHomeScreen extends StatefulWidget {
  const TeamCreatorHomeScreen({super.key});

  @override
  State<TeamCreatorHomeScreen> createState() => _TeamCreatorHomeScreenState();
}

class _TeamCreatorHomeScreenState extends State<TeamCreatorHomeScreen> {
  final SearchController _searchController = SearchController();
  final FocusNode _focusNode = FocusNode();

  late Future<void> _leagueFuture;

  @override
  void initState() {
    super.initState();
    _leagueFuture = fetchLeague();
  }

  Future<void> fetchLeague({bool refresh = false}) async {
    if (refresh) {
      getIt<LeagueProvider>().resetLeagueFetchedFlag();
    }
    await getIt<LeagueProvider>().fetchLeaguesOnce();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          setState(() {
            _leagueFuture = fetchLeague(refresh: true);
          });
          return _leagueFuture;
        },
        edgeOffset: 100,
        color: appColors.accent900,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Leagues',
                      style: TextStyle(
                        fontSize: Sizes.fontSizeMd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'See all',
                        style: TextStyle(
                          fontSize: Sizes.fontSizeSm,
                          color: appColors.accent900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: LeagueCarousel(future: _leagueFuture)),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    final appColors = context.appColors;
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: true,
      stretch: true,
      expandedHeight: 130,
      backgroundColor: appColors.gray200,

      onStretchTrigger: () async {
        await Future.delayed(Duration(milliseconds: 500));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Stretch triggered')));
      },

      actions: [
        PopupMenuButton(
          icon: Icon(Icons.more_vert, color: appColors.gray1100),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(child: Text('Test')),
            PopupMenuItem(
              child: Text('Logout'),
              onTap: () =>
                  handleLogout(context: context, route: '/client/login/screen'),
            ),
          ],
        ),
      ],

      flexibleSpace: Container(
        color: appColors.gray200,
        child: FlexibleSpaceBar(
          collapseMode: CollapseMode.parallax,
          background: Padding(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SearchAnchor(
                viewOnSubmitted: (value) {
                  _handleSearch(value);
                },
                searchController: _searchController,
                builder: (context, controller) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(height: 48),
                    child: SearchBar(
                      controller: _searchController,
                      focusNode: _focusNode,
                      hintText: 'Search...',
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(
                        appColors.gray100,
                      ),
                      surfaceTintColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      textInputAction: TextInputAction.search,

                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      ),

                      textStyle: WidgetStateProperty.all(
                        const TextStyle(fontSize: 16, height: 1.2),
                      ),

                      onTap: () {
                        controller.openView();
                      },

                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: appColors.gray600,
                            width: 0.5,
                          ),
                        ),
                      ),

                      leading: const Icon(Icons.search, size: 20),
                      trailing: [
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 36,
                          ),
                          onPressed: () {
                            _handleSearch(_searchController.text);
                          },
                        ),
                      ],
                    ),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  final query = controller.text.toLowerCase();
                  final filtered = []
                      .where((s) => s.toLowerCase().contains(query))
                      .toList();

                  return filtered.map((s) {
                    return ListTile(
                      title: Text(s),
                      onTap: () {
                        controller.text = s;
                        _handleSearch(s);
                        _focusNode.unfocus();
                      },
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSearch(s) {}
}
