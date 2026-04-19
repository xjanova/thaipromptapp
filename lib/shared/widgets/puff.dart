import 'package:flutter/material.dart';

import '../../core/theme/text_styles.dart';
import 'blob_3d.dart';

/// Stylized puffy capsule used to represent products in the prototype.
/// Port of the `Puff` component in blobs.jsx.
class Puff extends StatelessWidget {
  const Puff({
    super.key,
    this.width = 140,
    this.height = 110,
    this.hue = BlobHue.pink,
    this.label,
  });

  final double width;
  final double height;
  final BlobHue hue;
  final String? label;

  _PuffPalette get _palette => switch (hue) {
        BlobHue.pink =>
          const _PuffPalette(Color(0xFFFFDCE6), Color(0xFFFF3E6C), Color(0xFF8A0030)),
        BlobHue.mint =>
          const _PuffPalette(Color(0xFFE3FFF8), Color(0xFF00D4B4), Color(0xFF006B5A)),
        BlobHue.mango =>
          const _PuffPalette(Color(0xFFFFF3C7), Color(0xFFFFC94D), Color(0xFF7A5200)),
        BlobHue.purple =>
          const _PuffPalette(Color(0xFFEAE3FF), Color(0xFF6B4BFF), Color(0xFF2C1D8A)),
        BlobHue.tomato =>
          const _PuffPalette(Color(0xFFFFE3D6), Color(0xFFFF7A3A), Color(0xFF8A2A00)),
        BlobHue.leaf =>
          const _PuffPalette(Color(0xFFE5F8D5), Color(0xFF79C24A), Color(0xFF2E5A12)),
        BlobHue.sky =>
          const _PuffPalette(Color(0xFFE0F3FF), Color(0xFF5EC9FF), Color(0xFF0A5A85)),
      };

  @override
  Widget build(BuildContext context) {
    final p = _palette;
    final radiusX = width / 2;
    final radiusY = height * 0.45;
    return SizedBox(
      width: width,
      height: height + (label != null ? 20 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.elliptical(radiusX, radiusY),
                ),
                gradient: RadialGradient(
                  center: const Alignment(-0.4, -0.5), // 30%,25%
                  radius: 0.9,
                  colors: [p.light, p.main, p.dark],
                  stops: const [0, 0.5, 1],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    offset: const Offset(-10, -14),
                    blurRadius: 20,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, 16),
                    blurRadius: 10,
                    spreadRadius: -6,
                  ),
                ],
              ),
            ),
          ),
          // shine highlight
          Positioned(
            top: height * 0.12,
            left: width * 0.20,
            width: width * 0.30,
            height: height * 0.22,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          if (label != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Text(
                label!,
                textAlign: TextAlign.center,
                style: TpText.monoLabel,
              ),
            ),
        ],
      ),
    );
  }
}

class _PuffPalette {
  const _PuffPalette(this.light, this.main, this.dark);
  final Color light;
  final Color main;
  final Color dark;
}
