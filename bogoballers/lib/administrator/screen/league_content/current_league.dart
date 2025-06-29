import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:flutter/material.dart';

class CurrentLeague extends StatelessWidget {
  const CurrentLeague({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    const double targetHeight = 200;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appColors.gray100,
            border: Border.all(width: 0.5, color: appColors.gray600),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: targetHeight,
                      width: targetHeight * (16 / 9),
                      child: FlexibleNetworkImage(
                        enableEdit: true,
                        imageUrl: null,
                        size: targetHeight * (16 / 9),
                        aspectRatio: 16 / 9,
                        radius: 8,
                        isCircular: false,
                        enableViewImageFull: true,
                      ),
                    ),
                    SizedBox(width: Sizes.spaceMd),
                    SizedBox(
                      height: targetHeight,
                      width: targetHeight,
                      child: FlexibleNetworkImage(
                        enableEdit: true,
                        imageUrl: null,
                        size: targetHeight,
                        aspectRatio: 1 / 1,
                        radius: 8,
                        isCircular: false,
                        enableViewImageFull: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
