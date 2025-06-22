import 'package:bogoballers/client/screens/client_login_screen.dart';
import 'package:bogoballers/client/screens/player_register_screen.dart';
import 'package:bogoballers/client/screens/team_creator_register_screen.dart';
import 'package:bogoballers/core/widgets/auth_navigator.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ClientAuthScreen extends StatelessWidget {
  const ClientAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    Widget buildRoleCard({
      required String text,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: appColors.gray100,
            borderRadius: BorderRadius.circular(Sizes.radiusMd),
            border: Border.all(
              color: appColors.gray600,
              width: Sizes.borderWidthSm,
            ),
          ),
          padding: EdgeInsets.all(Sizes.spaceMd),
          child: Column(
            children: [
              Icon(
                icon,
                size: Sizes.fontSizeLg * 2,
                color: appColors.accent900,
              ),
              SizedBox(height: Sizes.spaceSm),
              Text(text),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Are you here to play or lead a team?",
                  style: TextStyle(
                    fontSize: Sizes.fontSizeMd,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Sizes.spaceLg),
                buildRoleCard(
                  text: "I’m a Player",
                  icon: Iconsax.dribbble,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return PlayerRegisterScreen();
                      },
                    ),
                  ),
                ),
                SizedBox(height: Sizes.spaceMd),
                buildRoleCard(
                  text: "I’m a Team Creator",
                  icon: Iconsax.profile_2user,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return TeamCreatorRegisterScreen();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.only(
                left: Sizes.spaceSm,
                right: Sizes.spaceSm,
                top: Sizes.spaceSm,
                bottom: Sizes.spaceLg,
              ),
              child: authNavigator(
                context,
                "Already have an account?",
                " Login",
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientLoginScreen()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
