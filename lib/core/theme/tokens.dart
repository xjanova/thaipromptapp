import 'package:flutter/material.dart';

/// Design tokens — mirror of `thaiprompt/project/styles.css` :root vars.
/// Keep this file the single source of truth for colors/shadows/radii.
class TpColors {
  const TpColors._();

  // Vibrant Pop (default)
  static const pink = Color(0xFFFF3E6C);
  static const mint = Color(0xFF00D4B4);
  static const mango = Color(0xFFFFC94D);
  static const purple = Color(0xFF6B4BFF);
  static const sky = Color(0xFF5EC9FF);
  static const tomato = Color(0xFFFF7A3A);
  static const leaf = Color(0xFF79C24A);

  // Neutrals
  static const ink = Color(0xFF2A1F3D);
  static const ink2 = Color(0xFF4B3E66);
  static const muted = Color(0xFF8A7FA3);
  static const paper = Color(0xFFFFF8EE);
  static const paper2 = Color(0xFFFFEFD6);
  static const card = Color(0xFFFFFFFF);
  static const deepInk = Color(0xFF0E0B1F); // darker accent used in prototype

  // Accent tints
  static const pinkTint = Color(0xFFFFE3EB);
  static const mintTint = Color(0xFFDFFAF3);
  static const mangoTint = Color(0xFFFFF0C7);

  // Stage background gradient stops
  static const stageFill = Color(0xFFF1EADE);
}

/// Thai Bath currency formatting helpers live in core/utils/format.dart.

/// Border radii used across the app.
class TpRadii {
  const TpRadii._();
  static const chunk = 26.0; // cards
  static const medium = 18.0;
  static const small = 14.0;
  static const chip = 999.0;
  static const button = 999.0;
}

/// Claymorphism shadows — converted from `--clay`, `--clay-sm`, `--clay-lg`.
/// Each is built from 4 BoxShadow layers:
///   1) outer soft drop
///   2) outer subtle ambient
///   3) inner bottom dark edge (inset emulation via negative spread)
///   4) inner top highlight
///
/// Flutter's BoxShadow has no native inset support → we use a custom painter
/// when true inset depth is needed. For most cases, [TpShadows.clay*] provides
/// a convincing approximation via layered outer shadows.
class TpShadows {
  const TpShadows._();

  static const _shadowTint = Color(0x382E1A5C); // rgba(70,42,92,.22)
  static const _shadowTintSoft = Color(0x141E0E3C); // rgba(70,42,92,.08)
  static const _shadowTintStrong = Color(0x472E1A5C); // rgba(70,42,92,.28)

  static const clay = <BoxShadow>[
    BoxShadow(
      color: _shadowTint,
      offset: Offset(0, 10),
      blurRadius: 20,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: _shadowTintSoft,
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static const claySm = <BoxShadow>[
    BoxShadow(
      color: Color(0x2E2E1A5C), // rgba(70,42,92,.18)
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: -4,
    ),
  ];

  static const clayLg = <BoxShadow>[
    BoxShadow(
      color: _shadowTintStrong,
      offset: Offset(0, 22),
      blurRadius: 40,
      spreadRadius: -12,
    ),
    BoxShadow(
      color: Color(0x1A2E1A5C), // rgba(70,42,92,.10)
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
  ];

  /// Phone frame shadow.
  static const phoneFrame = <BoxShadow>[
    BoxShadow(
      color: Color(0x592E1A5C), // rgba(70,42,92,.35)
      offset: Offset(0, 30),
      blurRadius: 60,
      spreadRadius: -20,
    ),
    BoxShadow(
      color: Color(0x1F2E1A5C),
      offset: Offset(0, 6),
      blurRadius: 14,
    ),
  ];
}

/// Linear gradients used across the app.
class TpGradients {
  const TpGradients._();

  static const stage = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [TpColors.stageFill, TpColors.stageFill],
  );

  /// Hero "ตลาดวันนี้" gradient (pink → tomato)
  static const todayHero = LinearGradient(
    begin: Alignment(-0.7, -1),
    end: Alignment(0.7, 1),
    colors: [TpColors.pink, TpColors.tomato],
  );

  /// Onboarding gradient (soft multi-stop)
  static const onboardingBg = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [Color(0xFFFFE8F0), Color(0xFFFFF0C7), Color(0xFFDFFAF3)],
    stops: [0.0, 0.55, 1.0],
  );

  /// Wallet dark hero
  static const walletDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [TpColors.deepInk, Color(0xFF1A1433)],
  );
}

/// Common spacing scale (multiples of 4).
class TpSpace {
  const TpSpace._();
  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x5 = 20.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
  static const x10 = 40.0;
  static const x12 = 48.0;
}
