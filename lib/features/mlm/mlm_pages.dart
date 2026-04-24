import 'package:flutter/material.dart';

import '../../shared/widgets/under_construction_page.dart';

/// MLM / Affiliate feature scaffold. See
/// `design_handoff_thaiprompt_marketplace/mlm-app.jsx` for canonical
/// reference. Existing `features/affiliate/affiliate_page.dart` will be
/// absorbed/extended into the Dashboard here in a later commit.

class MlmDashboardPage extends StatelessWidget {
  const MlmDashboardPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '🌳 MLM แดชบอร์ด',
        subtitle: 'ไทเออร์ · ความคืบหน้าสู่ไทเออร์ถัดไป · ดาวน์ไลน์ · คอมมิชชันเดือนนี้',
        icon: Icons.insights_rounded,
        onDark: true,
      );
}

class MlmTreePage extends StatelessWidget {
  const MlmTreePage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '🕸️ ทีม (Team Tree)',
        subtitle: 'Graph แบบต้นไม้ · แตะ node เพื่อเจาะลึก',
        icon: Icons.account_tree_rounded,
        onDark: true,
      );
}

class MlmEarningsPage extends StatelessWidget {
  const MlmEarningsPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '💎 รายได้ MLM',
        subtitle: 'ประวัติคอมมิชชัน · แยกตามเลเวล',
        icon: Icons.monetization_on_outlined,
        onDark: true,
      );
}

class MlmInvitePage extends StatelessWidget {
  const MlmInvitePage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '✉️ เชิญเพื่อน',
        subtitle: 'ลิงก์ส่วนตัว + QR + ปุ่มแชร์ · รายการที่เชิญ',
        icon: Icons.person_add_alt_rounded,
        onDark: true,
      );
}
