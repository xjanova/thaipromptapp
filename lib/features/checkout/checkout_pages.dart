import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puffy_button.dart';
import '../../shared/widgets/under_construction_page.dart';

/// Shared header used across checkout steps. Back button + TH title +
/// mono `STEP x/4` uppercase subtitle. Matches `BuyerHeader` in
/// `design_handoff_thaiprompt_marketplace/buyer-app.jsx`.
class _CkHeader extends StatelessWidget {
  const _CkHeader({required this.title, required this.sub, required this.onBack});
  final String title;
  final String sub;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onBack,
              child: const SizedBox(
                width: 34,
                height: 34,
                child: Icon(Icons.arrow_back_rounded, size: 18, color: TpColors.ink),
              ),
            ),
          ),
          const SizedBox(width: 10),
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
                    color: TpColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: TpColors.ink,
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

/// 4-step progress indicator. [step] is 0-based (0 = Address active).
class _CkProgress extends StatelessWidget {
  const _CkProgress({required this.step});
  final int step;

  static const _labels = ['ที่อยู่', 'วิธีจ่าย', 'QR', 'สำเร็จ'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          for (var i = 0; i < 4; i++) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i <= step ? TpColors.pink : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: TpShadows.claySm,
                    ),
                    child: Text(
                      i < step ? '✓' : '${i + 1}',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Thai',
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: i <= step ? Colors.white : TpColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _labels[i],
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 8,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                      color: i <= step ? TpColors.ink : TpColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (i < 3)
              Container(
                width: 12,
                height: 2,
                margin: const EdgeInsets.only(top: 12),
                color: i < step ? TpColors.pink : TpColors.muted.withValues(alpha: 0.2),
              ),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
// STEP 1/4 · Address picker
// ───────────────────────────────────────────────────────────────────────

class CheckoutAddressPage extends StatefulWidget {
  const CheckoutAddressPage({super.key});

  @override
  State<CheckoutAddressPage> createState() => _CheckoutAddressPageState();
}

class _CheckoutAddressPageState extends State<CheckoutAddressPage> {
  // Stub addresses until `/v1/user/addresses` lands.
  static const _addresses = <_AddrItem>[
    _AddrItem('บ้าน', 'ซ.สุขุมวิท 36 อาคาร B ชั้น 7 · 10110', '🏠', TpColors.mango, '25 นาที'),
    _AddrItem('ออฟฟิศ', 'อาคารเอ็มไพร์ ชั้น 24 · สาทร 10500', '🏢', TpColors.mint, '35 นาที'),
    _AddrItem('บ้านแม่', 'ซ.รามคำแหง 24 · 10240', '💝', TpColors.pink, '50 นาที'),
  ];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            _CkHeader(
              title: 'เลือกที่อยู่จัดส่ง',
              sub: 'CHECKOUT · STEP 1/4',
              onBack: () => context.go('/cart'),
            ),
            const _CkProgress(step: 0),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                children: [
                  for (var i = 0; i < _addresses.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AddrTile(
                        item: _addresses[i],
                        selected: i == _selected,
                        onTap: () => setState(() => _selected = i),
                      ),
                    ),
                  PuffyButton(
                    label: '+ เพิ่มที่อยู่ใหม่',
                    variant: PuffyVariant.ghost,
                    fullWidth: true,
                    onPressed: () {
                      // TODO: open /buyer/addresses new-form sheet
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ฟอร์มเพิ่มที่อยู่ใหม่ · เร็วๆ นี้')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: SafeArea(
        top: false,
        child: Container(
          color: TpColors.paper.withValues(alpha: 0.95),
          padding: const EdgeInsets.all(16),
          child: PuffyButton(
            label: 'ถัดไป · เลือกวิธีจ่าย →',
            variant: PuffyVariant.pink,
            fullWidth: true,
            size: PuffySize.large,
            onPressed: () => context.go('/buyer/checkout/payment'),
          ),
        ),
      ),
    );
  }
}

class _AddrItem {
  const _AddrItem(this.name, this.detail, this.emoji, this.color, this.eta);
  final String name;
  final String detail;
  final String emoji;
  final Color color;
  final String eta;
}

class _AddrTile extends StatelessWidget {
  const _AddrTile({required this.item, required this.selected, required this.onTap});
  final _AddrItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      border: selected ? Border.all(color: TpColors.pink, width: 3) : null,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: TpShadows.claySm,
            ),
            alignment: Alignment.center,
            child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Thai',
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: TpColors.ink,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: TpColors.mint,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        item.eta,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.detail,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 11,
                    color: TpColors.ink2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: selected ? TpColors.pink : Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: TpShadows.claySm,
            ),
            alignment: Alignment.center,
            child: selected
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
// STEP 2/4 · Payment method picker
// ───────────────────────────────────────────────────────────────────────

class CheckoutPaymentPage extends StatefulWidget {
  const CheckoutPaymentPage({super.key});

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  static const _methods = <_PayMethod>[
    _PayMethod('PromptPay QR', 'สแกนจ่ายทันที · xxx-xxx-4821', 'QR', TpColors.purple, 'แนะนำ'),
    _PayMethod('Thaiprompt Wallet', 'คงเหลือ ฿2,480', '฿', TpColors.mango, 'เร็วสุด'),
    _PayMethod('บัตรเครดิต', 'Visa ••• 2847', '▭', TpColors.pink, null),
    _PayMethod('TrueMoney Wallet', 'เชื่อมแล้ว', 'T', TpColors.tomato, null),
    _PayMethod('เก็บเงินปลายทาง', 'COD · ค่าส่ง +฿10', '✋', TpColors.mint, null),
  ];

  int _selected = 0;
  final _couponCtrl = TextEditingController();

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            _CkHeader(
              title: 'เลือกวิธีชำระเงิน',
              sub: 'CHECKOUT · STEP 2/4',
              onBack: () => context.go('/buyer/checkout/address'),
            ),
            const _CkProgress(step: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 140),
                children: [
                  for (var i = 0; i < _methods.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PayTile(
                        item: _methods[i],
                        selected: i == _selected,
                        onTap: () => setState(() => _selected = i),
                      ),
                    ),
                  const SizedBox(height: 6),
                  ClayCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'คูปอง & โค้ด',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: TpColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: TpColors.paper,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  controller: _couponCtrl,
                                  style: const TextStyle(
                                    fontFamily: 'IBM Plex Sans Thai',
                                    fontSize: 12,
                                    color: TpColors.ink,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'กรอกโค้ดส่วนลด',
                                    hintStyle: TextStyle(
                                      fontFamily: 'IBM Plex Sans Thai',
                                      fontSize: 12,
                                      color: TpColors.muted,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            PuffyButton(
                              label: 'ใช้',
                              variant: PuffyVariant.ghost,
                              size: PuffySize.small,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClayCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'สรุปยอด',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: TpColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        for (final row in const [
                          ('ยอดสินค้า', '฿185'),
                          ('ค่าส่ง', '฿20'),
                          ('ส่วนลด', '-฿35'),
                        ])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(row.$1, style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans Thai',
                                  fontSize: 12,
                                  color: TpColors.muted,
                                )),
                                Text(row.$2, style: const TextStyle(
                                  fontFamily: 'Space Grotesk',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: TpColors.ink,
                                )),
                              ],
                            ),
                          ),
                        const Divider(height: 14, thickness: 1, color: Color(0x1A2E1A5C)),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ยอดชำระ', style: TextStyle(
                              fontFamily: 'IBM Plex Sans Thai',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: TpColors.ink,
                            )),
                            Text('฿170', style: TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: TpColors.pink,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: SafeArea(
        top: false,
        child: Container(
          color: TpColors.paper.withValues(alpha: 0.95),
          padding: const EdgeInsets.all(16),
          child: PuffyButton(
            label: 'จ่าย ฿170 →',
            variant: PuffyVariant.pink,
            fullWidth: true,
            size: PuffySize.large,
            onPressed: () {
              // Route to QR if PromptPay selected, else skip to Paid.
              if (_selected == 0) {
                context.go('/buyer/checkout/qr');
              } else {
                context.go('/buyer/checkout/paid');
              }
            },
          ),
        ),
      ),
    );
  }
}

class _PayMethod {
  const _PayMethod(this.name, this.detail, this.icon, this.color, this.tag);
  final String name;
  final String detail;
  final String icon;
  final Color color;
  final String? tag;
}

class _PayTile extends StatelessWidget {
  const _PayTile({required this.item, required this.selected, required this.onTap});
  final _PayMethod item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      border: selected ? Border.all(color: TpColors.pink, width: 3) : null,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: TpShadows.claySm,
            ),
            alignment: Alignment.center,
            child: Text(
              item.icon,
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Thai',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: TpColors.ink,
                      ),
                    ),
                    if (item.tag != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: TpColors.mango,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          item.tag!,
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Thai',
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                            color: TpColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  item.detail,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 10,
                    color: TpColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: selected ? TpColors.pink : Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: TpShadows.claySm,
            ),
            alignment: Alignment.center,
            child: selected
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
// STEP 3/4 · PromptPay QR (stub for now · custom painter needed)
// ───────────────────────────────────────────────────────────────────────

class CheckoutQrPage extends StatefulWidget {
  const CheckoutQrPage({super.key});

  @override
  State<CheckoutQrPage> createState() => _CheckoutQrPageState();
}

class _CheckoutQrPageState extends State<CheckoutQrPage> {
  int _secondsRemaining = 287;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _secondsRemaining = (_secondsRemaining - 1).clamp(0, 99999);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mm = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final ss = (_secondsRemaining % 60).toString().padLeft(2, '0');
    final lowTime = _secondsRemaining < 60;

    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            _CkHeader(
              title: 'สแกนเพื่อจ่าย',
              sub: 'PROMPTPAY QR · STEP 3/4',
              onBack: () => context.go('/buyer/checkout/payment'),
            ),
            const _CkProgress(step: 2),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                child: ClayCard(
                  padding: const EdgeInsets.all(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Color(0xFFF1EBFF)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: TpColors.purple,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: TpShadows.claySm,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'P',
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'PromptPay',
                            style: TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 0.5,
                              color: TpColors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Faux QR placeholder — replace with real QR painter or
                      // `qr_flutter` package in v1.0.23.
                      Container(
                        width: 220,
                        height: 220,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: TpShadows.clayLg,
                        ),
                        child: CustomPaint(
                          painter: _FauxQrPainter(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '฿170.00',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.w900,
                          fontSize: 30,
                          color: TpColors.pink,
                        ),
                      ),
                      const Text(
                        'REF #TP-8821-9F4A',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          letterSpacing: 1.0,
                          color: TpColors.muted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: lowTime ? TpColors.pink : TpColors.deepInk,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: TpShadows.claySm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: TpColors.mango,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'รอการจ่าย · $mm:$ss',
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: SafeArea(
        top: false,
        child: Container(
          color: TpColors.paper.withValues(alpha: 0.95),
          padding: const EdgeInsets.all(16),
          child: PuffyButton(
            label: 'ชำระแล้ว · ตรวจสอบ →',
            variant: PuffyVariant.mint,
            fullWidth: true,
            size: PuffySize.large,
            onPressed: () => context.go('/buyer/checkout/paid'),
          ),
        ),
      ),
    );
  }
}

/// Visual-only QR placeholder. Renders a seeded "module" grid that looks
/// like a QR without encoding anything. Swap for `qr_flutter` + real
/// PromptPay payload in v1.0.23.
class _FauxQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cols = 14;
    final cell = size.width / cols;
    final paint = Paint()..color = TpColors.deepInk;

    for (var i = 0; i < cols * cols; i++) {
      final x = i % cols;
      final y = i ~/ cols;
      final seeded = (i * 31 + 7) % 100;
      final isCorner = (y < 3 && x < 3) ||
          (y < 3 && x >= cols - 3) ||
          (y >= cols - 3 && x < 3);
      if (isCorner || seeded < 55) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x * cell, y * cell, cell - 1, cell - 1),
            const Radius.circular(1),
          ),
          paint,
        );
      }
    }

    // Center badge with a ฿ glyph backdrop.
    final center = Offset(size.width / 2, size.height / 2);
    final badge = Paint()..color = TpColors.pink;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 40, height: 40),
        const Radius.circular(10),
      ),
      badge,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: '฿',
        style: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _FauxQrPainter oldDelegate) => false;
}

// ───────────────────────────────────────────────────────────────────────
// STEP 4/4 · Paid success
// ───────────────────────────────────────────────────────────────────────

class CheckoutPaidPage extends StatelessWidget {
  const CheckoutPaidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.5, -1),
            end: Alignment(0.5, 1),
            colors: [TpColors.mint, TpColors.mango],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success check — scale-in with TweenAnimationBuilder.
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: TpShadows.clayLg,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 64,
                      color: TpColors.mint,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'PAYMENT SUCCESS',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                    letterSpacing: 2.2,
                    color: TpColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ชำระเงินสำเร็จ',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                    color: TpColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ออเดอร์ #TP-8821 · ฿170',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 13,
                    color: TpColors.ink2,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: TpShadows.clay,
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'ครัวยายปราณี กำลังเตรียมของ',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Thai',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: TpColors.ink,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ประมาณ 25-35 นาที · ส่งถึงบ้าน',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Thai',
                          fontSize: 11,
                          color: TpColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: PuffyButton(
                        label: 'ใบเสร็จ',
                        variant: PuffyVariant.ghost,
                        fullWidth: true,
                        onPressed: () =>
                            context.go('/buyer/checkout/receipt/8821'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PuffyButton(
                        label: 'ติดตามออเดอร์ →',
                        variant: PuffyVariant.pink,
                        fullWidth: true,
                        onPressed: () => context.go('/buyer/tracking/8821'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
// Receipt — kept as stub; needs real order lookup from backend.
// ───────────────────────────────────────────────────────────────────────

class CheckoutReceiptPage extends StatelessWidget {
  const CheckoutReceiptPage({super.key, required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context) => UnderConstructionPage(
        title: 'ใบเสร็จ #$orderId',
        subtitle: 'รายการสินค้า · วิธีชำระ · ดาวน์โหลด PDF · share',
        icon: Icons.receipt_long_rounded,
      );
}
