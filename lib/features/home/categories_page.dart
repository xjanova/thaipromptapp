import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';

/// Categories page — 2-column grid of 8 category tiles, each a solid color
/// claymorphic card with emoji icon, Thai name, and shop-count label.
///
/// Reference: `design_handoff_thaiprompt_marketplace/buyer-app.jsx`
/// → `BuyerCategories`.
///
/// TODO(v1.0.23+): wire to `/v1/app/categories` so shop counts come from
/// the backend (currently static stub matching the mockup).
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  static const _categories = <_CatItem>[
    _CatItem('🍜', 'อาหาร', TpColors.pink, 240, '/buyer/categories/food'),
    _CatItem('🍰', 'ขนม', TpColors.mango, 182, '/buyer/categories/sweet'),
    _CatItem('🥤', 'เครื่องดื่ม', TpColors.mint, 98, '/buyer/categories/drink'),
    _CatItem('🧺', 'หัตถกรรม', TpColors.purple, 64, '/buyer/categories/craft'),
    _CatItem('👗', 'แฟชั่น', TpColors.tomato, 120, '/buyer/categories/fashion'),
    _CatItem('🌿', 'เกษตร', Color(0xFF2F7A5F), 56, '/buyer/categories/farm'),
    _CatItem('🧴', 'ความงาม', Color(0xFFE4405F), 42, '/buyer/categories/beauty'),
    _CatItem('📚', 'ของใช้', Color(0xFFC9B8FF), 88, '/buyer/categories/goods'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.35,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final c = _categories[i];
                    return _CategoryTile(
                      item: c,
                      onTap: () {
                        // Route to listings filtered by this category.
                        // Reuse existing /taladsod/listings for now until the
                        // marketplace listings endpoint lands.
                        context.go('/buyer');
                      },
                    );
                  },
                  childCount: _categories.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.go('/buyer'),
              child: const SizedBox(
                width: 34,
                height: 34,
                child: Icon(Icons.arrow_back_rounded,
                    size: 18, color: TpColors.ink),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CATEGORIES',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 9,
                    letterSpacing: 1.8,
                    color: TpColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'หมวดสินค้าทั้งหมด',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: TpColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatItem {
  const _CatItem(this.icon, this.name, this.color, this.shops, this.route);
  final String icon;
  final String name;
  final Color color;
  final int shops;
  final String route;
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.item, required this.onTap});

  final _CatItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Mango tiles use ink text; all other colors use white text.
    final onMango = item.color == TpColors.mango;
    final fg = onMango ? TpColors.deepInk : Colors.white;

    return ClayCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      radius: 18,
      color: item.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 30, height: 1.0)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Thai',
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: fg,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.shops} ร้าน',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  color: fg.withValues(alpha: 0.85),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
