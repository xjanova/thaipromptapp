import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Puffy coin — "฿" by default. Used across Wallet & Affiliate hooks.
class Coin extends StatelessWidget {
  const Coin({super.key, this.size = 44, this.label = '฿'});

  final double size;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.36, -0.44),
                radius: 0.85,
                colors: [
                  Color(0xFFFFF3C7),
                  Color(0xFFFFC94D),
                  Color(0xFF7A5200),
                ],
                stops: [0, 0.5, 1],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  offset: const Offset(-3, -5),
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(0, 6),
                  blurRadius: 6,
                  spreadRadius: -3,
                ),
              ],
            ),
          ),
          // dashed inner ring
          Container(
            width: size * 0.88,
            height: size * 0.88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF5A3A00),
              fontWeight: FontWeight.w900,
              fontSize: size * 0.45,
            ),
          ),
        ],
      ),
    );
  }
}
