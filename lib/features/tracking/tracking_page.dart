import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/models/commerce.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puffy_button.dart';
import 'tracking_repository.dart';

/// Port of `Tracking` in screens-b.jsx.
class TrackingPage extends ConsumerWidget {
  const TrackingPage({super.key, required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(trackingProvider(orderId));

    return Scaffold(
      backgroundColor: TpColors.paper,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: TpColors.pink)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('โหลดสถานะไม่ได้: $e', style: TpText.bodyMd),
          ),
        ),
        data: (tracking) => _Body(tracking: tracking, orderId: orderId),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.tracking, required this.orderId});
  final Tracking tracking;
  final int orderId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _MapHero(eta: tracking.etaMinutes),
        const SizedBox(height: 14),
        if (tracking.rider != null) _RiderCard(rider: tracking.rider!, orderId: orderId),
        const SizedBox(height: 14),
        _Timeline(steps: tracking.steps, orderRef: tracking.orderRef),
        const SizedBox(height: 30),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Map hero (stylized — not a real map; phase 4 swaps in flutter_map)
// ---------------------------------------------------------------------------

class _MapHero extends StatelessWidget {
  const _MapHero({required this.eta});
  final int? eta;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFDFFAF3), Color(0xFFFFE3EB)],
                ),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _MapPainter())),

          // Rider
          Positioned(
            left: MediaQuery.of(context).size.width * 0.42,
            top: 100,
            child: _RiderDot()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -6, duration: 3000.ms, curve: Curves.easeInOut),
          ),

          // Destination pin
          Positioned(
            right: MediaQuery.of(context).size.width * 0.10,
            top: 50,
            child: const _DestinationPin(),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TopBtn(icon: Icons.arrow_back_rounded, onTap: () => context.pop()),
                  if (eta != null)
                    ClayCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: TpColors.mango,
                      shadow: ClayShadow.small,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PulseDot(),
                          const SizedBox(width: 6),
                          Text('ถึงใน $eta นาที', style: TpText.titleMd.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    // Road
    final roadPath = Path()
      ..moveTo(-10, 200)
      ..quadraticBezierTo(80, 140, 180, 160)
      ..quadraticBezierTo(280, 180, 380, 100);
    final roadShadow = Paint()
      ..color = TpColors.deepInk.withValues(alpha: 0.08)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;
    canvas.drawPath(roadPath, roadShadow);
    final roadFill = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;
    canvas.drawPath(roadPath, roadFill);

    final dashPaint = Paint()
      ..color = TpColors.deepInk
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // crude dashed emulation
    final metrics = roadPath.computeMetrics();
    for (final m in metrics) {
      double d = 0;
      while (d < m.length) {
        final segment = m.extractPath(d, (d + 8).clamp(0, m.length));
        canvas.drawPath(segment, dashPaint);
        d += 14;
      }
    }

    // Building blocks
    const blocks = [
      (30.0, 80.0, Color(0xFFFFC94D)),
      (70.0, 60.0, Color(0xFFFF3E6C)),
      (240.0, 50.0, Color(0xFF6B4BFF)),
      (290.0, 80.0, Color(0xFF00D4B4)),
      (60.0, 220.0, Color(0xFFFF7A3A)),
      (260.0, 220.0, Color(0xFFFFC94D)),
    ];
    for (final b in blocks) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(b.$1, b.$2, 28, 28),
        const Radius.circular(5),
      );
      final fill = Paint()..color = b.$3;
      final stroke = Paint()
        ..color = TpColors.deepInk
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rect, fill);
      canvas.drawRRect(rect, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => false;
}

class _RiderDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: TpColors.pink.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (c) => c.repeat()).scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.4, 1.4),
                duration: 1600.ms,
              ).fadeOut(duration: 1600.ms),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TpColors.pink,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text('🛵', style: TextStyle(fontSize: 22)),
          ),
        ],
      ),
    );
  }
}

class _DestinationPin extends StatelessWidget {
  const _DestinationPin();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.785, // -45 deg
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: TpColors.deepInk,
          border: Border.all(color: TpColors.mango, width: 3),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
        ),
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: 0.785,
          child: const Icon(Icons.home_rounded, color: TpColors.mango, size: 20),
        ),
      ),
    );
  }
}

class _TopBtn extends StatelessWidget {
  const _TopBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: TpColors.paper,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              offset: const Offset(0, 4),
              blurRadius: 8,
              spreadRadius: -2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: TpColors.ink),
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: TpColors.pink,
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (c) => c.repeat()).fadeOut(duration: 1400.ms).scale(
          begin: const Offset(1, 1),
          end: const Offset(2, 2),
          duration: 1400.ms,
        );
  }
}

// ---------------------------------------------------------------------------
// Rider card
// ---------------------------------------------------------------------------

class _RiderCard extends StatelessWidget {
  const _RiderCard({required this.rider, required this.orderId});
  final Rider rider;
  final int orderId;

  @override
  Widget build(BuildContext context) {
    final initial = rider.name.isEmpty ? '?' : rider.name.characters.first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClayCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: TpColors.purple,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(initial,
                  style: TpText.display4.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${rider.name} · ${rider.role}',
                      style: TpText.titleMd.copyWith(fontSize: 13)),
                  Text(
                    [
                      if (rider.rating != null) '★ ${rider.rating!.toStringAsFixed(1)}',
                      if (rider.vehicle != null) rider.vehicle!,
                      if (rider.plate != null) rider.plate!,
                    ].join(' · '),
                    style: TpText.monoLabel,
                  ),
                ],
              ),
            ),
            PuffyButton(
              label: '📞',
              variant: PuffyVariant.ghost,
              size: PuffySize.small,
              onPressed: () {},
            ),
            const SizedBox(width: 6),
            PuffyButton(
              label: '💬',
              variant: PuffyVariant.pink,
              size: PuffySize.small,
              onPressed: () => context.go('/orders/$orderId/chat'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline
// ---------------------------------------------------------------------------

class _Timeline extends StatelessWidget {
  const _Timeline({required this.steps, required this.orderRef});
  final List<TrackingStep> steps;
  final String orderRef;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClayCard(
        padding: const EdgeInsets.all(14),
        color: TpColors.mangoTint,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ORDER #$orderRef · สถานะ', style: TpText.monoLabel),
            const SizedBox(height: 10),
            for (var i = 0; i < steps.length; i++)
              _StepRow(
                index: i,
                step: steps[i],
                isLast: i == steps.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.step, required this.isLast});
  final int index;
  final TrackingStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final bg = step.done
        ? TpColors.mint
        : step.active
            ? TpColors.pink
            : Colors.white;
    final fg = step.done || step.active ? Colors.white : TpColors.muted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              if (!isLast)
                Positioned(
                  top: 28,
                  child: Container(
                    width: 2,
                    height: 24,
                    color: step.done ? TpColors.mint : TpColors.ink.withValues(alpha: 0.15),
                  ),
                ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  boxShadow: step.active
                      ? [
                          BoxShadow(
                            color: TpColors.pink.withValues(alpha: 0.3),
                            spreadRadius: 4,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  step.done ? '✓' : '${index + 1}',
                  style: TpText.titleMd.copyWith(
                    fontSize: 13,
                    color: fg,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                step.label,
                style: TpText.titleMd.copyWith(
                  fontSize: 13,
                  fontWeight: step.active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
          if (step.timeText != null)
            Text(step.timeText!, style: TpText.monoTag.copyWith(fontSize: 11, color: TpColors.muted)),
        ],
      ),
    );
  }
}
