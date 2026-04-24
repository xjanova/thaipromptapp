import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puffy_button.dart';
import '../../shared/widgets/section_header.dart';

/// Rider feature pages — all real UI on dark (deepInk) background per
/// `design_handoff_thaiprompt_marketplace/rider-app.jsx`.

// ═══════════════════════════════════════════════════════════════════════
// R1 · Dashboard · mini-map + active job + upcoming queue
// ═══════════════════════════════════════════════════════════════════════

class RiderDashboardPage extends StatelessWidget {
  const RiderDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const _RiderMap(),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _RiderStat(
                  label: 'วันนี้',
                  value: '฿840',
                  color: TpColors.mango,
                  onTap: () => context.go('/rider/earnings'),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _RiderStat(
                  label: 'เที่ยว',
                  value: '14',
                  color: TpColors.pink,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _RiderStat(
                  label: 'ชม.',
                  value: '6.5h',
                  color: TpColors.mint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _ActiveJobCard(onTap: () => context.go('/rider/jobs/TP-2041')),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'คิวงานถัดไป',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Thai',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/rider/jobs'),
                child: const Text(
                  'ดูทั้งหมด →',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: TpColors.mango,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final j in _upcomingJobs) ...[
                _JobRow(
                  job: j,
                  onTap: () => context.go('/rider/jobs/${j.id}'),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static const _upcomingJobs = <_JobStub>[
    _JobStub(id: 'TP-2042', distance: '0.8km', route: 'ครัวยายปราณี → สุขุมวิท 40', pay: 85, eta: 12),
    _JobStub(id: 'TP-2043', distance: '1.4km', route: 'น้องฟ้า → อโศก', pay: 70, eta: 18),
  ];
}

class _RiderMap extends StatelessWidget {
  const _RiderMap();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [TpColors.ink2, TpColors.ink],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _RouteMapPainter()),
          ),
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusChip(label: 'ออนไลน์', pulse: true),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    '9.8 km · ฿180',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, this.pulse = false});
  final String label;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: TpColors.mint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Thai',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Route painter — draws dashed curve + 3 waypoints (A pink, B mango, C mint).
class _RouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dashed route path
    final path = Path()
      ..moveTo(-10, 150)
      ..quadraticBezierTo(100, 80, 200 * size.width / 360, 120)
      ..quadraticBezierTo(280 * size.width / 360, 140, size.width + 20, 60);

    final dashPaint = Paint()
      ..color = TpColors.mango.withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final metric = path.computeMetrics().first;
    double distance = 0;
    while (distance < metric.length) {
      final seg = metric.extractPath(distance, distance + dashWidth);
      canvas.drawPath(seg, dashPaint);
      distance += dashWidth + dashSpace;
    }

    // Waypoints
    const waypoints = [
      ('A', 60.0, 150.0, TpColors.pink),
      ('B', 180.0, 120.0, TpColors.mango),
      ('C', 300.0, 60.0, TpColors.mint),
    ];
    for (final w in waypoints) {
      final cx = w.$2 * size.width / 360;
      final cy = w.$3;
      canvas.drawCircle(Offset(cx, cy), 14, Paint()..color = w.$4);
      canvas.drawCircle(
        Offset(cx, cy),
        14,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: w.$1,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Thai',
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: TpColors.ink,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter old) => false;
}

class _RiderStat extends StatelessWidget {
  const _RiderStat({
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 9,
                  color: Color(0xB3FFFFFF),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  const _ActiveJobCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [TpColors.mango, TpColors.tomato],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'JOB #TP-2041 · เร่งด่วน',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: Color(0xB32A1F3D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '⏱ 8:32',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Thai',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: TpColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _StopRow(letter: 'A', label: 'รับของที่ ครัวยายปราณี', addr: 'สุขุมวิท 24', color: TpColors.pink, done: true),
          const SizedBox(height: 8),
          const _StopRow(letter: 'B', label: 'ส่งที่ คุณสมพร', addr: 'สุขุมวิท 36 · 1.2km', color: TpColors.mint),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PuffyButton(
                  label: '🧭 นำทาง',
                  variant: PuffyVariant.ink,
                  fullWidth: true,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              PuffyButton(
                label: '✓ ส่งสำเร็จ',
                variant: PuffyVariant.pink,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.letter,
    required this.label,
    required this.addr,
    required this.color,
    this.done = false,
  });

  final String letter;
  final String label;
  final String addr;
  final Color color;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: TpShadows.claySm,
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Thai',
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label${done ? ' ✓' : ''}',
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Thai',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: TpColors.ink,
                ),
              ),
              Text(
                addr,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  color: Color(0xB32A1F3D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JobStub {
  const _JobStub({
    required this.id,
    required this.distance,
    required this.route,
    required this.pay,
    required this.eta,
    this.tag,
  });
  final String id;
  final String distance;
  final String route;
  final int pay;
  final int eta;
  final String? tag;
}

class _JobRow extends StatelessWidget {
  const _JobRow({required this.job, required this.onTap});
  final _JobStub job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [TpColors.purple, TpColors.ink],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: TpShadows.claySm,
                ),
                alignment: Alignment.center,
                child: Text(
                  job.distance,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.route,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Thai',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '~${job.eta} นาที${job.tag != null ? ' · ${job.tag}' : ''}',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        color: Color(0x99FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '฿${job.pay}',
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: TpColors.mango,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// R2 · Jobs queue
// ═══════════════════════════════════════════════════════════════════════

class RiderJobsPage extends StatefulWidget {
  const RiderJobsPage({super.key});
  @override
  State<RiderJobsPage> createState() => _RiderJobsPageState();
}

class _RiderJobsPageState extends State<RiderJobsPage> {
  int _tab = 0;
  static const _tabs = ['ทั้งหมด', 'ใกล้สุด', 'ราคาสูง'];
  static const _jobs = <_JobStub>[
    _JobStub(id: 'TP-2042', distance: '0.8km', route: 'ครัวยายปราณี → สุขุมวิท 40', pay: 85, eta: 12, tag: 'ใกล้'),
    _JobStub(id: 'TP-2043', distance: '1.4km', route: 'น้องฟ้า ขนมไทย → อโศก', pay: 70, eta: 18),
    _JobStub(id: 'TP-2044', distance: '2.1km', route: 'ลุงโต ก๋วยเตี๋ยว → เพลินจิต', pay: 95, eta: 24, tag: '💰'),
    _JobStub(id: 'TP-2045', distance: '3.0km', route: 'ป้าสม → ทองหล่อ', pay: 110, eta: 30),
    _JobStub(id: 'TP-2046', distance: '0.5km', route: 'ร้านแดง → สีลม', pay: 60, eta: 10, tag: 'ใกล้'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const _RiderHeader(title: 'คิวงานทั้งหมด', sub: 'JOBS QUEUE'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _tab == i ? TpColors.mango : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _tabs[i],
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Thai',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _tab == i ? TpColors.ink : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final j in _jobs) ...[
                _JobRow(job: j, onTap: () => context.go('/rider/jobs/${j.id}')),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RiderHeader extends StatelessWidget {
  const _RiderHeader({required this.title, required this.sub, this.showBack = false});
  final String title;
  final String sub;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          if (showBack) ...[
            Material(
              color: Colors.white.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.pop(),
                child: const SizedBox(
                  width: 34,
                  height: 34,
                  child: Icon(Icons.arrow_back_rounded, size: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub,
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 9,
                    letterSpacing: 1.8,
                    color: Color(0x99FFFFFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// R3 · Job detail
// ═══════════════════════════════════════════════════════════════════════

class RiderJobDetailPage extends StatelessWidget {
  const RiderJobDetailPage({super.key, required this.jobId});
  final int jobId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.deepInk,
      body: SafeArea(
        child: Column(
          children: [
            _RiderHeader(title: '#$jobId', sub: 'JOB DETAIL', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [TpColors.mango, TpColors.tomato],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'รายได้',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: Color(0xB32A1F3D),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '฿85',
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: TpColors.ink,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(width: 8),
                            Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text(
                                '+ ทิป ฿10 (ลูกค้า VIP)',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Thai',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: TpColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'ระยะทาง 2.1km · เวลาเฉลี่ย 18 นาที',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Thai',
                            fontSize: 11,
                            color: TpColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _PickupDropoffCard(
                    tag: 'จุดรับของ · PICKUP',
                    name: 'ครัวยายปราณี',
                    addr: 'ซ.สุขุมวิท 24 เลขที่ 48/12',
                    meta: '120m · 2 นาที',
                    accent: TpColors.pink,
                  ),
                  const SizedBox(height: 10),
                  const _PickupDropoffCard(
                    tag: 'จุดส่ง · DROPOFF',
                    name: 'คุณสมพร (สมพร จันทร์เพ็ญ)',
                    addr: 'ซ.สุขุมวิท 40 เลขที่ 224',
                    meta: '1.2km · 5 นาที',
                    accent: TpColors.mint,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      PuffyButton(
                        label: 'ปฏิเสธ',
                        variant: PuffyVariant.ghost,
                        onPressed: () => context.go('/rider/jobs'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PuffyButton(
                          label: 'รับงานนี้ · ฿85',
                          variant: PuffyVariant.ink,
                          fullWidth: true,
                          size: PuffySize.large,
                          onPressed: () => context.go('/rider'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupDropoffCard extends StatelessWidget {
  const _PickupDropoffCard({
    required this.tag,
    required this.name,
    required this.addr,
    required this.meta,
    required this.accent,
  });
  final String tag;
  final String name;
  final String addr;
  final String meta;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 9,
              letterSpacing: 1.5,
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Thai',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            addr,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Thai',
              fontSize: 12,
              color: Color(0xD9FFFFFF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            meta,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              color: Color(0x99FFFFFF),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SmallActionButton(label: '📞 โทร', onTap: () {}),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SmallActionButton(label: '🧭 นำทาง', onTap: () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Thai',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// R4 · Earnings
// ═══════════════════════════════════════════════════════════════════════

class RiderEarningsPage extends StatelessWidget {
  const RiderEarningsPage({super.key});

  static const _weekBars = [180, 240, 120, 320, 280, 420, 380];
  static const _history = <_TripHistory>[
    _TripHistory(id: 'TP-2041', route: 'สุขุมวิท 24 → 40', pay: 95, when: 'เมื่อกี้'),
    _TripHistory(id: 'TP-2039', route: 'อโศก → ทองหล่อ', pay: 110, when: 'เช้านี้'),
    _TripHistory(id: 'TP-2036', route: 'สีลม → สาทร', pay: 75, when: 'เมื่อวาน'),
  ];

  @override
  Widget build(BuildContext context) {
    final maxBar = _weekBars.reduce((a, b) => a > b ? a : b);
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const _RiderHeader(title: 'รายได้ของฉัน', sub: 'EARNINGS'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [TpColors.pink, TpColors.mango],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'สัปดาห์นี้',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: Color(0xBF2A1F3D),
                  ),
                ),
                const Text(
                  '฿1,940',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: TpColors.ink,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ขึ้น 24% จากสัปดาห์ที่แล้ว',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: TpColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < _weekBars.length; i++) ...[
                        if (i > 0) const SizedBox(width: 5),
                        Expanded(
                          child: FractionallySizedBox(
                            heightFactor: _weekBars[i] / maxBar,
                            child: Container(
                              decoration: BoxDecoration(
                                color: i == 5 ? TpColors.ink : TpColors.ink.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.3,
            children: const [
              _MiniMetric(label: 'เที่ยวส่ง', value: '24', color: TpColors.mint),
              _MiniMetric(label: 'เฉลี่ย/เที่ยว', value: '฿81', color: TpColors.mango),
              _MiniMetric(label: 'ทิป', value: '฿140', color: TpColors.pink),
              _MiniMetric(label: 'ชั่วโมง', value: '28h', color: TpColors.purple),
            ],
          ),
        ),
        const SectionHeader(
          titleTh: 'ประวัติงาน',
          titleEn: 'Recent trips',
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final h in _history) ...[
                _HistoryRow(trip: h),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 9,
              letterSpacing: 1.5,
              color: Color(0x99FFFFFF),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripHistory {
  const _TripHistory({required this.id, required this.route, required this.pay, required this.when});
  final String id;
  final String route;
  final int pay;
  final String when;
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.trip});
  final _TripHistory trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: TpColors.mint,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check_rounded, size: 18, color: TpColors.ink),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.route,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '#${trip.id} · ${trip.when}',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: Color(0x99FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+฿${trip.pay}',
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: TpColors.mango,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// R5 · Profile
// ═══════════════════════════════════════════════════════════════════════

class RiderProfilePage extends StatelessWidget {
  const RiderProfilePage({super.key});

  static const _menu = <_RProfileItem>[
    _RProfileItem('🛵', 'ยานพาหนะ', 'Honda Wave'),
    _RProfileItem('📄', 'เอกสาร', 'ครบ'),
    _RProfileItem('🏥', 'ประกัน', 'กำลังใช้งาน'),
    _RProfileItem('🆘', 'SOS · ฉุกเฉิน', ''),
    _RProfileItem('⚙', 'ตั้งค่า', ''),
    _RProfileItem('↗', 'ออกจากระบบ', ''),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const _RiderHeader(title: 'โปรไฟล์ไรเดอร์', sub: 'PROFILE'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [TpColors.purple, TpColors.pink],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: TpColors.mango,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: TpShadows.claySm,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'ว',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: TpColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RIDER · LV 8',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          letterSpacing: 1.5,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                      Text(
                        'วิชัย แสงดาว',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Thai',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '⭐ 4.8 · 1,240 เที่ยว · Honda Wave กข-1482',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Thai',
                          fontSize: 11,
                          color: Color(0xE6FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (final b in const [('🏆', 'Gold'), ('✓', '98%'), ('⚡', '12m'), ('🛡', 'ยืนยัน')]) ...[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(b.$1, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text(
                          b.$2,
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 9,
                            color: Color(0xB3FFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final m in _menu) ...[
                _MenuRow(item: m),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RProfileItem {
  const _RProfileItem(this.icon, this.label, this.rightText);
  final String icon;
  final String label;
  final String rightText;
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item});
  final _RProfileItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: TpColors.mango.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(item.icon, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Thai',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
          if (item.rightText.isNotEmpty)
            Text(
              item.rightText,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                color: Color(0x99FFFFFF),
              ),
            ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0x66FFFFFF)),
        ],
      ),
    );
  }
}
