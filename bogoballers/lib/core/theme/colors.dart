import 'package:flutter/material.dart';

const MaterialColor lightPrimarySwatch = MaterialColor(0xFFF85C15, <int, Color>{
  50: Color(0xFFFFF5F0),
  100: Color(0xFFFFE9DE),
  200: Color(0xFFFFD7C4),
  300: Color(0xFFFFC9B1),
  400: Color(0xFFFFB99C),
  500: Color(0xFFFFA585),
  600: Color(0xFFF58C67),
  700: Color(0xFFF85C15),
  800: Color(0xFFEA4F00),
  900: Color(0xFFD74400),
});

const darkPrimarySwatch = MaterialColor(0xFFF85C15, <int, Color>{
  50: Color(0xFF1F1511),
  100: Color(0xFF371A10),
  200: Color(0xFF4D1905),
  300: Color(0xFF5C210A),
  400: Color(0xFF6C2E17),
  500: Color(0xFF843E25),
  600: Color(0xFFAB502F),
  700: Color(0xFFF85C15),
  800: Color(0xFFEA4F00),
  900: Color(0xFFFF9870),
});

final lightAppColors = AppColors(
  accent100: Color(0xFFFEFCFB), // often used in text & card backgrounds
  accent200: Color(0xFFFFF5F0),
  accent300: Color(0xFFFFE9DE), // often used in background
  accent400: Color(0xFFFFD7C4),
  accent500: Color(0xFFFFC9B1),
  accent600: Color(0xFFFFB99C),
  accent700: Color(0xFFFFA585),
  accent800: Color(0xFFF58C67),
  accent900: Color(0xFFF85C15), // often used in appbars background
  accent1000: Color(0xFFEA4F00),
  accent1100: Color(0xFFD74400),
  accent1200: Color(0xFF592C1C),
  gray50: Color(0xFFFCFCFD),
  gray100: Color(0xFFF9F9FB),
  gray200: Color(0xFFEFF0F3),
  gray300: Color(0xFFE7E8EC),
  gray400: Color(0xFFE0E1E6),
  gray500: Color(0xFFD8D9E0),
  gray600: Color(0xFFCDCED7),
  gray700: Color(0xFFB9BBC6),
  gray800: Color(0xFF8B8D98),
  gray900: Color(0xFF80828D),
  gray1000: Color(0xFF62636C),
  gray1100: Color(0xFF1E1F24), // often used in text & icons
);

final darkAppColors = AppColors(
  accent100: Color(0xFF160F0D),
  accent200: Color(0xFF1F1511),
  accent300: Color(0xFF371A10),
  accent400: Color(0xFF4D1905),
  accent500: Color(0xFF5C210A),
  accent600: Color(0xFF6C2E17),
  accent700: Color(0xFF843E25),
  accent800: Color(0xFFAB502F),
  accent900: Color(0xFFF85C15),
  accent1000: Color(0xFFEA4F00),
  accent1100: Color(0xFFFF9870),
  accent1200: Color(0xFFFFD9CA),
  gray50: Color(0xFF111113),
  gray100: Color(0xFF19191B),
  gray200: Color(0xFF222325),
  gray300: Color(0xFF292A2E),
  gray400: Color(0xFF303136),
  gray500: Color(0xFF393A40),
  gray600: Color(0xFF46484F),
  gray700: Color(0xFF5F606A),
  gray800: Color(0xFF6C6E79),
  gray900: Color(0xFF797B86),
  gray1000: Color(0xFFB2B3BD),
  gray1100: Color(0xFFEEEEF0),
);

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color accent100;
  final Color accent200;
  final Color accent300;
  final Color accent400;
  final Color accent500;
  final Color accent600;
  final Color accent700;
  final Color accent800;
  final Color accent900;
  final Color accent1000;
  final Color accent1100;
  final Color accent1200;

  final Color gray50;
  final Color gray100;
  final Color gray200;
  final Color gray300;
  final Color gray400;
  final Color gray500;
  final Color gray600;
  final Color gray700;
  final Color gray800;
  final Color gray900;
  final Color gray1000;
  final Color gray1100;

  const AppColors({
    required this.accent100,
    required this.accent200,
    required this.accent300,
    required this.accent400,
    required this.accent500,
    required this.accent600,
    required this.accent700,
    required this.accent800,
    required this.accent900,
    required this.accent1000,
    required this.accent1100,
    required this.accent1200,
    required this.gray50,
    required this.gray100,
    required this.gray200,
    required this.gray300,
    required this.gray400,
    required this.gray500,
    required this.gray600,
    required this.gray700,
    required this.gray800,
    required this.gray900,
    required this.gray1000,
    required this.gray1100,
  });

  @override
  AppColors copyWith({
    Color? accent100,
    Color? accent200,
    Color? accent300,
    Color? accent400,
    Color? accent500,
    Color? accent600,
    Color? accent700,
    Color? accent800,
    Color? accent900,
    Color? accent1000,
    Color? accent1100,
    Color? accent1200,
    Color? gray50,
    Color? gray100,
    Color? gray200,
    Color? gray300,
    Color? gray400,
    Color? gray500,
    Color? gray600,
    Color? gray700,
    Color? gray800,
    Color? gray900,
    Color? gray1000,
    Color? gray1100,
  }) {
    return AppColors(
      accent100: accent100 ?? this.accent100,
      accent200: accent200 ?? this.accent200,
      accent300: accent300 ?? this.accent300,
      accent400: accent400 ?? this.accent400,
      accent500: accent500 ?? this.accent500,
      accent600: accent600 ?? this.accent600,
      accent700: accent700 ?? this.accent700,
      accent800: accent800 ?? this.accent800,
      accent900: accent900 ?? this.accent900,
      accent1000: accent1000 ?? this.accent1000,
      accent1100: accent1100 ?? this.accent1100,
      accent1200: accent1200 ?? this.accent1200,
      gray50: gray50 ?? this.gray50,
      gray100: gray100 ?? this.gray100,
      gray200: gray200 ?? this.gray200,
      gray300: gray300 ?? this.gray300,
      gray400: gray400 ?? this.gray400,
      gray500: gray500 ?? this.gray500,
      gray600: gray600 ?? this.gray600,
      gray700: gray700 ?? this.gray700,
      gray800: gray800 ?? this.gray800,
      gray900: gray900 ?? this.gray900,
      gray1000: gray1000 ?? this.gray1000,
      gray1100: gray1100 ?? this.gray1100,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      accent100: Color.lerp(accent100, other.accent100, t)!,
      accent200: Color.lerp(accent200, other.accent200, t)!,
      accent300: Color.lerp(accent300, other.accent300, t)!,
      accent400: Color.lerp(accent400, other.accent400, t)!,
      accent500: Color.lerp(accent500, other.accent500, t)!,
      accent600: Color.lerp(accent600, other.accent600, t)!,
      accent700: Color.lerp(accent700, other.accent700, t)!,
      accent800: Color.lerp(accent800, other.accent800, t)!,
      accent900: Color.lerp(accent900, other.accent900, t)!,
      accent1000: Color.lerp(accent1000, other.accent1000, t)!,
      accent1100: Color.lerp(accent1100, other.accent1100, t)!,
      accent1200: Color.lerp(accent1200, other.accent1200, t)!,
      gray50: Color.lerp(gray50, other.gray50, t)!,
      gray100: Color.lerp(gray100, other.gray100, t)!,
      gray200: Color.lerp(gray200, other.gray200, t)!,
      gray300: Color.lerp(gray300, other.gray300, t)!,
      gray400: Color.lerp(gray400, other.gray400, t)!,
      gray500: Color.lerp(gray500, other.gray500, t)!,
      gray600: Color.lerp(gray600, other.gray600, t)!,
      gray700: Color.lerp(gray700, other.gray700, t)!,
      gray800: Color.lerp(gray800, other.gray800, t)!,
      gray900: Color.lerp(gray900, other.gray900, t)!,
      gray1000: Color.lerp(gray1000, other.gray1000, t)!,
      gray1100: Color.lerp(gray1100, other.gray1100, t)!,
    );
  }
}
