import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puffy_button.dart';
import '../../shared/widgets/section_header.dart';

/// Seller feature pages — all real UI per
/// `design_handoff_thaiprompt_marketplace/seller-app.jsx`.

// Shared seller header (light page bg, black title).
class _SellerHeader extends StatelessWidget {
  const _SellerHeader({required this.title, required this.sub, this.showBack = false});
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
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.pop(),
                child: const SizedBox(
                  width: 34,
                  height: 34,
                  child: Icon(Icons.arrow_back_rounded, size: 18, color: TpColors.ink),
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

// ═══════════════════════════════════════════════════════════════════════
// S1 · Dashboard
// ═══════════════════════════════════════════════════════════════════════

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({super.key});

  static const _hoursSales = [12, 28, 45, 38, 52, 62, 48, 35];
  static const _newOrders = <_SellerOrderStub>[
    _SellerOrderStub(id: 'TP-2041', summary: 'ข้าวซอยไก่ x2, ไข่ต้ม', status: 'ใหม่!', statusColor: TpColors.pink, elapsed: '1 นาที', price: 170),
    _SellerOrderStub(id: 'TP-2040', summary: 'แกงเหลือง x1', status: 'กำลังทำ', statusColor: TpColors.mango, elapsed: '8 นาที', price: 85),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const _ShopHeader(),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(child: _StatCard(label: 'ยอดขายวันนี้', value: '฿3,820', delta: '↑ 18%', deltaColor: TpColors.mint, bg: Colors.white, fg: TpColors.ink)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(label: 'รอจัดส่ง', value: '7', delta: '⚡ 2 ด่วน →', deltaColor: TpColors.mango, bg: TpColors.ink, fg: Colors.white, onTap: () => context.go('/seller/orders'))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SalesChartCard(bars: _hoursSales, onViewAll: () => context.go('/seller/reports')),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: _QuickAction(icon: '＋', label: 'เพิ่มสินค้า', color: TpColors.mint, onTap: () => context.go('/seller/products/0'))),
              const SizedBox(width: 8),
              Expanded(child: _QuickAction(icon: '%', label: 'โปรโมชัน', color: TpColors.pink, onTap: () => context.go('/seller/promos'))),
              const SizedBox(width: 8),
              const Expanded(child: _QuickAction(icon: '💬', label: 'แชท', color: TpColors.purple)),
              const SizedBox(width: 8),
              Expanded(child: _QuickAction(icon: '↓', label: 'ถอน', color: TpColors.mango, onTap: () => context.go('/seller/withdraw'))),
            ],
          ),
        ),
        const SectionHeader(titleTh: 'ออเดอร์ใหม่', titleEn: 'New orders', action: 'ทั้งหมด'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final o in _newOrders) ...[
                _OrderRow(order: o, onTap: () => context.go('/seller/orders/${o.id}')),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [TpColors.mango, TpColors.tomato]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SELLER · ร้านค้า', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, letterSpacing: 1.5, color: Color(0xCC2A1F3D), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: TpShadows.claySm),
                alignment: Alignment.center,
                child: const Text('ป', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w900, fontSize: 18, color: TpColors.ink)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ครัวยายปราณี', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w900, fontSize: 16, color: TpColors.ink)),
                    Text('● เปิดร้านอยู่ · 4.9★', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 11, color: TpColors.ink)),
                  ],
                ),
              ),
              Container(
                width: 42, height: 24,
                decoration: BoxDecoration(color: TpColors.mint, borderRadius: BorderRadius.circular(999), boxShadow: TpShadows.claySm),
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(padding: EdgeInsets.only(right: 3), child: CircleAvatar(radius: 9, backgroundColor: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.delta, required this.deltaColor, required this.bg, required this.fg, this.onTap});
  final String label, value, delta;
  final Color deltaColor, bg, fg;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ClayCard(
      onTap: onTap, color: bg, padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, letterSpacing: 1.5, color: fg.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w900, fontSize: 22, color: fg)),
          const SizedBox(height: 2),
          Text(delta, style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 11, color: deltaColor, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SalesChartCard extends StatelessWidget {
  const _SalesChartCard({required this.bars, required this.onViewAll});
  final List<int> bars;
  final VoidCallback onViewAll;
  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('ยอดขาย 8 ชม.ล่าสุด', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w800, fontSize: 13, color: TpColors.ink))),
              GestureDetector(onTap: onViewAll, child: const Text('ดูเพิ่ม →', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TpColors.tomato, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < bars.length; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  Expanded(
                    child: FractionallySizedBox(
                      heightFactor: bars[i] / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: i == 5 ? const [TpColors.pink, Color(0xFF8A0030)] : const [TpColors.mango, Color(0xFF7A5200)]),
                          borderRadius: BorderRadius.circular(8),
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
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color, this.onTap});
  final String icon, label;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14), boxShadow: TpShadows.claySm),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w900, fontSize: 18, color: TpColors.ink)),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 10, fontWeight: FontWeight.w700, color: TpColors.ink)),
        ],
      ),
    );
  }
}

class _SellerOrderStub {
  const _SellerOrderStub({required this.id, required this.summary, required this.status, required this.statusColor, required this.elapsed, required this.price, this.customer});
  final String id, summary, status, elapsed;
  final Color statusColor;
  final int price;
  final String? customer;
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.onTap});
  final _SellerOrderStub order;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ClayCard(
      onTap: onTap, padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('#${order.id}', style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.w700, color: TpColors.ink)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: order.statusColor, borderRadius: BorderRadius.circular(999), boxShadow: TpShadows.claySm),
                child: Text(order.status, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(order.summary, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w700, fontSize: 13, color: TpColors.ink)),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${order.customer != null ? '👤 ${order.customer} · ' : ''}${order.elapsed}', style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TpColors.muted)),
              Text('฿${order.price}', style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w900, fontSize: 16, color: TpColors.ink)),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// S2 · Orders
// ═══════════════════════════════════════════════════════════════════════

class SellerOrdersPage extends StatefulWidget {
  const SellerOrdersPage({super.key});
  @override
  State<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends State<SellerOrdersPage> {
  int _tab = 0;
  static const _tabs = ['ทั้งหมด', 'ใหม่', 'กำลังทำ', 'ส่งแล้ว'];
  static const _orders = <_SellerOrderStub>[
    _SellerOrderStub(id: 'TP-2041', summary: 'ข้าวซอยไก่ x2, ไข่ต้ม', status: 'ใหม่', statusColor: TpColors.pink, elapsed: '1 นาที', price: 170, customer: 'สมพร'),
    _SellerOrderStub(id: 'TP-2040', summary: 'แกงเหลือง x1, ผัดไทย x1', status: 'กำลังทำ', statusColor: TpColors.mango, elapsed: '8 นาที', price: 175, customer: 'ฟ้า'),
    _SellerOrderStub(id: 'TP-2039', summary: 'ขนมจีน x3', status: 'รอไรเดอร์', statusColor: TpColors.purple, elapsed: '12 นาที', price: 210, customer: 'ตุ๊ก'),
    _SellerOrderStub(id: 'TP-2038', summary: 'ข้าวซอยไก่ x1', status: 'ส่งแล้ว', statusColor: TpColors.mint, elapsed: '45 นาที', price: 75, customer: 'มานะ'),
    _SellerOrderStub(id: 'TP-2037', summary: 'แกงเหลือง x2', status: 'ส่งแล้ว', statusColor: TpColors.mint, elapsed: '1 ชม', price: 170, customer: 'พลอย'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const _SellerHeader(title: 'ออเดอร์ทั้งหมด', sub: 'ORDERS'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _tab == i ? TpColors.ink : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: _tab == i ? TpShadows.claySm : null,
                    ),
                    child: Text(_tabs[i], style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 12, fontWeight: FontWeight.w700, color: _tab == i ? TpColors.mango : TpColors.ink2)),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final o in _orders) ...[
                _OrderRow(order: o, onTap: () => context.go('/seller/orders/${o.id}')),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// S3 · Order detail
// ═══════════════════════════════════════════════════════════════════════

class SellerOrderDetailPage extends StatelessWidget {
  const SellerOrderDetailPage({super.key, required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SafeArea(
        child: ListView(
          children: [
            _SellerHeader(title: '#$orderId', sub: 'ORDER DETAIL', showBack: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: TpColors.pink, borderRadius: BorderRadius.circular(TpRadii.chunk), boxShadow: TpShadows.clay),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ORDER NEW · 1 นาทีที่แล้ว', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, letterSpacing: 1.5, color: Color(0xD9FFFFFF))),
                    const SizedBox(height: 4),
                    const Text('รอยืนยันออเดอร์', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: PuffyButton(label: '✓ รับออเดอร์', variant: PuffyVariant.ghost, fullWidth: true, onPressed: () => context.pop())),
                        const SizedBox(width: 8),
                        PuffyButton(label: 'ปฏิเสธ', variant: PuffyVariant.ink, onPressed: () => context.pop()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClayCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ลูกค้า', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, letterSpacing: 1.5, color: TpColors.muted)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(color: TpColors.mango, borderRadius: BorderRadius.circular(12), boxShadow: TpShadows.claySm),
                          alignment: Alignment.center,
                          child: const Text('ส', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w900, fontSize: 16, color: TpColors.ink)),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('คุณสมพร · Lv.12', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 13, fontWeight: FontWeight.w700, color: TpColors.ink)),
                              Text('ซ.สุขุมวิท 24 · 1.2km', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TpColors.muted)),
                            ],
                          ),
                        ),
                        PuffyButton(label: '💬', variant: PuffyVariant.ghost, size: PuffySize.small, onPressed: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClayCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('รายการ', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, letterSpacing: 1.5, color: TpColors.muted)),
                    const SizedBox(height: 8),
                    _ItemRow(name: 'ข้าวซอยไก่ (กลาง)', qty: 2, price: 150, note: 'ไม่เผ็ด'),
                    const Divider(height: 12, thickness: 1, color: Color(0x1A2E1A5C)),
                    const _ItemRow(name: 'ไข่ต้มเพิ่ม', qty: 2, price: 20),
                    const Divider(height: 16, color: TpColors.ink),
                    const _SummaryRow(label: 'ยอดรวม', value: '฿170'),
                    const _SummaryRow(label: 'ค่าคอมแพลตฟอร์ม 8%', value: '-฿13.60'),
                    const SizedBox(height: 6),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('ร้านได้รับ', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w900, fontSize: 14, color: TpColors.ink)),
                        Text('฿156.40', style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 22, fontWeight: FontWeight.w900, color: TpColors.mint)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClayCard(
                color: TpColors.paper2, padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: TpColors.mint, borderRadius: BorderRadius.circular(8)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text('จ่ายด้วย Wallet · สำเร็จแล้ว', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 12, fontWeight: FontWeight.w700, color: TpColors.ink)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.name, required this.qty, required this.price, this.note});
  final String name;
  final int qty, price;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('×$qty', style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.w700, color: TpColors.pink)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w700, fontSize: 13, color: TpColors.ink)),
              if (note != null)
                Text('หมายเหตุ: $note', style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 11, fontStyle: FontStyle.italic, color: TpColors.pink)),
            ],
          ),
        ),
        Text('฿$price', style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 13, fontWeight: FontWeight.w700, color: TpColors.ink)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 11, color: TpColors.muted)),
          Text(value, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.w700, color: TpColors.ink)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// S4 · Products
// ═══════════════════════════════════════════════════════════════════════

class SellerProductsPage extends StatelessWidget {
  const SellerProductsPage({super.key});

  static const _products = <_ProductStub>[
    _ProductStub(id: 1, name: 'ข้าวซอยไก่', price: 85, stock: 42, bg: Color(0xFFFFE3EB), sold: 142, enabled: true),
    _ProductStub(id: 2, name: 'แกงเหลือง', price: 85, stock: 18, bg: Color(0xFFFFF0C7), sold: 88, enabled: true),
    _ProductStub(id: 3, name: 'ผัดไทยกุ้ง', price: 90, stock: 0, bg: Color(0xFFFFE3EB), sold: 56, enabled: false),
    _ProductStub(id: 4, name: 'ขนมจีนน้ำยา', price: 70, stock: 12, bg: Color(0xFFDFFAF3), sold: 34, enabled: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const _SellerHeader(title: 'สินค้าของร้าน', sub: 'PRODUCTS · 38 รายการ'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ClayCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shadow: ClayShadow.small,
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, size: 16, color: TpColors.muted),
                      SizedBox(width: 6),
                      Text('ค้นหาสินค้า...', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 12, color: TpColors.muted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PuffyButton(label: '＋ เพิ่ม', variant: PuffyVariant.ink, size: PuffySize.small, onPressed: () => context.go('/seller/products/0')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
            childAspectRatio: 0.85,
            children: [
              for (final p in _products) _ProductCard(product: p, onTap: () => context.go('/seller/products/${p.id}')),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductStub {
  const _ProductStub({required this.id, required this.name, required this.price, required this.stock, required this.bg, required this.sold, required this.enabled});
  final int id, price, stock, sold;
  final String name;
  final Color bg;
  final bool enabled;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});
  final _ProductStub product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(TpRadii.chunk),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(TpRadii.chunk), boxShadow: TpShadows.clay),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Container(
                    height: 80, color: product.bg,
                    alignment: Alignment.center,
                    child: const Text('🍜', style: TextStyle(fontSize: 32)),
                  ),
                  if (!product.enabled)
                    Positioned.fill(
                      child: Container(
                        color: TpColors.ink.withValues(alpha: 0.7),
                        alignment: Alignment.center,
                        child: const Text('หมด', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white)),
                      ),
                    ),
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: product.enabled ? TpColors.mint : TpColors.muted, borderRadius: BorderRadius.circular(999)),
                      child: Text(product.enabled ? 'เปิดขาย' : 'ปิด', style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w700, fontSize: 12, color: TpColors.ink)),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('฿${product.price}', style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w900, fontSize: 14, color: TpColors.ink)),
                        Text('ขาย ${product.sold}', style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, color: TpColors.muted)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'STOCK: ${product.stock}',
                      style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, fontWeight: FontWeight.w700, color: product.stock < 10 ? TpColors.pink : TpColors.muted),
                    ),
                  ],
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
// S5 · Product edit
// ═══════════════════════════════════════════════════════════════════════

class SellerProductEditPage extends StatefulWidget {
  const SellerProductEditPage({super.key, required this.productId});
  final int productId;
  @override
  State<SellerProductEditPage> createState() => _SellerProductEditPageState();
}

class _SellerProductEditPageState extends State<SellerProductEditPage> {
  int _categoryIdx = 0;
  bool _enabled = true;
  static const _categories = ['อาหาร', 'ของหวาน', 'เครื่องดื่ม', 'ผักผลไม้'];

  @override
  Widget build(BuildContext context) {
    final isNew = widget.productId == 0;
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            _SellerHeader(
              title: isNew ? 'เพิ่มสินค้าใหม่' : 'แก้ไขสินค้า',
              sub: isNew ? 'NEW PRODUCT' : 'EDIT',
              showBack: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: i == 0 ? const Color(0xFFFFE3EB) : Colors.white,
                            borderRadius: BorderRadius.circular(TpRadii.chunk),
                            border: i == 0 ? null : Border.all(color: TpColors.muted.withValues(alpha: 0.25), width: 2, style: BorderStyle.solid),
                            boxShadow: i == 0 ? TpShadows.claySm : null,
                          ),
                          child: Stack(
                            children: [
                              Center(child: Text(i == 0 ? '🍜' : '＋', style: const TextStyle(fontSize: 24))),
                              if (i == 0)
                                Positioned(
                                  top: 4, left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: TpColors.ink, borderRadius: BorderRadius.circular(6)),
                                    child: const Text('หลัก', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w800, fontSize: 9, color: TpColors.mango)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Field(label: 'ชื่อสินค้า', value: isNew ? '' : 'ข้าวซอยไก่สูตรเชียงใหม่'),
            _Field(label: 'รายละเอียด', value: isNew ? '' : 'น้ำข้นเข้มข้น ไก่นุ่มเปื่อย มาพร้อมเครื่องเคียงครบ', multiline: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _Field(label: 'ราคา (฿)', value: isNew ? '' : '85', mono: true, padless: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(label: 'สต็อก', value: isNew ? '' : '42', mono: true, padless: true)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('หมวด', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, letterSpacing: 1.5, color: TpColors.muted)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: [
                      for (var i = 0; i < _categories.length; i++)
                        GestureDetector(
                          onTap: () => setState(() => _categoryIdx = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: i == _categoryIdx ? TpColors.ink : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: TpShadows.claySm,
                            ),
                            child: Text(
                              _categories[i],
                              style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 11, fontWeight: FontWeight.w700, color: i == _categoryIdx ? TpColors.mango : TpColors.ink2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClayCard(
                color: const Color(0xFFDFFAF3),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('เปิดขาย (visible to buyers)', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 13, fontWeight: FontWeight.w700, color: TpColors.ink)),
                    ),
                    Switch.adaptive(
                      value: _enabled,
                      activeColor: TpColors.mint,
                      onChanged: (v) => setState(() => _enabled = v),
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
                  if (!isNew)
                    PuffyButton(label: '🗑 ลบ', variant: PuffyVariant.ghost, onPressed: () => context.pop()),
                  if (!isNew) const SizedBox(width: 8),
                  Expanded(
                    child: PuffyButton(
                      label: 'บันทึกสินค้า',
                      variant: PuffyVariant.pink, fullWidth: true, size: PuffySize.large,
                      onPressed: () => context.go('/seller/products'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.multiline = false, this.mono = false, this.padless = false});
  final String label, value;
  final bool multiline, mono, padless;

  @override
  Widget build(BuildContext context) {
    final inner = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, letterSpacing: 1.5, color: TpColors.muted)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          constraints: BoxConstraints(minHeight: multiline ? 70 : 0),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(TpRadii.chunk), boxShadow: TpShadows.claySm),
          child: Text(
            value.isEmpty ? 'ใส่$label...' : value,
            style: TextStyle(
              fontFamily: mono ? 'JetBrains Mono' : 'IBM Plex Sans Thai',
              fontSize: 13,
              color: value.isEmpty ? TpColors.muted : TpColors.ink,
            ),
          ),
        ),
      ],
    );
    return Padding(
      padding: padless ? EdgeInsets.zero : const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: inner,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// S6 · Promos
// ═══════════════════════════════════════════════════════════════════════

class SellerPromosPage extends StatelessWidget {
  const SellerPromosPage({super.key});

  static const _promos = <_PromoStub>[
    _PromoStub(name: 'ลด 20% เมื่อซื้อ 2 ชิ้น', type: 'ส่วนลด%', color: TpColors.pink, used: '42/100', on: true),
    _PromoStub(name: 'ส่งฟรีทุกออเดอร์', type: 'ส่งฟรี', color: TpColors.mint, used: '88/∞', on: true),
    _PromoStub(name: 'SONGKRAN30', type: 'โค้ดลด ฿30', color: TpColors.mango, used: '0/50', on: false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const _SellerHeader(title: 'โปรโมชัน', sub: 'PROMOTIONS'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [TpColors.pink, TpColors.purple]),
              borderRadius: BorderRadius.circular(TpRadii.chunk), boxShadow: TpShadows.clay,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ACTIVE · 2 โปร', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, letterSpacing: 1.5, color: Color(0xD9FFFFFF))),
                SizedBox(height: 4),
                Text('เพิ่มยอดขาย 34%', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('โปรกระตุ้นได้ผลดีที่สุดในเดือนนี้', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 11, color: Color(0xE6FFFFFF))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final p in _promos) ...[
                _PromoRow(promo: p),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 6),
              PuffyButton(label: '＋ สร้างโปรใหม่', variant: PuffyVariant.ink, fullWidth: true, size: PuffySize.large, onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
}

class _PromoStub {
  const _PromoStub({required this.name, required this.type, required this.color, required this.used, required this.on});
  final String name, type, used;
  final Color color;
  final bool on;
}

class _PromoRow extends StatelessWidget {
  const _PromoRow({required this.promo});
  final _PromoStub promo;
  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: promo.color, borderRadius: BorderRadius.circular(14), boxShadow: TpShadows.claySm),
            alignment: Alignment.center,
            child: const Text('%', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promo.name, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w700, fontSize: 13, color: TpColors.ink)),
                Text('${promo.type} · ใช้ ${promo.used}', style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TpColors.muted)),
              ],
            ),
          ),
          Switch.adaptive(value: promo.on, activeColor: TpColors.mint, onChanged: (_) {}),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// S7 · Reports
// ═══════════════════════════════════════════════════════════════════════

class SellerReportsPage extends StatelessWidget {
  const SellerReportsPage({super.key});

  static const _months = [45, 62, 58, 80, 72, 95];
  static const _monthLabels = ['พ.ย.', 'ธ.ค.', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.'];
  static const _topSelling = <_TopProduct>[
    _TopProduct('ข้าวซอยไก่', 142, 12070, Color(0xFFFFE3EB)),
    _TopProduct('แกงเหลือง', 88, 7480, Color(0xFFFFF0C7)),
    _TopProduct('ผัดไทยกุ้ง', 56, 5040, Color(0xFFFFE3EB)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const _SellerHeader(title: 'รายงานยอดขาย', sub: 'REPORTS'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(child: _StatCard(label: 'เดือนนี้', value: '฿48,240', delta: '↑ 22%', deltaColor: TpColors.mint, bg: TpColors.ink, fg: Colors.white)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(label: 'ออเดอร์', value: '312', delta: 'เฉลี่ย 10/วัน', deltaColor: const Color(0xFF7A5200), bg: TpColors.mango, fg: TpColors.ink2)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClayCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ยอดขาย 6 เดือน', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w800, fontSize: 13, color: TpColors.ink)),
                const SizedBox(height: 10),
                AspectRatio(
                  aspectRatio: 2.67,
                  child: CustomPaint(painter: _MonthLineChartPainter(_months)),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final m in _monthLabels)
                      Text(m, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, color: TpColors.muted)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SectionHeader(titleTh: 'สินค้าขายดี', titleEn: 'Top selling'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final p in _topSelling) ...[
                ClayCard(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: p.bg, borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center, child: const Text('🍜', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w700, fontSize: 13, color: TpColors.ink)),
                            Text('ขาย ${p.qty} จาน', style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TpColors.muted)),
                          ],
                        ),
                      ),
                      Text('฿${p.revenue.toString()}', style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 15, fontWeight: FontWeight.w900, color: TpColors.mint)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TopProduct {
  const _TopProduct(this.name, this.qty, this.revenue, this.bg);
  final String name;
  final int qty, revenue;
  final Color bg;
}

class _MonthLineChartPainter extends CustomPainter {
  _MonthLineChartPainter(this.months);
  final List<int> months;

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = months.reduce((a, b) => a > b ? a : b);
    final step = size.width / (months.length - 1);
    final points = <Offset>[
      for (var i = 0; i < months.length; i++)
        Offset(i * step, size.height - (months[i] / maxV * size.height * 0.9))
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Fill area under line.
    final fill = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0x4DFF7A3A), Color(0x00FF7A3A)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = TpColors.tomato
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (final p in points) {
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 5, Paint()..color = TpColors.tomato..strokeWidth = 3..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _MonthLineChartPainter old) => old.months != months;
}

// ═══════════════════════════════════════════════════════════════════════
// S8 · Withdraw
// ═══════════════════════════════════════════════════════════════════════

class SellerWithdrawPage extends StatelessWidget {
  const SellerWithdrawPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const _SellerHeader(title: 'ถอนเงินเข้าบัญชี', sub: 'WITHDRAW'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [TpColors.mint, TpColors.purple]),
              borderRadius: BorderRadius.circular(TpRadii.chunk), boxShadow: TpShadows.clay,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ยอดคงเหลือ · ถอนได้', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, letterSpacing: 1.5, color: Color(0xD9FFFFFF))),
                Text('฿8,420.60', style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('รอเคลียร์ (2 วัน): ฿1,240', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 11, color: Color(0xD9FFFFFF))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClayCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('บัญชีรับเงิน', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, letterSpacing: 1.5, color: TpColors.muted)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(color: TpColors.pink, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: const Text('K', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('กสิกรไทย · •••• 3821', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 13, fontWeight: FontWeight.w700, color: TpColors.ink)),
                          Text('ปราณี ศรีสวัสดิ์', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TpColors.muted)),
                        ],
                      ),
                    ),
                    const Text('เปลี่ยน', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 11, fontWeight: FontWeight.w700, color: TpColors.tomato)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClayCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('จำนวนเงิน', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, letterSpacing: 1.5, color: TpColors.muted)),
                const SizedBox(height: 6),
                const Text('฿3,000', style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 36, fontWeight: FontWeight.w900, color: TpColors.ink)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final amt in const ['฿1,000', '฿3,000', '฿5,000', 'ทั้งหมด']) ...[
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: amt == '฿3,000' ? TpColors.ink : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: TpShadows.claySm,
                          ),
                          child: Center(
                            child: Text(amt, style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 11, fontWeight: FontWeight.w700, color: amt == '฿3,000' ? TpColors.mango : TpColors.ink2)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PuffyButton(label: 'ถอนเงิน ฿3,000', variant: PuffyVariant.pink, fullWidth: true, size: PuffySize.large, onPressed: () {}),
        ),
        const SectionHeader(titleTh: 'ประวัติถอนล่าสุด', titleEn: 'Recent withdrawals'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final h in const [
                ('5,000', '20 เม.ย.', 'สำเร็จ'),
                ('3,000', '10 เม.ย.', 'สำเร็จ'),
                ('2,000', '1 เม.ย.', 'สำเร็จ'),
              ]) ...[
                ClayCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.south_east_rounded, size: 18, color: TpColors.mint),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('฿${h.$1}', style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 15, fontWeight: FontWeight.w900, color: TpColors.ink)),
                            Text(h.$2, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TpColors.muted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: TpColors.mint, borderRadius: BorderRadius.circular(999)),
                        child: Text(h.$3, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
