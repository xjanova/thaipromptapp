import 'package:flutter/material.dart';

import '../../shared/widgets/under_construction_page.dart';

/// Checkout flow scaffold — 4-step stepper plus a receipt leaf.
///
/// Canonical reference: `design_handoff_thaiprompt_marketplace/buyer-app.jsx`
/// → `CkAddress`, `CkPayment`, `CkQR`, `BuyerPaid`, `CkReceipt`.

class CheckoutAddressPage extends StatelessWidget {
  const CheckoutAddressPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '1/4 · ที่อยู่จัดส่ง',
        subtitle: 'ชื่อ · เบอร์ · อาคาร · ตำบล/แขวง · จังหวัด (77)',
        icon: Icons.location_on_outlined,
      );
}

class CheckoutPaymentPage extends StatelessWidget {
  const CheckoutPaymentPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '2/4 · วิธีการชำระ',
        subtitle: 'PromptPay · บัตร · Wallet · โปรโมโค้ด',
        icon: Icons.payment_outlined,
      );
}

class CheckoutQrPage extends StatelessWidget {
  const CheckoutQrPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '3/4 · PromptPay QR',
        subtitle: 'QR code · นับถอยหลัง · ยกเลิก',
        icon: Icons.qr_code_2_rounded,
      );
}

class CheckoutPaidPage extends StatelessWidget {
  const CheckoutPaidPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '4/4 · ชำระสำเร็จ',
        subtitle: 'Confetti + scale-in check · ดูใบเสร็จ / ติดตามออเดอร์',
        icon: Icons.check_circle_outline_rounded,
      );
}

class CheckoutReceiptPage extends StatelessWidget {
  const CheckoutReceiptPage({super.key, required this.orderId});
  final int orderId;
  @override
  Widget build(BuildContext context) => UnderConstructionPage(
        title: 'ใบเสร็จ #$orderId',
        subtitle: 'รายละเอียดคำสั่งซื้อ · วิธีชำระ · ดาวน์โหลด PDF',
        icon: Icons.receipt_long_rounded,
      );
}
