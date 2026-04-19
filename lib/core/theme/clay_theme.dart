import 'package:flutter/material.dart';

import 'text_styles.dart';
import 'tokens.dart';

/// Theme extension exposing clay-specific tokens at runtime.
/// Access via `Theme.of(context).extension<ClayTheme>()!`.
@immutable
class ClayTheme extends ThemeExtension<ClayTheme> {
  const ClayTheme({
    required this.clay,
    required this.claySm,
    required this.clayLg,
    required this.chunkRadius,
  });

  final List<BoxShadow> clay;
  final List<BoxShadow> claySm;
  final List<BoxShadow> clayLg;
  final double chunkRadius;

  @override
  ClayTheme copyWith({
    List<BoxShadow>? clay,
    List<BoxShadow>? claySm,
    List<BoxShadow>? clayLg,
    double? chunkRadius,
  }) =>
      ClayTheme(
        clay: clay ?? this.clay,
        claySm: claySm ?? this.claySm,
        clayLg: clayLg ?? this.clayLg,
        chunkRadius: chunkRadius ?? this.chunkRadius,
      );

  @override
  ClayTheme lerp(ThemeExtension<ClayTheme>? other, double t) {
    if (other is! ClayTheme) return this;
    return this;
  }
}

ThemeData buildThaipromptTheme() {
  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: TpColors.pink,
    onPrimary: Colors.white,
    secondary: TpColors.mint,
    onSecondary: TpColors.ink,
    tertiary: TpColors.mango,
    onTertiary: TpColors.ink,
    error: const Color(0xFFD92D2D),
    onError: Colors.white,
    surface: TpColors.card,
    onSurface: TpColors.ink,
    surfaceContainerHighest: TpColors.paper,
    outline: Colors.transparent,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: TpColors.paper,
    fontFamily: TpText.bodyMd.fontFamily,
    textTheme: TextTheme(
      displayLarge: TpText.display1,
      displayMedium: TpText.display2,
      displaySmall: TpText.display3,
      headlineMedium: TpText.display4,
      titleLarge: TpText.titleLg,
      titleMedium: TpText.titleMd,
      titleSmall: TpText.titleSm,
      bodyLarge: TpText.bodyLg,
      bodyMedium: TpText.bodyMd,
      bodySmall: TpText.bodySm,
      labelLarge: TpText.btn,
      labelMedium: TpText.monoLabel,
    ),
    splashFactory: InkSparkle.splashFactory,
    extensions: const [
      ClayTheme(
        clay: TpShadows.clay,
        claySm: TpShadows.claySm,
        clayLg: TpShadows.clayLg,
        chunkRadius: TpRadii.chunk,
      ),
    ],
    iconTheme: const IconThemeData(color: TpColors.ink),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TpColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TpRadii.medium),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: TpText.bodyMd.copyWith(color: TpColors.muted),
    ),
  );
}
