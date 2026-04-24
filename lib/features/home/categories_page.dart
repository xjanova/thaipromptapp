import 'package:flutter/material.dart';

import '../../shared/widgets/under_construction_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '🧩 หมวดสินค้า',
        subtitle: 'อาหาร · ขนม · เครื่องดื่ม · หัตถกรรม · แฟชั่น · เกษตร · ของใช้',
        icon: Icons.grid_view_rounded,
      );
}
