import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import 'clay_card.dart';

/// Placeholder page for screens that are scaffolded but not yet built.
///
/// Shows the screen title + a "ยังไม่เปิดใช้งาน" illustration + a subtitle
/// describing what this screen will do. Used during the v1.0.22 scaffold
/// phase where all routes are wired but only a few have real UI.
///
/// Replace with the real page as each screen ships.
class UnderConstructionPage extends StatelessWidget {
  const UnderConstructionPage({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.construction_rounded,
    this.background,
    this.onDark = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color? background;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final bg = background ?? (onDark ? TpColors.deepInk : TpColors.paper);
    final titleColor = onDark ? Colors.white : TpColors.ink;
    final subColor = onDark ? Colors.white70 : TpColors.muted;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ClayCard(
              padding: const EdgeInsets.all(24),
              color: onDark ? const Color(0xFF1A1433) : Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: TpColors.mangoTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 32, color: TpColors.tomato),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Thai',
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Thai',
                      fontSize: 12,
                      color: subColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: TpColors.mango,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'COMING SOON',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        letterSpacing: 1.5,
                        color: TpColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
