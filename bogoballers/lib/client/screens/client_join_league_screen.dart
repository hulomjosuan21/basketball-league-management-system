import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/extensions/extensions.dart';
import 'package:bogoballers/core/models/league_model.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:flutter/material.dart';

class JoinLeagueScreen extends StatefulWidget {
  const JoinLeagueScreen({required this.league, super.key});
  final LeagueModel league;

  @override
  State<JoinLeagueScreen> createState() => _JoinLeagueScreenState();
}

class _JoinLeagueScreenState extends State<JoinLeagueScreen> {
  late LeagueModel league;

  @override
  void initState() {
    super.initState();
    league = widget.league;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColors.gray200,
        iconTheme: IconThemeData(color: appColors.gray1100),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Sizes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Sizes.radiusMd),
                child: ViewOnlyNetworkImage(imageUrl: league.banner_url),
              ),
            ),
            const SizedBox(height: Sizes.spaceMd),

            Text(
              league.league_title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              maxLines: 5,
              overflow: TextOverflow.fade,
            ),
            const SizedBox(height: Sizes.spaceSm),
            Divider(thickness: 0.5, color: appColors.gray600),
            const Text(
              "Description",
              style: TextStyle(
                fontSize: Sizes.fontSizeMd,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              league.league_description.orNoData(),
              style: const TextStyle(fontSize: Sizes.fontSizeSm),
              maxLines: 10,
              textAlign: TextAlign.justify,
              overflow: TextOverflow.fade,
            ),

            const SizedBox(height: Sizes.spaceLg),

            Divider(thickness: 0.5, color: appColors.gray600),
            const Text(
              "Categories",
              style: TextStyle(
                fontSize: Sizes.fontSizeLg,
                fontWeight: FontWeight.w600,
              ),
            ),
            ...league.categories.map((category) {
              return _buildCategoriesCard(category);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Container _buildCategoriesCard(LeagueCategoryModel category) {
    final appColors = context.appColors;
    final fee = category.entrance_fee_amount;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Sizes.spaceSm),
      decoration: BoxDecoration(
        color: appColors.gray100,
        borderRadius: BorderRadius.circular(Sizes.radiusMd),
        border: BoxBorder.all(
          width: Sizes.borderWidthSm,
          color: appColors.gray600,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.category_name,
              style: const TextStyle(
                fontSize: Sizes.fontSizeLg,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 20,
              overflow: TextOverflow.fade,
            ),
            Divider(thickness: 0.5, color: appColors.gray600),

            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "Format: ",
                    style: TextStyle(
                      fontSize: Sizes.fontSizeSm,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: category.category_format,
                    style: TextStyle(
                      fontSize: Sizes.fontSizeSm,
                      fontWeight: FontWeight.w500,
                      color: appColors.gray900,
                    ),
                  ),
                ],
              ),
              maxLines: 50,
              overflow: TextOverflow.fade,
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                if (fee == 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "FREE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "Entrance Fee: ",
                          style: TextStyle(
                            fontSize: Sizes.fontSizeSm,
                            fontWeight: FontWeight.w500,
                            color: Colors.black, // base color
                          ),
                        ),
                        TextSpan(
                          text: "₱${fee.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: Sizes.fontSizeSm,
                            fontWeight: FontWeight.w500,
                            color: appColors.accent900,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.fade,
                  ),

                const Spacer(),

                AppButton(onPressed: () {}, label: "Join", size: ButtonSize.sm),
              ],
            ),
            const SizedBox(height: Sizes.spaceXs),

            Text(
              "Make sure your team is eligible and matches this category's requirements.",
              style: TextStyle(
                fontSize: Sizes.fontSizeXs,
                color: appColors.gray900,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
