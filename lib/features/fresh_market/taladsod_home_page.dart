import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/models/fresh_market.dart';
import '../../shared/widgets/blob_3d.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/section_header.dart';
import 'fresh_market_repository.dart';
import 'widgets/listing_card.dart';

/// Landing for the Fresh Market (ตลาดสด) experience.
///
/// Layout (top→bottom):
///   1. Curved leaf-green hero banner with title + tagline + search CTA
///   2. Categories strip (horizontal pill list of category icons)
///   3. "สินค้าใหม่ล่าสุด" section — paginated listings, page 1
class TaladsodHomePage extends ConsumerWidget {
  const TaladsodHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(fmCategoriesProvider);
    final listings = ref.watch(fmRecentListingsProvider);

    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: TpColors.leaf,
          onRefresh: () async {
            ref.invalidate(fmCategoriesProvider);
            ref.invalidate(fmRecentListingsProvider);
            await Future.wait([
              ref.read(fmCategoriesProvider.future),
              ref.read(fmRecentListingsProvider.future),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const _Hero(),
              const SizedBox(height: 16),
              SectionHeader(
                titleTh: 'หมวดหมู่',
                titleEn: 'Categories',
                action: categories.maybeWhen(
                  data: (cs) => cs.isEmpty ? null : 'ทั้งหมด',
                  orElse: () => null,
                ),
                onActionTap: () => context.push('/taladsod/listings'),
              ),
              SizedBox(
                height: 96,
                child: categories.when(
                  loading: () => _CategoriesPlaceholder(),
                  error: (e, _) => _ErrorRow(message: '$e'),
                  data: (items) => items.isEmpty
                      ? _EmptyHint(
                          icon: Icons.category_outlined,
                          text: 'ยังไม่มีหมวดหมู่ · รอผู้ขายเปิดร้าน',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => _CategoryPill(
                            category: items[i],
                            onTap: () => context.push(
                              '/taladsod/listings?category=${items[i].id}',
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              SectionHeader(
                titleTh: 'สินค้าใหม่ล่าสุด',
                titleEn: 'Fresh today',
                action: 'ดูทั้งหมด',
                onActionTap: () => context.push('/taladsod/listings'),
              ),
              listings.when(
                loading: () => const _ListingsPlaceholder(),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ErrorRow(message: '$e'),
                ),
                data: (page) => page.items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: _EmptyHint(
                          icon: Icons.shopping_basket_outlined,
                          text: 'ตอนนี้ยังไม่มีสินค้าในตลาด',
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.66,
                          ),
                          itemCount: page.items.length,
                          itemBuilder: (_, i) => ListingCard(
                            listing: page.items[i],
                            onTap: () => context.push(
                              '/taladsod/listings/${page.items[i].id}',
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [TpColors.leaf, Color(0xFF9CD66A)],
            ),
            borderRadius: BorderRadius.circular(TpRadii.chunk),
            boxShadow: TpShadows.clayLg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🥬', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'ตลาดสดไทยพร๊อม',
                          style: TpText.titleLg.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ของสด · ส่งตรงจากร้านในย่านบ้านคุณ',
                      style: TpText.bodySm.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () =>
                          GoRouter.of(context).push('/taladsod/listings'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(TpRadii.button),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search,
                                size: 18, color: TpColors.leaf),
                            const SizedBox(width: 6),
                            Text(
                              'ค้นหาผัก ผลไม้ เนื้อสัตว์ ...',
                              style: TpText.bodySm.copyWith(
                                color: TpColors.ink2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Blob3D(size: 64, hue: BlobHue.leaf),
            ],
          ),
        ),
        Positioned(
          top: 6,
          left: 24,
          child: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: ClayCard(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 20, color: TpColors.ink),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category, required this.onTap});
  final TmCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 86,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: TpColors.card,
          borderRadius: BorderRadius.circular(TpRadii.medium),
          boxShadow: TpShadows.claySm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (category.imageUrl != null && category.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: category.imageUrl!,
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      const Blob3D(size: 38, hue: BlobHue.mint),
                  errorWidget: (_, __, ___) =>
                      Text(category.icon ?? '🌿',
                          style: const TextStyle(fontSize: 26)),
                ),
              )
            else
              Text(
                _categoryEmoji(category),
                style: const TextStyle(fontSize: 26),
              ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TpText.bodyXs.copyWith(
                  color: TpColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryEmoji(TmCategory c) {
    if (c.icon != null && c.icon!.isNotEmpty) return c.icon!;
    // Fallback: pick emoji deterministically from category id so the same
    // category always shows the same icon when none is provided.
    const fallbacks = ['🥬', '🍅', '🥕', '🍌', '🍚', '🐟', '🥩', '🥚'];
    return fallbacks[c.id.abs() % fallbacks.length];
  }
}

// ---------------------------------------------------------------------------
// Loading + empty + error helpers
// ---------------------------------------------------------------------------

class _CategoriesPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => Container(
        width: 86,
        decoration: BoxDecoration(
          color: TpColors.card,
          borderRadius: BorderRadius.circular(TpRadii.medium),
          boxShadow: TpShadows.claySm,
        ),
      ),
    );
  }
}

class _ListingsPlaceholder extends StatelessWidget {
  const _ListingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.66,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: TpColors.card,
            borderRadius: BorderRadius.circular(TpRadii.medium),
            boxShadow: TpShadows.claySm,
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: TpColors.muted),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TpText.bodySm.copyWith(color: TpColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        'โหลดข้อมูลไม่สำเร็จ — ${message.length > 80 ? "${message.substring(0, 80)}..." : message}',
        style: TpText.bodySm.copyWith(color: TpColors.pink),
      ),
    );
  }
}
