import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/models/commerce.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/iso_stall.dart';
import '../../shared/widgets/puff.dart';
import '../../shared/widgets/puffy_button.dart';
import 'shop_repository.dart';

/// Port of `Shop` in screens-a.jsx.
class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key, required this.shopId});
  final int shopId;

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> {
  int _tabIndex = 0;
  static const _tabs = ['สินค้า', 'รีวิว', 'โปรโมชัน'];

  @override
  Widget build(BuildContext context) {
    final asyncShop = ref.watch(shopDetailProvider(widget.shopId));
    final asyncProducts = ref.watch(shopProductsProvider(widget.shopId));

    return Scaffold(
      backgroundColor: TpColors.paper,
      body: asyncShop.when(
        loading: () => const Center(child: CircularProgressIndicator(color: TpColors.pink)),
        error: (e, _) => Center(child: Text('เกิดข้อผิดพลาด: $e', style: TpText.bodyMd)),
        data: (shop) => ListView(
          padding: EdgeInsets.zero,
          children: [
            _Cover(),
            _ProfileOverlap(shop: shop),
            _Stats(shop: shop),
            const SizedBox(height: 8),
            _CtaRow(),
            const SizedBox(height: 8),
            _Tabs(
              index: _tabIndex,
              onChange: (i) => setState(() => _tabIndex = i),
            ),
            const SizedBox(height: 12),
            if (_tabIndex == 0)
              asyncProducts.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: TpColors.pink)),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('โหลดสินค้าไม่ได้: $e', style: TpText.bodySm),
                ),
                data: (products) => _ProductGrid(products: products),
              )
            else
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text('เร็ว ๆ นี้ ·  ${_tabs[_tabIndex]}',
                      style: TpText.bodyMd.copyWith(color: TpColors.muted)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.7, -1),
                  end: Alignment(0.7, 1),
                  colors: [TpColors.purple, TpColors.pink],
                ),
              ),
            ),
          ),
          Positioned(
            right: -30,
            top: -20,
            child: Transform.rotate(
              angle: 0.21,
              child: const Opacity(
                opacity: 0.9,
                child: IsoStall(width: 240, height: 200),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PillButton(icon: Icons.arrow_back_rounded, onTap: () => context.pop()),
                  _PillButton(icon: Icons.more_horiz_rounded, onTap: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: TpColors.paper,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              offset: const Offset(0, 4),
              blurRadius: 8,
              spreadRadius: -2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: TpColors.ink),
      ),
    );
  }
}

class _ProfileOverlap extends StatelessWidget {
  const _ProfileOverlap({required this.shop});
  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final initial = shop.name.isEmpty ? '?' : shop.name.characters.first;
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClayCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Transform.translate(
                offset: const Offset(0, -36),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: TpColors.mango,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(initial, style: TpText.display2.copyWith(fontSize: 30)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VERIFIED SELLER · LV ${shop.verifiedLevel ?? 1}',
                      style: TpText.monoLabel,
                    ),
                    const SizedBox(height: 2),
                    Text(shop.name, style: TpText.titleLg.copyWith(fontSize: 17, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (shop.rating != null) '★ ${shop.rating!.toStringAsFixed(1)}',
                        '${shop.orderCount} คำสั่งซื้อ',
                        if (shop.replyWithinMinutes != null)
                          'ตอบใน ${shop.replyWithinMinutes} นาที',
                      ].join(' · '),
                      style: TpText.bodyXs,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.shop});
  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final items = [
      ['${shop.followerCount}', 'ตามแล้ว'],
      ['${shop.productCount}', 'สินค้า'],
      [
        shop.reviewReplyPercent == null ? '—' : '${shop.reviewReplyPercent!.toStringAsFixed(0)}%',
        'ตอบรีวิว',
      ],
    ];
    return Transform.translate(
      offset: const Offset(0, -28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: TpColors.mangoTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(items[i][0], style: TpText.display4.copyWith(fontSize: 18)),
                      Text(
                        items[i][1],
                        style: TpText.bodyXs.copyWith(
                          fontSize: 10,
                          color: TpColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (i < items.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _CtaRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: PuffyButton(
                label: '＋ ติดตาม',
                variant: PuffyVariant.pink,
                fullWidth: true,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PuffyButton(
                label: '💬 แชท',
                variant: PuffyVariant.ghost,
                fullWidth: true,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.index, required this.onChange});
  final int index;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    const labels = ['สินค้า', 'รีวิว', 'โปรโมชัน'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            _TabChip(label: labels[i], active: i == index, onTap: () => onChange(i)),
            if (i < labels.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? TpColors.deepInk : TpColors.card,
          borderRadius: BorderRadius.circular(999),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TpText.bodySm.copyWith(
            color: active ? TpColors.mango : TpColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('ร้านยังไม่มีสินค้า', style: TpText.bodyMd.copyWith(color: TpColors.muted)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => _ProductTile(product: products[i]),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final isEven = product.id.isEven;
    return ClayCard(
      padding: EdgeInsets.zero,
      clipChildren: true,
      onTap: () => context.go('/product/${product.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 110,
            color: isEven ? TpColors.mintTint : TpColors.pinkTint,
            child: Center(child: Puff(width: 100, height: 70, hue: product.hue)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TpText.titleSm.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('฿${product.priceThb.toStringAsFixed(0)}',
                        style: TpText.display4.copyWith(fontSize: 14)),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: TpColors.pink,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
