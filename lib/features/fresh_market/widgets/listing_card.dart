import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/format.dart';
import '../../../shared/models/fresh_market.dart';
import '../../../shared/widgets/blob_3d.dart';
import '../../../shared/widgets/chip_tag.dart' show TpChip;

/// Reusable card for a single fresh-market listing — used on Home grid,
/// search results, seller profile listings, and "related" strip.
///
/// Surfaces price, organic/discount badges, distance (when present),
/// stock state, shop name. Tap → calls [onTap].
class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.showShopName = true,
  });

  final TmListing listing;
  final VoidCallback onTap;
  final bool showShopName;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        listing.mainImageUrl != null && listing.mainImageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: TpColors.card,
          borderRadius: BorderRadius.circular(TpRadii.medium),
          boxShadow: TpShadows.claySm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    CachedNetworkImage(
                      imageUrl: listing.mainImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(
                        color: TpColors.paper2,
                      ),
                      errorWidget: (_, __, ___) => Center(
                        child: Blob3D(
                          size: 64,
                          hue: _hueFor(listing.id),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Blob3D(
                        size: 72,
                        hue: _hueFor(listing.id),
                      ),
                    ),
                  if (!listing.inStock)
                    const _OverlayLabel(text: 'หมดสต็อก'),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (listing.isOrganic)
                          const TpChip(
                            label: '🌱 ออร์แกนิก',
                            color: Color(0xFFE5F6CC),
                            textColor: Color(0xFF3E6B0A),
                            small: true,
                          ),
                        if (listing.hasDiscount)
                          TpChip(
                            label: '-${listing.discountPercent}%',
                            color: TpColors.pinkTint,
                            textColor: TpColors.pink,
                            small: true,
                          ),
                      ],
                    ),
                  ),
                  if (listing.distanceKm != null)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${listing.distanceKm!.toStringAsFixed(1)} กม.',
                          style: TpText.bodyXs.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TpText.bodyMd.copyWith(
                      color: TpColors.ink,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatBaht(listing.price),
                        style: TpText.bodyMd.copyWith(
                          color: TpColors.leaf,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '/ ${listing.unit}',
                          style: TpText.bodyXs.copyWith(color: TpColors.muted),
                        ),
                      ),
                    ],
                  ),
                  if (showShopName && listing.seller != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.storefront,
                            size: 12, color: TpColors.muted),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            listing.seller!.shopName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TpText.bodyXs.copyWith(color: TpColors.muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static BlobHue _hueFor(int id) => listingHueFor(id);
}

/// Deterministic blob colour for a listing — same id always gets the same
/// hue, so placeholder rendering stays consistent across screens.
BlobHue listingHueFor(int id) {
  const hues = [
    BlobHue.leaf,
    BlobHue.mango,
    BlobHue.tomato,
    BlobHue.mint,
    BlobHue.pink,
    BlobHue.purple,
  ];
  return hues[id.abs() % hues.length];
}

class _OverlayLabel extends StatelessWidget {
  const _OverlayLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TpText.bodySm.copyWith(
            color: TpColors.pink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
