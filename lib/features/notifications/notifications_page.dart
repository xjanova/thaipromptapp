import 'package:flutter/material.dart';

import '../../shared/widgets/under_construction_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '🔔 การแจ้งเตือน',
        subtitle: 'ออเดอร์ · โปรโมชั่น · ระบบ · ส่วนลด',
        icon: Icons.notifications_outlined,
      );
}
