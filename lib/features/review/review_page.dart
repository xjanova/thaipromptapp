import 'package:flutter/material.dart';

import '../../shared/widgets/under_construction_page.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key, required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context) => UnderConstructionPage(
        title: '⭐ รีวิว · ออเดอร์ #$orderId',
        subtitle: 'ดาว 1-5 · รูปถ่าย · ข้อความ · ตอบกลับร้าน',
        icon: Icons.star_outline_rounded,
      );
}
