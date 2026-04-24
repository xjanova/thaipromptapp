import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puffy_button.dart';
import '../../shared/widgets/section_header.dart';

/// Profile, address book, coupons. References: `screens-c.jsx → Profile` +
/// `buyer-app.jsx → BuyerAddress, BuyerCoupons`.

// ───────────────────────────────────────────────────────────────────────
// Profile
// ───────────────────────────────────────────────────────────────────────

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _menu = <_PMenuItem>[
    _PMenuItem('📦', 'ออเดอร์ของฉัน', '3 กำลังส่ง', TpColors.tomato, '/buyer/orders'),
    _PMenuItem('🏪', 'ร้านของฉัน', 'จัดการร้าน', TpColors.mango, '/seller'),
    _PMenuItem('🛵', 'โหมดไรเดอร์', 'เปิดใช้งาน', TpColors.purple, '/rider'),
    _PMenuItem('🌳', 'MLM Network', '฿12,480 รายได้', TpColors.mint, '/mlm'),
    _PMenuItem('📍', 'ที่อยู่จัดส่ง', '3 ที่อยู่', TpColors.sky, '/buyer/addresses'),
    _PMenuItem('🎫', 'คูปองของฉัน', '5 ใบ', TpColors.pink, '/buyer/coupons'),
    _PMenuItem('?', 'ช่วยเหลือ', '24/7', Color(0xFFEADDFB), null),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [TpColors.purple, TpColors.pink, TpColors.mango], stops: [0.0, 0.65, 1.0]),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => context.go('/buyer'),
                              child: const SizedBox(width: 38, height: 38, child: Icon(Icons.arrow_back_rounded, size: 18, color: TpColors.ink)),
                            ),
                          ),
                          Material(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => context.go('/settings'),
                              child: const SizedBox(width: 38, height: 38, child: Icon(Icons.settings_rounded, size: 18, color: TpColors.ink)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16, right: 16, bottom: -50,
                  child: ClayCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 84, height: 84,
                          margin: const EdgeInsets.only(top: -40),
                          decoration: BoxDecoration(
                            gradient: const RadialGradient(center: Alignment(-0.36, -0.44), radius: 0.9, colors: [Color(0xFFFFC99C), TpColors.pink, Color(0xFF8A0030)]),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [BoxShadow(color: TpColors.pink.withValues(alpha: 0.5), offset: const Offset(0, 10), blurRadius: 20, spreadRadius: -6)],
                          ),
                          alignment: Alignment.center,
                          child: const Text('ส', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w900, fontSize: 32, color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('@SOMPORN · LV 12', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, letterSpacing: 1.5, color: TpColors.muted)),
                              Text('สมพร จันทร์เพ็ญ', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w900, fontSize: 18, color: TpColors.ink)),
                              Text('🥈 Silver Affiliate · สมาชิกตั้งแต่ 2024', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 11, color: TpColors.ink2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 62),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (final s in const [('ออเดอร์', '84', Color(0xFFFFE3EB)), ('ดาวน์ไลน์', '27', Color(0xFFDFFAF3)), ('คะแนน', '4.9', Color(0xFFFFF0C7))]) ...[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(color: s.$3, borderRadius: BorderRadius.circular(TpRadii.chunk), boxShadow: TpShadows.claySm),
                        child: Column(
                          children: [
                            Text(s.$2, style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 20, fontWeight: FontWeight.w900, color: TpColors.ink)),
                            Text(s.$1, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TpColors.ink2)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SectionHeader(titleTh: 'เมนูของฉัน', titleEn: 'My menu'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final m in _menu) ...[
                    ClayCard(
                      onTap: m.route == null ? null : () => context.go(m.route!),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: m.color, borderRadius: BorderRadius.circular(14), boxShadow: TpShadows.claySm),
                            alignment: Alignment.center,
                            child: Text(m.icon, style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(m.label, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w700, fontSize: 13, color: TpColors.ink)),
                          ),
                          Text(m.right, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TpColors.muted)),
                          const Icon(Icons.chevron_right_rounded, size: 18, color: TpColors.muted),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _PMenuItem {
  const _PMenuItem(this.icon, this.label, this.right, this.color, this.route);
  final String icon, label, right;
  final Color color;
  final String? route;
}

// ───────────────────────────────────────────────────────────────────────
// Address book
// ───────────────────────────────────────────────────────────────────────

class AddressBookPage extends StatelessWidget {
  const AddressBookPage({super.key});

  static const _addrs = <_Addr>[
    _Addr('บ้าน', 'ซ.สุขุมวิท 36 กรุงเทพ 10110', TpColors.mango, true),
    _Addr('ออฟฟิศ', 'อาคารเอ็มไพร์ สาทร 10500', TpColors.mint, false),
    _Addr('บ้านแม่', 'ซ.รามคำแหง 24 กรุงเทพ 10240', TpColors.pink, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            _PBackHeader(title: 'ที่อยู่จัดส่ง', sub: 'ADDRESSES', onBack: () => context.go('/buyer/profile')),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final a in _addrs) ...[
                    ClayCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: a.color, borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center,
                            child: const Text('📍', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(a.name, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w900, fontSize: 14, color: TpColors.ink)),
                                    if (a.isDefault) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(color: TpColors.deepInk, borderRadius: BorderRadius.circular(5)),
                                        child: const Text('ค่าเริ่มต้น', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 9, fontWeight: FontWeight.w800, color: TpColors.mango)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(a.detail, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 11, color: TpColors.ink2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  PuffyButton(label: '+ เพิ่มที่อยู่', variant: PuffyVariant.ink, fullWidth: true, size: PuffySize.large, onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Addr {
  const _Addr(this.name, this.detail, this.color, this.isDefault);
  final String name, detail;
  final Color color;
  final bool isDefault;
}

// ───────────────────────────────────────────────────────────────────────
// Coupons
// ───────────────────────────────────────────────────────────────────────

class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key});

  static const _coupons = <_Coupon>[
    _Coupon('ส่วนลด ฿50', 'ขั้นต่ำ ฿200 · ใช้ได้ทุกร้าน', 'หมด 30 เม.ย.', TpColors.pink),
    _Coupon('ส่งฟรี', 'รัศมี 5 กม. · ไม่มีขั้นต่ำ', 'หมด 25 เม.ย.', TpColors.mango),
    _Coupon('ลด 15%', 'ร้านอาหารเท่านั้น', 'หมด 30 เม.ย.', TpColors.mint),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            _PBackHeader(title: 'คูปองของฉัน', sub: 'COUPONS', onBack: () => context.go('/buyer/profile')),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final c in _coupons) ...[
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(TpRadii.chunk), boxShadow: TpShadows.clay),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          Container(
                            width: 90,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: c.color,
                              border: Border(right: BorderSide(color: TpColors.deepInk.withValues(alpha: 0.2), width: 1)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              c.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                color: c.color == TpColors.mango ? TpColors.deepInk : Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.desc, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 12, fontWeight: FontWeight.w700, color: TpColors.ink)),
                                  Text(c.expires, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TpColors.muted)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(color: TpColors.mango, borderRadius: BorderRadius.circular(999), boxShadow: TpShadows.claySm),
                                    child: const Text('ใช้เลย', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 11, fontWeight: FontWeight.w800, color: TpColors.ink)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Coupon {
  const _Coupon(this.title, this.desc, this.expires, this.color);
  final String title, desc, expires;
  final Color color;
}

// Shared back-header used by Address + Coupons
class _PBackHeader extends StatelessWidget {
  const _PBackHeader({required this.title, required this.sub, required this.onBack});
  final String title, sub;
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
              child: const SizedBox(width: 34, height: 34, child: Icon(Icons.arrow_back_rounded, size: 18, color: TpColors.ink)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sub, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, letterSpacing: 1.8, color: TpColors.muted, fontWeight: FontWeight.w600)),
                Text(title, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w900, fontSize: 16, color: TpColors.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
