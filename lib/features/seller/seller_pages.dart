import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/under_construction_page.dart';

/// Seller feature pages. Dashboard is a real implementation; the rest are
/// stubs pending per-screen sessions.
///
/// Reference: `design_handoff_thaiprompt_marketplace/seller-app.jsx`.

// ═══════════════════════════════════════════════════════════════════════
// S1 · Dashboard — real
// ═══════════════════════════════════════════════════════════════════════

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({super.key});

  // Hourly sales (last 8h) as percentages of the chart height.
  // Replace with backend data from `/v1/seller/dashboard` in v1.0.23+.
  static const _hoursSales = [12, 28, 45, 38, 52, 62, 48, 35];

  static const _newOrders = <_SellerOrderStub>[
    _SellerOrderStub(
      id: 'TP-2041',
      summary: 'ข้าวซอยไก่ x2, ไข่ต้ม',
      status: 'ใหม่!',
      statusColor: TpColors.pink,
      elapsed: '1 นาที',
      price: 170,
    ),
    _SellerOrderStub(
      id: 'TP-2040',
      summary: 'แกงเหลือง x1',
      status: 'กำลังทำ',
      statusColor: TpColors.mango,
      elapsed: '8 นาที',
      price: 85,
    ),
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
              const Expanded(child: _StatCard(
                label: 'ยอดขายวันนี้',
                value: '฿3,820',
                delta: '↑ 18%',
                deltaColor: TpColors.mint,
                bg: Colors.white,
                fg: TpColors.ink,
              )),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'รอจัดส่ง',
                  value: '7',
                  delta: '⚡ 2 ด่วน →',
                  deltaColor: TpColors.mango,
                  bg: TpColors.ink,
                  fg: Colors.white,
                  onTap: () => context.go('/seller/orders'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SalesChartCard(
            bars: _hoursSales,
            onViewAll: () => context.go('/seller/reports'),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: '＋',
                  label: 'เพิ่มสินค้า',
                  color: TpColors.mint,
                  onTap: () => context.go('/seller/products/0'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickAction(
                  icon: '%',
                  label: 'โปรโมชัน',
                  color: TpColors.pink,
                  onTap: () => context.go('/seller/promos'),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _QuickAction(
                  icon: '💬',
                  label: 'แชท',
                  color: TpColors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickAction(
                  icon: '↓',
                  label: 'ถอน',
                  color: TpColors.mango,
                  onTap: () => context.go('/seller/withdraw'),
                ),
              ),
            ],
          ),
        ),
        const SectionHeader(
          titleTh: 'ออเดอร์ใหม่',
          titleEn: 'New orders',
          action: 'ทั้งหมด',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final order in _newOrders) ...[
                _OrderRow(
                  order: order,
                  onTap: () => context.go('/seller/orders/${order.id}'),
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

class _ShopHeader extends StatelessWidget {
  const _ShopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TpColors.mango, TpColors.tomato],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SELLER · ร้านค้า',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              letterSpacing: 1.5,
              color: Color(0xCC2A1F3D),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: TpShadows.claySm,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'ป',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: TpColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ครัวยายปราณี',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Thai',
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: TpColors.ink,
                      ),
                    ),
                    Text(
                      '● เปิดร้านอยู่ · 4.9★',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Thai',
                        fontSize: 11,
                        color: TpColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              // Toggle switch for open/closed.
              Container(
                width: 42,
                height: 24,
                decoration: BoxDecoration(
                  color: TpColors.mint,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: TpShadows.claySm,
                ),
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 3),
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.white,
                    ),
                  ),
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
  const _StatCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.deltaColor,
    required this.bg,
    required this.fg,
    this.onTap,
  });

  final String label;
  final String value;
  final String delta;
  final Color deltaColor;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      onTap: onTap,
      color: bg,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 9,
              letterSpacing: 1.5,
              color: fg.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: fg,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            delta,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Thai',
              fontSize: 11,
              color: deltaColor,
              fontWeight: FontWeight.w700,
            ),
          ),
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
              const Expanded(
                child: Text(
                  'ยอดขาย 8 ชม.ล่าสุด',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: TpColors.ink,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'ดูเพิ่ม →',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: TpColors.tomato,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: i == 5
                                ? const [TpColors.pink, Color(0xFF8A0030)]
                                : const [TpColors.mango, Color(0xFF7A5200)],
                          ),
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
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: TpShadows.claySm,
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: TpColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Thai',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: TpColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerOrderStub {
  const _SellerOrderStub({
    required this.id,
    required this.summary,
    required this.status,
    required this.statusColor,
    required this.elapsed,
    required this.price,
  });
  final String id;
  final String summary;
  final String status;
  final Color statusColor;
  final String elapsed;
  final int price;
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.onTap});
  final _SellerOrderStub order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${order.id}',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: TpColors.ink,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: order.statusColor,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: TpShadows.claySm,
                ),
                child: Text(
                  order.status,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            order.summary,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Thai',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: TpColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                order.elapsed,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  color: TpColors.muted,
                ),
              ),
              Text(
                '฿${order.price}',
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: TpColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Remaining seller pages — stubs (to be implemented per design spec)
// ═══════════════════════════════════════════════════════════════════════

class SellerOrdersPage extends StatelessWidget {
  const SellerOrdersPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '📦 ออเดอร์',
        subtitle: 'แท็บสถานะ: ใหม่ · กำลังทำ · จัดส่ง · เสร็จ · ยกเลิก',
        icon: Icons.shopping_bag_outlined,
      );
}

class SellerOrderDetailPage extends StatelessWidget {
  const SellerOrderDetailPage({super.key, required this.orderId});
  final int orderId;
  @override
  Widget build(BuildContext context) => UnderConstructionPage(
        title: 'ออเดอร์ #$orderId',
        subtitle: 'รายการ · ลูกค้า · action row: ยืนยัน / ปฏิเสธ',
        icon: Icons.receipt_long_rounded,
      );
}

class SellerProductsPage extends StatelessWidget {
  const SellerProductsPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '🛒 สินค้า',
        subtitle: 'Grid สินค้า · สต็อก · ปุ่มแก้ไข · เพิ่มสินค้า',
        icon: Icons.inventory_2_outlined,
      );
}

class SellerProductEditPage extends StatelessWidget {
  const SellerProductEditPage({super.key, required this.productId});
  final int productId;
  @override
  Widget build(BuildContext context) => UnderConstructionPage(
        title: 'แก้สินค้า #$productId',
        subtitle: 'อัปโหลดรูป 4 ช่อง · ชื่อ/ราคา/สต็อก/รายละเอียด/variants',
        icon: Icons.edit_note_rounded,
      );
}

class SellerPromosPage extends StatelessWidget {
  const SellerPromosPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '🎟️ โปรโมชั่น',
        subtitle: 'โปรที่ใช้งานอยู่ · สร้างโปรใหม่',
        icon: Icons.discount_outlined,
      );
}

class SellerReportsPage extends StatelessWidget {
  const SellerReportsPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '📊 รายงาน',
        subtitle: 'กราฟรายได้ 6 เดือน · สินค้าขายดี · Export',
        icon: Icons.bar_chart_rounded,
      );
}

class SellerWithdrawPage extends StatelessWidget {
  const SellerWithdrawPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '💸 ถอนเงิน',
        subtitle: 'บัญชีธนาคาร · จำนวนเงิน · quick-pick 1k/3k/all · ประวัติ',
        icon: Icons.account_balance_wallet_outlined,
      );
}
