import 'package:flutter/material.dart';

import '../../shared/widgets/under_construction_page.dart';

/// Rider feature scaffold. See
/// `design_handoff_thaiprompt_marketplace/rider-app.jsx` for canonical
/// implementation. All pages are `onDark: true` to match the role's dark
/// page background.

class RiderDashboardPage extends StatelessWidget {
  const RiderDashboardPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '🗺️ งานด่วน · แผนที่',
        subtitle: 'Mini map A→B→C · active job card · accept/navigate',
        icon: Icons.map_rounded,
        onDark: true,
      );
}

class RiderJobsPage extends StatelessWidget {
  const RiderJobsPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '📋 คิวงาน',
        subtitle: 'ใกล้ฉัน · ราคาสูง · ด่วน · job cards (distance/fare/ETA)',
        icon: Icons.list_alt_rounded,
        onDark: true,
      );
}

class RiderJobDetailPage extends StatelessWidget {
  const RiderJobDetailPage({super.key, required this.jobId});
  final int jobId;
  @override
  Widget build(BuildContext context) => UnderConstructionPage(
        title: 'งาน #$jobId',
        subtitle: 'Full map · contact · pickup→dropoff timeline · action row',
        icon: Icons.directions_bike_rounded,
        onDark: true,
      );
}

class RiderEarningsPage extends StatelessWidget {
  const RiderEarningsPage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '💰 รายได้',
        subtitle: 'วัน/สัปดาห์/เดือน · bar chart · breakdown',
        icon: Icons.monetization_on_outlined,
        onDark: true,
      );
}

class RiderProfilePage extends StatelessWidget {
  const RiderProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '🪪 โปรไฟล์ไรเดอร์',
        subtitle: 'rating · ยานพาหนะ · สถานะเอกสาร · SOS',
        icon: Icons.person_outline_rounded,
        onDark: true,
      );
}
