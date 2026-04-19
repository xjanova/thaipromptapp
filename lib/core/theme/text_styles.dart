import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Typography tokens for Thaiprompt.
///
/// Fonts (loaded via `google_fonts` at runtime):
/// - Display:  Space Grotesk  (headlines, big numbers)
/// - Body:     IBM Plex Sans Thai (all Thai UI text)
/// - Mono:     JetBrains Mono (tags, codes, labels)
class TpText {
  const TpText._();

  static TextStyle _display({
    required double size,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double height = 1.1,
    double letterSpacing = -0.4,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        color: color ?? TpColors.ink,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle _body({
    required double size,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double height = 1.5,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.ibmPlexSansThai(
        fontSize: size,
        fontWeight: weight,
        color: color ?? TpColors.ink,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle _mono({
    required double size,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double letterSpacing = 1.5,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color ?? TpColors.muted,
        letterSpacing: letterSpacing,
      );

  // Display scale
  static final display1 = _display(size: 40, weight: FontWeight.w900, letterSpacing: -1.0);
  static final display2 = _display(size: 30, weight: FontWeight.w900, letterSpacing: -0.9);
  static final display3 = _display(size: 24, weight: FontWeight.w800);
  static final display4 = _display(size: 20, weight: FontWeight.w700);
  static final bigNum = _display(size: 22, weight: FontWeight.w800);

  // Body scale
  static final bodyLg = _body(size: 16, weight: FontWeight.w500);
  static final bodyMd = _body(size: 14, weight: FontWeight.w500);
  static final bodySm = _body(size: 13, weight: FontWeight.w500);
  static final bodyXs = _body(size: 11, weight: FontWeight.w500);

  static final titleLg = _body(size: 17, weight: FontWeight.w800);
  static final titleMd = _body(size: 14, weight: FontWeight.w700);
  static final titleSm = _body(size: 12, weight: FontWeight.w700);

  // Mono scale (labels/tags)
  static final monoLabel = _mono(size: 10);
  static final monoLabelSm = _mono(size: 9);
  static final monoTag = _mono(size: 11, weight: FontWeight.w700);

  // Buttons
  static final btn = _body(size: 14, weight: FontWeight.w700, height: 1);
  static final btnSm = _body(size: 12, weight: FontWeight.w700, height: 1);

  // Greeting ("สวัสดี, สมพร")
  static final greet = _body(size: 14, weight: FontWeight.w700);
}
