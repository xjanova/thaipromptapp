import 'package:flutter/material.dart';

import '../../shared/widgets/under_construction_page.dart';

/// Profile-family scaffold: main profile, address book, coupons. Each will
/// be fleshed out per the design spec.
///
/// Reference: `design_handoff_thaiprompt_marketplace/screens-c.jsx` and
/// `extra-screens.jsx`.

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '👤 โปรไฟล์',
        subtitle: 'ข้อมูลผู้ใช้ · ที่อยู่ · คูปอง · รีวิว · ออกจากระบบ',
        icon: Icons.person_outline_rounded,
      );
}

class AddressBookPage extends StatelessWidget {
  const AddressBookPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '📍 สมุดที่อยู่',
        subtitle: 'บ้าน · ที่ทำงาน · เพิ่มที่อยู่ใหม่',
        icon: Icons.home_work_outlined,
      );
}

class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '🎟️ คูปอง',
        subtitle: 'คูปองที่มี · คูปองที่ใช้แล้ว · ใส่โค้ด',
        icon: Icons.confirmation_number_outlined,
      );
}
