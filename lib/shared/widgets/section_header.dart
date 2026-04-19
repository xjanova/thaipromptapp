import 'package:flutter/material.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';

/// Section header with Thai title + optional English subtitle + optional trailing action.
/// Port of `H` in phone.jsx.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.titleTh,
    this.titleEn,
    this.action,
    this.onActionTap,
    this.padding = const EdgeInsets.fromLTRB(16, 18, 16, 10),
  });

  final String titleTh;
  final String? titleEn;
  final String? action;
  final VoidCallback? onActionTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(titleTh, style: TpText.display4),
                if (titleEn != null) ...[
                  const SizedBox(height: 2),
                  Text(titleEn!.toUpperCase(), style: TpText.monoLabel),
                ],
              ],
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                '$action →',
                style: TpText.bodySm.copyWith(
                  color: TpColors.pink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
