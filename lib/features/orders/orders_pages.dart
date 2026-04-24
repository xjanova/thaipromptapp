import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';

/// Buyer orders inbox — tabs + list of orders with status chips.
/// Reference: `buyer-app.jsx` → `BuyerOrders`.

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _tab = 0;
  static const _tabs = ['ทั้งหมด', 'กำลังมา', 'เสร็จแล้ว', 'ยกเลิก'];
  static const _orders = <_Order>[
    _Order(id: '#TP-8821', shop: 'ครัวยายปราณี', status: 'กำลังส่ง', statusColor: TpColors.mango, price: 185, icon: '🍜'),
    _Order(id: '#TP-8815', shop: 'ขนมไทยนิดา', status: 'ถึงแล้ว', statusColor: TpColors.mint, price: 120, icon: '🍰'),
    _Order(id: '#TP-8803', shop: 'ลุงโต ก๋วยเตี๋ยว', status: 'รอรีวิว', statusColor: TpColors.pink, price: 95, icon: '🍜'),
    _Order(id: '#TP-8790', shop: 'ร้านน้ำพริกป้าสม', status: 'ส่งเรียบร้อย', statusColor: TpColors.muted, price: 140, icon: '🌶'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.go('/buyer'),
                      child: const SizedBox(width: 34, height: 34, child: Icon(Icons.arrow_back_rounded, size: 18, color: TpColors.ink)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MY ORDERS', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, letterSpacing: 1.8, color: TpColors.muted, fontWeight: FontWeight.w600)),
                        Text('ออเดอร์ของฉัน', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w900, fontSize: 16, color: TpColors.ink)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _tab == i ? TpColors.deepInk : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: _tab == i ? TpShadows.claySm : null,
                        ),
                        child: Text(_tabs[i], style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w700, fontSize: 11, color: _tab == i ? TpColors.mango : TpColors.deepInk)),
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
                  for (final o in _orders) ...[
                    ClayCard(
                      onTap: () => context.go('/buyer/tracking/8821'),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: o.statusColor, borderRadius: BorderRadius.circular(14)),
                            alignment: Alignment.center,
                            child: Text(o.icon, style: const TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(o.shop, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w800, fontSize: 13, color: TpColors.ink)),
                                Text(o.id, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TpColors.muted)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('฿${o.price}', style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 16, fontWeight: FontWeight.w900, color: TpColors.ink)),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: o.statusColor, borderRadius: BorderRadius.circular(999)),
                                child: Text(o.status, style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 9, fontWeight: FontWeight.w800, color: o.statusColor == TpColors.mango ? TpColors.deepInk : Colors.white)),
                              ),
                            ],
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

class _Order {
  const _Order({required this.id, required this.shop, required this.status, required this.statusColor, required this.price, required this.icon});
  final String id, shop, status, icon;
  final Color statusColor;
  final int price;
}
