import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_state.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../shared/models/fresh_market.dart';
import '../../shared/widgets/blob_3d.dart';
import '../../shared/widgets/chip_tag.dart' show TpChip;
import '../../shared/widgets/clay_card.dart';
import 'fresh_market_repository.dart';
import 'order_sheet.dart';
import 'widgets/listing_card.dart';

/// Detail screen for a single fresh-market listing.
///
/// Layout:
///   - Hero image carousel
///   - Title + price/unit + organic + freshness chips
///   - Seller card (tap → seller profile)
///   - Description
///   - Stats (views / orders / cashback)
///   - Related listings strip
///   - Sticky bottom CTA: "สั่งซื้อ" — opens [OrderSheet]
class TaladsodListingDetailPage extends ConsumerWidget {
  const TaladsodListingDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_listingDetailProvider(id));

    return Scaffold(
      backgroundColor: TpColors.paper,
      body: detail.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: TpColors.leaf)),
        error: (e, _) => _ErrorView(
          error: '$e',
          onRetry: () => ref.invalidate(_listingDetailProvider(id)),
        ),
        data: (d) => _DetailBody(detail: d),
      ),
    );
  }
}

final _listingDetailProvider =
    FutureProvider.family<TmListingDetail, int>((ref, id) async {
  final repo = await ref.watch(freshMarketRepositoryProvider.future);
  return repo.listingDetail(id);
});

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.detail});
  final TmListingDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = detail.listing;
    final auth = ref.watch(authControllerProvider);
    final isAuth = auth is AuthAuthenticated;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: TpColors.paper,
              foregroundColor: TpColors.ink,
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _Hero(listing: l),
              ),
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
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (l.isOrganic)
                            const TpChip(
                              label: '🌱 ออร์แกนิก',
                              color: Color(0xFFE5F6CC),
                              textColor: Color(0xFF3E6B0A),
                              small: true,
                            ),
                          if (l.freshnessLevel != null &&
                              l.freshnessLevel!.isNotEmpty)
                            TpChip(
                              label: '✨ ${l.freshnessLevel!}',
                              color: TpColors.mintTint,
                              textColor: TpColors.mint,
                              small: true,
                            ),
                          if (l.distanceKm != null)
                            TpChip(
                              label: '📍 ${formatDistance(l.distanceKm!)}',
                              color: TpColors.paper2,
                              textColor: TpColors.ink2,
                              small: true,
                            ),
                          if (l.cashbackAmount != null && l.cashbackAmount! > 0)
                            TpChip(
                              label:
                                  '🪙 Cashback ${formatBaht(l.cashbackAmount!)}',
                              color: TpColors.mangoTint,
                              textColor: const Color(0xFF8C6F00),
                              small: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(l.title,
                          style: TpText.display3
                              .copyWith(color: TpColors.ink, height: 1.2)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatBaht(l.price, decimals: l.price % 1 != 0),
                              style: TpText.display1
                                  .copyWith(color: TpColors.leaf)),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('/ ${l.unit}',
                                style: TpText.bodyMd
                                    .copyWith(color: TpColors.muted)),
                          ),
                          if (l.hasDiscount) ...[
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                formatBaht(l.compareAtPrice!, decimals: true),
                                style: TpText.bodySm.copyWith(
                                  color: TpColors.muted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.inStock
                            ? 'มีสินค้า ${l.quantityAvailable} ${l.unit}'
                            : 'หมดสต็อก',
                        style: TpText.bodySm.copyWith(
                          color: l.inStock ? TpColors.mint : TpColors.pink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (detail.seller != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClayCard(
                      onTap: () => context.push(
                          '/taladsod/sellers/${detail.seller!.id}'),
                      child: Row(
                        children: [
                          ClipOval(
                            child: detail.seller!.shopImage != null &&
                                    detail.seller!.shopImage!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: detail.seller!.shopImage!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Blob3D(
                                        size: 48, hue: BlobHue.mango),
                                    errorWidget: (_, __, ___) => const Blob3D(
                                        size: 48, hue: BlobHue.mango),
                                  )
                                : const Blob3D(size: 48, hue: BlobHue.mango),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        detail.seller!.shopName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TpText.bodyMd.copyWith(
                                          color: TpColors.ink,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    if (detail.seller!.isVerified)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 4),
                                        child: Icon(Icons.verified,
                                            size: 16, color: TpColors.sky),
                                      ),
                                  ],
                                ),
                                Text(
                                  detail.seller!.ratingAverage == null
                                      ? 'ยังไม่มีรีวิว'
                                      : '⭐ ${detail.seller!.ratingAverage!.toStringAsFixed(1)} · ${detail.seller!.ratingCount} รีวิว',
                                  style: TpText.bodyXs
                                      .copyWith(color: TpColors.muted),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: TpColors.muted),
                        ],
                      ),
                    ),
                  ),
                ],
                if (l.description != null && l.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('รายละเอียด',
                            style: TpText.titleLg.copyWith(color: TpColors.ink)),
                        const SizedBox(height: 6),
                        Text(l.description!,
                            style: TpText.bodyMd
                                .copyWith(color: TpColors.ink2, height: 1.5)),
                      ],
                    ),
                  ),
                ],
                if (detail.related.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('สินค้าที่เกี่ยวข้อง',
                        style: TpText.titleLg.copyWith(color: TpColors.ink)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemCount: detail.related.length,
                      itemBuilder: (_, i) {
                        final r = detail.related[i];
                        return SizedBox(
                          width: 130,
                          child: GestureDetector(
                            onTap: () =>
                                context.push('/taladsod/listings/${r.id}'),
                            child: Container(
                              decoration: BoxDecoration(
                                color: TpColors.card,
                                borderRadius:
                                    BorderRadius.circular(TpRadii.medium),
                                boxShadow: TpShadows.claySm,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: r.mainImageUrl != null &&
                                            r.mainImageUrl!.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: r.mainImageUrl!,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) =>
                                                const ColoredBox(
                                                    color: TpColors.paper2),
                                            errorWidget: (_, __, ___) =>
                                                const Center(
                                                    child: Blob3D(
                                                        size: 48,
                                                        hue: BlobHue.leaf)),
                                          )
                                        : const Center(
                                            child: Blob3D(
                                                size: 48, hue: BlobHue.leaf)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8, 6, 8, 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(r.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TpText.bodySm.copyWith(
                                                color: TpColors.ink,
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 2),
                                        Text(
                                            '${formatBaht(r.price)} / ${r.unit}',
                                            style: TpText.bodyXs.copyWith(
                                                color: TpColors.leaf,
                                                fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 120),
              ]),
            ),
          ],
        ),
        // Sticky bottom CTA
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: TpColors.paper,
              boxShadow: [
                BoxShadow(
                  color: TpColors.ink.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _LeafCtaButton(
                    label: l.inStock ? 'สั่งซื้อ' : 'หมดสต็อก',
                    enabled: l.inStock,
                    onPressed: () => _onOrderTap(context, isAuth),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onOrderTap(BuildContext context, bool isAuth) {
    if (!isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบเพื่อสั่งซื้อ')),
      );
      context.push('/login');
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderSheet(detail: detail),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.listing});
  final TmListing listing;

  @override
  Widget build(BuildContext context) {
    final imgs = [
      if (listing.mainImageUrl != null && listing.mainImageUrl!.isNotEmpty)
        listing.mainImageUrl!,
      ...listing.images,
    ].toSet().toList(); // de-dupe in case main is also in images[]

    if (imgs.isEmpty) {
      return Container(
        color: TpColors.paper2,
        child: Center(
          child: Blob3D(size: 140, hue: listingHueFor(listing.id)),
        ),
      );
    }

    return PageView.builder(
      itemCount: imgs.length,
      itemBuilder: (_, i) => CachedNetworkImage(
        imageUrl: imgs[i],
        fit: BoxFit.cover,
        placeholder: (_, __) => const ColoredBox(color: TpColors.paper2),
        errorWidget: (_, __, ___) => Container(
          color: TpColors.paper2,
          child: Center(
            child: Blob3D(size: 100, hue: listingHueFor(listing.id)),
          ),
        ),
      ),
    );
  }
}

/// Leaf-themed pill button used as the primary CTA on this screen and in
/// [OrderSheet]. PuffyButton's preset variants don't include leaf, so we
/// inline a thin clay-shadowed button matching the rest of taladsod.
class _LeafCtaButton extends StatelessWidget {
  const _LeafCtaButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? TpColors.leaf : TpColors.muted,
          borderRadius: BorderRadius.circular(TpRadii.button),
          boxShadow: enabled ? TpShadows.clay : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TpText.bodyMd.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: TpColors.pink),
              const SizedBox(height: 12),
              Text('โหลดสินค้านี้ไม่ได้',
                  style: TpText.titleLg.copyWith(color: TpColors.ink)),
              const SizedBox(height: 8),
              Text(
                error.length > 120 ? '${error.substring(0, 120)}...' : error,
                textAlign: TextAlign.center,
                style: TpText.bodySm.copyWith(color: TpColors.muted),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('ลองใหม่')),
            ],
          ),
        ),
      ),
    );
  }
}
