import 'package:flutter/material.dart';

/// Floor shadow ellipse — used below hero products.
/// Port of `FloorShadow` from blobs.jsx.
class FloorShadow extends StatelessWidget {
  const FloorShadow({super.key, this.width = 160});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width),
        gradient: RadialGradient(
          colors: [
            Colors.black.withValues(alpha: 0.35),
            Colors.black.withValues(alpha: 0),
          ],
          stops: const [0, 0.65],
        ),
      ),
    );
  }
}
