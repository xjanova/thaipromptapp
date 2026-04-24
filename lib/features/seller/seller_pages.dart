import 'package:flutter/material.dart';

import '../../shared/widgets/under_construction_page.dart';

/// Seller feature — scaffold pages. All stubs during v1.0.22. Each page will
/// be fleshed out in subsequent commits per the design spec.
///
/// See `design_handoff_thaiprompt_marketplace/seller-app.jsx` for the
/// canonical reference implementations.

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '🏪 แดชบอร์ดร้านค้า',
        subtitle:
            'รายได้วันนี้ · กราฟรายชั่วโมง · ออเดอร์ล่าสุด · 4 quick-actions',
        icon: Icons.dashboard_rounded,
      );
}

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
