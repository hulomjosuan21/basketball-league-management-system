import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class SlidingIntroBanner extends StatefulWidget {
  const SlidingIntroBanner({super.key});

  @override
  State<SlidingIntroBanner> createState() => _SlidingIntroBanner();
}

class _SlidingIntroBanner extends State<SlidingIntroBanner> {
  final List<String> messages = [
    "🎉 Welcome to BogoBallers!",
    "🏀 The ultimate basketball league companion.",
    "📲 Create teams, manage players, and compete.",
    "🔥 Stay updated on events and tryouts.",
    "💪 Built for players, coaches, and fans alike.",
  ];

  int currentMessageIndex = 0;
  Offset slideOffset = const Offset(0, 1);

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        slideOffset = const Offset(0, 0);
      });
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;

      setState(() {
        currentMessageIndex = (currentMessageIndex + 1) % messages.length;
      });
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 600),
        offset: slideOffset,
        curve: Curves.easeOut,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: appColors.gray1100.withAlpha((0.6 * 255).toInt()),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              messages[currentMessageIndex],
              style: TextStyle(
                color: appColors.gray100,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
