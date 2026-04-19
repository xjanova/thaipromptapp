import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_state.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/blob_3d.dart';
import '../../shared/widgets/chip_tag.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/coin.dart';
import '../../shared/widgets/iso_stall.dart';
import '../../shared/widgets/marquee.dart';
import '../../shared/widgets/nav_dock.dart';
import '../../shared/widgets/puff.dart';
import '../../shared/widgets/puffy_button.dart';
import '../../shared/widgets/section_header.dart';

/// Port of `Home` in screens-a.jsx.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final userName = auth is AuthAuthenticated ? auth.user.name : 'ลูกค้า';

    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                const SizedBox(height: 8),
                _TopBar(userName: userName),
                const SizedBox(height: 12),
                const _SearchBar(),
                const SizedBox(height: 12),
                const _TodayHero(),
                const SizedBox(height: 10),
                const _WalletAffiliateRow(),
                const SectionHeader(
                  titleTh: 'หมวดหมู่',
                  titleEn: 'Categories',
                  action: 'ทั้งหมด',
                ),
                const _CategoryMarquee(),
                const SectionHeader(
                  titleTh: 'ใกล้บ้าน',
                  titleEn: 'Near you · 2.4km',
                  action: 'แผนที่',
                ),
                const _NearbyRow(),
                const SectionHeader(
                  titleTh: 'ร้านแนะนำวันนี้',
                  titleEn: 'Featured shop',
                ),
                const _FeaturedShop(),
                const SizedBox(height: 20),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: NavDock(
                active: NavTab.home,
                onChange: (t) {
                  switch (t) {
                    case NavTab.wallet:
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Wallet · Phase 3')),
                      );
                    case NavTab.affiliate:
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Affiliate · Phase 3')),
                      );
                    case NavTab.menu:
                    case NavTab.me:
                    case NavTab.home:
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// Top bar
// ------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.userName});
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TpColors.mango,
              borderRadius: BorderRadius.circular(14),
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
            child: Text('ส', style: TpText.display4.copyWith(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('BANGKOK · CHATUCHAK', style: TpText.monoLabel),
                Text('สวัสดี, $userName 👋', style: TpText.greet),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.go('/cart'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                    child: const Icon(Icons.shopping_basket_outlined, size: 18),
                  ),
                ),
              ),
              const Positioned(
                top: -6,
                right: -6,
                child: _NotificationDot(count: 3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(color: TpColors.pink, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TpText.bodyXs.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// Search
// ------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ClayCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shadow: ClayShadow.small,
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 18, color: TpColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ค้นหาของอร่อย ร้านใกล้บ้าน...',
                      style: TpText.bodySm.copyWith(color: TpColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          PuffyButton(
            label: '',
            icon: Icons.tune_rounded,
            variant: PuffyVariant.mint,
            size: PuffySize.small,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// Hero — Today's market
// ------------------------------------------------------------------

class _TodayHero extends StatelessWidget {
  const _TodayHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClayCard(
        gradient: TpGradients.todayHero,
        padding: const EdgeInsets.all(16),
        shadow: ClayShadow.large,
        clipChildren: true,
        child: SizedBox(
          height: 160,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -40,
                bottom: -20,
                child: Transform.scale(
                  scale: 0.95,
                  child: const IsoStall(width: 240, height: 180),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TpChip(label: '🔥 ตลาดวันนี้', color: TpColors.mango),
                  const SizedBox(height: 10),
                  Text(
                    'ตลาดนัดคลองเตย\nเปิดแล้ว!',
                    style: TpText.display3.copyWith(
                      color: Colors.white,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '128 ร้าน · ส่งฟรีในรัศมี 3km',
                    style: TpText.bodyXs.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) => PuffyButton(
                      label: 'เข้าตลาด →',
                      variant: PuffyVariant.ink,
                      size: PuffySize.small,
                      onPressed: () => context.go('/shop/1'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// Wallet + Affiliate mini widgets
// ------------------------------------------------------------------

class _WalletAffiliateRow extends StatelessWidget {
  const _WalletAffiliateRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          Expanded(flex: 13, child: _WalletMini()),
          SizedBox(width: 10),
          Expanded(flex: 10, child: _AffiliateMini()),
        ],
      ),
    );
  }
}

class _WalletMini extends StatelessWidget {
  const _WalletMini();

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      color: TpColors.deepInk,
      padding: const EdgeInsets.all(14),
      clipChildren: true,
      child: SizedBox(
        height: 98,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MY WALLET',
                    style: TpText.monoLabelSm.copyWith(color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('฿2,481',
                        style: TpText.bigNum.copyWith(color: Colors.white, fontSize: 22)),
                    Text('.50',
                        style: TpText.bodyXs.copyWith(color: Colors.white.withValues(alpha: 0.6))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    PuffyButton(
                      label: '+ เติม',
                      variant: PuffyVariant.mango,
                      size: PuffySize.small,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('ถอน',
                          style: TpText.btnSm.copyWith(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: -10,
              top: -10,
              child: Opacity(opacity: 0.9, child: const Coin(size: 60)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AffiliateMini extends StatelessWidget {
  const _AffiliateMini();

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      color: TpColors.mint,
      padding: const EdgeInsets.all(14),
      clipChildren: true,
      child: SizedBox(
        height: 98,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('AFFILIATE',
                    style: TpText.monoLabelSm.copyWith(color: const Color(0xFF003028))),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('+฿420',
                        style: TpText.bigNum.copyWith(fontSize: 20, color: TpColors.ink)),
                    Text(' /wk',
                        style: TpText.bodyXs.copyWith(
                          color: TpColors.ink.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
                const SizedBox(height: 6),
                Text('🥈 Silver · 8.5%',
                    style: TpText.bodyXs.copyWith(
                      color: const Color(0xFF003028),
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            Positioned(
              right: -14,
              bottom: -14,
              child: Transform(
                transform: _rotate8,
                child: const Blob3D(size: 60, hue: BlobHue.purple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final Matrix4 _rotate8 = Matrix4.rotationZ(-0.14);
}

// ------------------------------------------------------------------
// Categories marquee
// ------------------------------------------------------------------

class _CategoryMarquee extends StatelessWidget {
  const _CategoryMarquee();

  static const _cats = [
    _CatItem('ผัก-ผลไม้', 'Produce', BlobHue.leaf),
    _CatItem('อาหารสด', 'Cooked', BlobHue.tomato),
    _CatItem('ขนม', 'Sweet', BlobHue.mango),
    _CatItem('งานแฮนด์เมด', 'Craft', BlobHue.purple),
    _CatItem('ของมือสอง', 'Thrift', BlobHue.pink),
    _CatItem('ต้นไม้', 'Plants', BlobHue.mint),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Marquee(
        children: [for (final c in _cats) _CategoryCard(cat: c)],
      ),
    );
  }
}

class _CatItem {
  const _CatItem(this.th, this.en, this.hue);
  final String th;
  final String en;
  final BlobHue hue;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.cat});
  final _CatItem cat;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      color: TpColors.card,
      padding: const EdgeInsets.all(12),
      shadow: ClayShadow.small,
      child: SizedBox(
        width: 84,
        height: 94,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Puff(width: 68, height: 52, hue: cat.hue),
            const SizedBox(height: 12),
            Text(cat.th, style: TpText.titleSm),
            Text(cat.en, style: TpText.monoLabelSm),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// Nearby shops row
// ------------------------------------------------------------------

class _NearbyRow extends StatelessWidget {
  const _NearbyRow();

  static const _shops = [
    _ShopItem('ป้าสม ผักสด', 'Produce', '120m', '4.9', BlobHue.leaf),
    _ShopItem('ลุงโต ก๋วยเตี๋ยว', 'Noodles', '340m', '4.8', BlobHue.tomato),
    _ShopItem('น้องฟ้า ขนมไทย', 'Sweets', '580m', '5.0', BlobHue.mango),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _shops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _NearbyCard(shop: _shops[i]),
      ),
    );
  }
}

class _ShopItem {
  const _ShopItem(this.name, this.type, this.dist, this.rating, this.hue);
  final String name;
  final String type;
  final String dist;
  final String rating;
  final BlobHue hue;
}

class _NearbyCard extends StatelessWidget {
  const _NearbyCard({required this.shop});
  final _ShopItem shop;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: EdgeInsets.zero,
      clipChildren: true,
      onTap: () => context.go('/shop/${shop.name.hashCode.abs() % 100 + 1}'),
      child: SizedBox(
        width: 180,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(-0.7, -1),
                          end: const Alignment(0.7, 1),
                          colors: const [Color(0xFFFFE8F0), Color(0xFFFFF0C7)],
                        ),
                      ),
                    ),
                  ),
                  Center(child: Puff(width: 120, height: 80, hue: shop.hue)),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: TpColors.deepInk,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '★ ${shop.rating}',
                        style: TpText.bodyXs.copyWith(
                          color: TpColors.mango,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(shop.name, style: TpText.titleMd.copyWith(fontSize: 13)),
                  Text('${shop.type} · ${shop.dist}', style: TpText.monoLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// Featured shop
// ------------------------------------------------------------------

class _FeaturedShop extends StatelessWidget {
  const _FeaturedShop();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: ClayCard(
        color: TpColors.mango,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment(-0.7, -1),
                  end: Alignment(0.7, 1),
                  colors: [Color(0xFFFFE3D6), Color(0xFFFF7A3A)],
                ),
              ),
              alignment: Alignment.center,
              child: const Puff(width: 58, height: 44, hue: BlobHue.tomato),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ครัวยายปราณี',
                      style: TpText.titleLg.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('อาหารใต้ · เปิด 7:00-19:00',
                      style: TpText.bodyXs),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      TpChip(label: 'ส่งฟรี', small: true),
                      SizedBox(width: 6),
                      TpChip(label: 'เปิดอยู่', small: true),
                    ],
                  ),
                ],
              ),
            ),
            PuffyButton(
              label: 'เข้าร้าน',
              variant: PuffyVariant.ink,
              size: PuffySize.small,
              onPressed: () => context.go('/shop/1'),
            ),
          ],
        ),
      ),
    );
  }
}
