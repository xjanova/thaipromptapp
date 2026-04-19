import 'package:flutter/material.dart';

/// Horizontally auto-scrolling row — port of `.marquee` from styles.css.
/// Duplicates [children] internally to achieve a seamless loop.
class Marquee extends StatefulWidget {
  const Marquee({
    super.key,
    required this.children,
    this.duration = const Duration(seconds: 28),
    this.gap = 20,
  });

  final List<Widget> children;
  final Duration duration;
  final double gap;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(_tick)
      ..repeat();
  }

  void _tick() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max == 0) return;
    final target = _ctrl.value * (max / 2); // full loop at value=1; list is doubled
    _scroll.jumpTo(target);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final looped = [...widget.children, ...widget.children];
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
        stops: [0, 0.06, 0.94, 1],
      ).createShader(rect),
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: looped.length,
        separatorBuilder: (_, __) => SizedBox(width: widget.gap),
        itemBuilder: (_, i) => looped[i],
      ),
    );
  }
}
