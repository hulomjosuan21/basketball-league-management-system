import 'package:bogoballers/client/screens/notification_screen.dart';
import 'package:bogoballers/core/theme/colors.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  final SearchController _searchController = SearchController();
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = ['Shoes', 'Ball', 'Court', 'Team'];

  void _handleGotoNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationScreen(enableBack: true),
      ),
    );
  }

  void _handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      print('Searching: $query');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(title: Text('Item ${index + 1}')),
              childCount: 20,
            ),
          ),
        ],
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

      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlexibleNetworkImage(
          isCircular: true,
          imageUrl: null,
          enableEdit: false,
          onEdit: () async => null,
          size: 40,
        ),
      ),

      actions: [
        IconButton(
          icon: Icon(Iconsax.notification, color: appColors.gray1100),
          onPressed: _handleGotoNotification,
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
                  final filtered = _suggestions
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
}
