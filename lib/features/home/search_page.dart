import 'package:flutter/material.dart';

import '../../shared/widgets/under_construction_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) => const UnderConstructionPage(
        title: '🔍 ค้นหา',
        subtitle: 'ยอดนิยม · ประวัติการค้น · ค้นข้อความ · ค้นด้วยรูปภาพ',
        icon: Icons.search_rounded,
      );
}
