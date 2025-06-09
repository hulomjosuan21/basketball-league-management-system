import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class BracketStructureContent extends StatelessWidget {
  const BracketStructureContent({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    const organizationName = "Bogo City League";

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 34,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: appColors.accent100,
            size: 14,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(width: 0.5, color: appColors.gray100),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              organizationName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 11, color: appColors.accent100),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
