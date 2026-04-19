import 'package:flutter/material.dart';

import '../../core/theme/clay_theme.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';

/// Small pill — matches `.chip` in styles.css.
class TpChip extends StatelessWidget {
  const TpChip({
    super.key,
    required this.label,
    this.color = TpColors.card,
    this.textColor,
    this.icon,
    this.small = false,
  });

  final String label;
  final Color color;
  final Color? textColor;
  final Widget? icon;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final clay = Theme.of(context).extension<ClayTheme>()!;
    final pad = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    final style = small
        ? TpText.bodyXs.copyWith(fontWeight: FontWeight.w600, color: textColor ?? TpColors.ink)
        : TpText.bodySm.copyWith(fontWeight: FontWeight.w600, color: textColor ?? TpColors.ink);
    return Container(
      padding: pad,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(TpRadii.chip),
        boxShadow: clay.claySm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 6)],
          Text(label, style: style),
        ],
      ),
    );
  }
}
