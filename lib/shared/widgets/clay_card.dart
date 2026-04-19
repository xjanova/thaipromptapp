import 'package:flutter/material.dart';

import '../../core/theme/clay_theme.dart';
import '../../core/theme/tokens.dart';

/// The "chunk" primitive from the prototype — a card with soft clay shadow.
/// Matches `.chunk` in `thaiprompt/project/styles.css`.
class ClayCard extends StatelessWidget {
  const ClayCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin = EdgeInsets.zero,
    this.color = TpColors.card,
    this.radius = TpRadii.chunk,
    this.shadow = ClayShadow.regular,
    this.onTap,
    this.clipChildren = false,
    this.gradient,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color color;
  final double radius;
  final ClayShadow shadow;
  final VoidCallback? onTap;
  final bool clipChildren;
  final Gradient? gradient;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final clay = Theme.of(context).extension<ClayTheme>()!;
    final shadows = switch (shadow) {
      ClayShadow.none => const <BoxShadow>[],
      ClayShadow.small => clay.claySm,
      ClayShadow.regular => clay.clay,
      ClayShadow.large => clay.clayLg,
    };

    final decoration = BoxDecoration(
      color: gradient == null ? color : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadows,
      border: border,
    );

    Widget body = DecoratedBox(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (onTap != null) {
      body = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: body,
        ),
      );
    }

    if (margin == EdgeInsets.zero) return body;
    return Padding(padding: margin, child: body);
  }
}

enum ClayShadow { none, small, regular, large }
