import 'package:flutter/material.dart';

import '../../shared/widgets/under_construction_page.dart';

/// Orders feature — consolidates the `fresh_market/my_orders_page.dart` into
/// a buyer-wide /buyer/orders inbox per the design spec. Existing fresh-market
/// orders remain accessible at `/taladsod/orders` until merged.

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '📦 คำสั่งซื้อ',
        subtitle: 'สถานะ: รอชำระ · รอจัดส่ง · กำลังส่ง · เสร็จสิ้น · ยกเลิก',
        icon: Icons.shopping_bag_outlined,
      );
}
