import 'package:flutter/material.dart';

import '../../core/theme/clay_theme.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';

/// The `.btn` primitive — pill-shaped button with claymorphic shadow.
/// Matches the `btn`, `btn.pink`, `btn.mint`, `btn.mango`, `btn.purple`,
/// `btn.ghost` variants from styles.css.
class PuffyButton extends StatefulWidget {
  const PuffyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = PuffyVariant.ink,
    this.size = PuffySize.medium,
    this.fullWidth = false,
    this.trailing,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PuffyVariant variant;
  final PuffySize size;
  final bool fullWidth;
  final Widget? trailing;

  @override
  State<PuffyButton> createState() => _PuffyButtonState();
}

class _PuffyButtonState extends State<PuffyButton> {
  bool _pressed = false;

  (Color bg, Color fg) _colors() => switch (widget.variant) {
        PuffyVariant.ink => (TpColors.deepInk, Colors.white),
        PuffyVariant.pink => (TpColors.pink, Colors.white),
        PuffyVariant.mint => (TpColors.mint, TpColors.ink),
        PuffyVariant.mango => (TpColors.mango, TpColors.ink),
        PuffyVariant.purple => (TpColors.purple, Colors.white),
        PuffyVariant.ghost => (TpColors.card, TpColors.ink),
      };

  EdgeInsets _padding() => switch (widget.size) {
        PuffySize.small => const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        PuffySize.medium => const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        PuffySize.large => const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      };

  TextStyle _textStyle() {
    return widget.size == PuffySize.small ? TpText.btnSm : TpText.btn;
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors();
    final clay = Theme.of(context).extension<ClayTheme>()!;
    final disabled = widget.onPressed == null;

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          transform: _pressed
              ? (Matrix4.identity()..translate(0.0, 1.0))
              : Matrix4.identity(),
          width: widget.fullWidth ? double.infinity : null,
          padding: _padding(),
          decoration: BoxDecoration(
            color: disabled ? bg.withValues(alpha: 0.5) : bg,
            borderRadius: BorderRadius.circular(TpRadii.button),
            boxShadow: _pressed ? const [] : clay.claySm,
          ),
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: fg),
                const SizedBox(width: 6),
              ],
              Text(widget.label, style: _textStyle().copyWith(color: fg)),
              if (widget.trailing != null) ...[
                const SizedBox(width: 6),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum PuffyVariant { ink, pink, mint, mango, purple, ghost }

enum PuffySize { small, medium, large }
