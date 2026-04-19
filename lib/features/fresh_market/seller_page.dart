import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/blob_3d.dart';
import '../../shared/widgets/clay_card.dart';
import 'fresh_market_repository.dart';
import 'widgets/listing_card.dart';

/// Seller profile + their latest active listings.
class TaladsodSellerPage extends ConsumerWidget {
  const TaladsodSellerPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(_sellerProvider(id));
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: profile.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: TpColors.leaf),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('โหลดข้อมูลผู้ขายไม่ได้\n$e',
                textAlign: TextAlign.center,
                style: TpText.bodySm.copyWith(color: TpColors.pink)),
          ),
        ),
        data: (p) => CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: TpColors.paper,
              foregroundColor: TpColors.ink,
              pinned: true,
              expandedHeight: 220,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: ClayCard(
                  padding: EdgeInsets.zero,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.arrow_back_rounded,
                        color: TpColors.ink),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [TpColors.leaf, Color(0xFFB6E08A)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 16),
                    child: Row(
                      children: [
                        ClipOval(
                          child: p.seller.shopImage != null &&
                                  p.seller.shopImage!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: p.seller.shopImage!,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Blob3D(
                                      size: 72, hue: BlobHue.mango),
                                  errorWidget: (_, __, ___) => const Blob3D(
                                      size: 72, hue: BlobHue.mango),
                                )
                              : const Blob3D(size: 72, hue: BlobHue.mango),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(p.seller.shopName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TpText.display3.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        )),
                                  ),
                                  if (p.seller.isVerified)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 6),
                                      child: Icon(Icons.verified,
                                          color: Colors.white, size: 18),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.seller.ratingAverage == null
                                    ? 'ยังไม่มีรีวิว'
                                    : '⭐ ${p.seller.ratingAverage!.toStringAsFixed(1)} · ${p.seller.ratingCount} รีวิว · ขายแล้ว ${p.seller.totalSales}',
                                style: TpText.bodySm.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (p.seller.shopDescription != null &&
                p.seller.shopDescription!.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    p.seller.shopDescription!,
                    style: TpText.bodyMd
                        .copyWith(color: TpColors.ink2, height: 1.5),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'สินค้าในร้าน (${p.listings.length})',
                  style: TpText.titleLg.copyWith(color: TpColors.ink),
                ),
              ),
            ),
            if (p.listings.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('ร้านนี้ยังไม่มีสินค้า',
                        style: TextStyle(color: TpColors.muted)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.66,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => ListingCard(
                      listing: p.listings[i],
                      showShopName: false,
                      onTap: () => context
                          .push('/taladsod/listings/${p.listings[i].id}'),
                    ),
                    childCount: p.listings.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final _sellerProvider =
    FutureProvider.family<TmSellerProfile, int>((ref, id) async {
  final repo = await ref.watch(freshMarketRepositoryProvider.future);
  return repo.seller(id);
});
