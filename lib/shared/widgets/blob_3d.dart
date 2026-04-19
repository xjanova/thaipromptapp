import 'package:flutter/material.dart';

/// Puffy 3D blob — a radial-gradient sphere with an inner shine highlight.
/// Direct Dart port of `Blob3D` from `thaiprompt/project/blobs.jsx`.
class Blob3D extends StatelessWidget {
  const Blob3D({
    super.key,
    this.size = 120,
    this.hue = BlobHue.pink,
    this.shine = true,
  });

  final double size;
  final BlobHue hue;
  final bool shine;

  _Palette get _palette => switch (hue) {
        BlobHue.pink =>
          const _Palette(Color(0xFFFFDCE6), Color(0xFFFF3E6C), Color(0xFF8A0030)),
        BlobHue.mint =>
          const _Palette(Color(0xFFE3FFF8), Color(0xFF00D4B4), Color(0xFF006B5A)),
        BlobHue.mango =>
          const _Palette(Color(0xFFFFF3C7), Color(0xFFFFC94D), Color(0xFF7A5200)),
        BlobHue.purple =>
          const _Palette(Color(0xFFEAE3FF), Color(0xFF6B4BFF), Color(0xFF2C1D8A)),
        BlobHue.sky =>
          const _Palette(Color(0xFFE0F3FF), Color(0xFF5EC9FF), Color(0xFF0A5A85)),
        BlobHue.tomato =>
          const _Palette(Color(0xFFFFE3D6), Color(0xFFFF7A3A), Color(0xFF8A2A00)),
        BlobHue.leaf =>
          const _Palette(Color(0xFFE5F8D5), Color(0xFF79C24A), Color(0xFF2E5A12)),
      };

  @override
  Widget build(BuildContext context) {
    final p = _palette;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.36, -0.44), // 32%,28%
                  radius: 0.85,
                  colors: [p.light, p.main, p.dark],
                  stops: const [0, 0.42, 1],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    offset: Offset(-size * 0.12, -size * 0.14),
                    blurRadius: size * 0.2,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    offset: Offset(0, size * 0.18),
                    blurRadius: size * 0.14,
                    spreadRadius: -size * 0.1,
                  ),
                ],
              ),
            ),
          ),
          if (shine)
            Positioned(
              top: size * 0.12,
              left: size * 0.18,
              width: size * 0.32,
              height: size * 0.20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(size),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum BlobHue { pink, mint, mango, purple, sky, tomato, leaf }

class _Palette {
  const _Palette(this.light, this.main, this.dark);
  final Color light;
  final Color main;
  final Color dark;
}
