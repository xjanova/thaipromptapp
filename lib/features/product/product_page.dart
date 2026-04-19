import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/models/commerce.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/coin.dart';
import '../../shared/widgets/floor_shadow.dart';
import '../../shared/widgets/puff.dart';
import '../../shared/widgets/puffy_button.dart';
import '../cart/cart_controller.dart';
import 'product_repository.dart';

/// Port of `Product` in screens-a.jsx.
class ProductPage extends ConsumerStatefulWidget {
  const ProductPage({super.key, required this.productId});
  final int productId;

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
  int _selectedVariantIndex = -1;
  final Set<int> _selectedAddonIds = {};

  @override
  Widget build(BuildContext context) {
    final asyncProduct = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: TpColors.paper,
      body: asyncProduct.when(
        loading: () => const _ProductSkeleton(),
        error: (e, _) => _ProductError(message: e.toString()),
        data: (product) => _ProductBody(
          product: product,
          selectedVariantIndex: _pickVariantIndex(product),
          selectedAddonIds: _effectiveAddonIds(product),
          onVariantChange: (i) => setState(() => _selectedVariantIndex = i),
          onAddonToggle: (id) => setState(() {
            if (_selectedAddonIds.contains(id)) {
              _selectedAddonIds.remove(id);
            } else {
              _selectedAddonIds.add(id);
            }
          }),
          onAddToCart: () => _addToCart(product),
        ),
      ),
    );
  }

  int _pickVariantIndex(Product p) {
    if (p.variants.isEmpty) return -1;
    if (_selectedVariantIndex == -1) {
      // default to middle variant if any, else first
      return p.variants.length >= 2 ? 1 : 0;
    }
    return _selectedVariantIndex.clamp(0, p.variants.length - 1);
  }

  Set<int> _effectiveAddonIds(Product p) {
    if (_selectedAddonIds.isNotEmpty) return _selectedAddonIds;
    return {
      for (final a in p.addons)
        if (a.defaultSelected) a.id,
    };
  }

  Future<void> _addToCart(Product product) async {
    final variantIndex = _pickVariantIndex(product);
    final variantId = (variantIndex >= 0 && variantIndex < product.variants.length)
        ? product.variants[variantIndex].id
        : null;
    final addonIds = _effectiveAddonIds(product).toList();

    try {
      await ref.read(cartControllerProvider.notifier).addProduct(
            product.id,
            variantId: variantId,
            addonIds: addonIds,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เพิ่มลงตะกร้าแล้ว 🛒')),
      );
      context.go('/cart');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ผิดพลาด: $e')),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _ProductBody extends StatelessWidget {
  const _ProductBody({
    required this.product,
    required this.selectedVariantIndex,
    required this.selectedAddonIds,
    required this.onVariantChange,
    required this.onAddonToggle,
    required this.onAddToCart,
  });

  final Product product;
  final int selectedVariantIndex;
  final Set<int> selectedAddonIds;
  final ValueChanged<int> onVariantChange;
  final ValueChanged<int> onAddonToggle;
  final VoidCallback onAddToCart;

  double get _totalThb {
    final base = (selectedVariantIndex >= 0 && selectedVariantIndex < product.variants.length)
        ? product.variants[selectedVariantIndex].priceThb
        : product.priceThb;
    final addonsTotal = product.addons
        .where((a) => selectedAddonIds.contains(a.id))
        .fold<double>(0, (sum, a) => sum + a.priceThb);
    return base + addonsTotal;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _HeroSection(product: product),
              _InfoSection(
                product: product,
                selectedVariantIndex: selectedVariantIndex,
                onVariantChange: onVariantChange,
                selectedAddonIds: selectedAddonIds,
                onAddonToggle: onAddonToggle,
              ),
            ],
          ),
        ),
        _StickyCta(total: _totalThb, onAdd: onAddToCart),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.7, -1),
                  end: Alignment(0.7, 1),
                  colors: [TpColors.pink, TpColors.tomato],
                ),
              ),
            ),
          ),
          // product puff
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Puff(width: 200, height: 170, hue: product.hue).animate(
                onPlay: (c) => c.repeat(reverse: true),
              ).moveY(begin: 0, end: -8, duration: 3500.ms),
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(child: FloorShadow(width: 220)),
          ),

          // Navigation buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _RoundButton(icon: Icons.arrow_back_rounded, onTap: () => context.pop()),
                  const Spacer(),
                  _RoundButton(icon: Icons.favorite_border_rounded, onTap: () {}),
                ],
              ),
            ),
          ),

          // Free delivery badge
          if (product.freeDelivery)
            Positioned(
              top: 30,
              right: 16,
              child: const _FreeDeliveryBadge().animate(
                onPlay: (c) => c.repeat(),
              ).rotate(duration: 22.seconds),
            ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
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
        child: Icon(icon, size: 18, color: TpColors.ink),
      ),
    );
  }
}

class _FreeDeliveryBadge extends StatelessWidget {
  const _FreeDeliveryBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: TpColors.mango,
        border: Border.all(color: TpColors.deepInk, width: 2.5),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: TpColors.deepInk,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.star_rounded, color: TpColors.mango, size: 18),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.product,
    required this.selectedVariantIndex,
    required this.onVariantChange,
    required this.selectedAddonIds,
    required this.onAddonToggle,
  });

  final Product product;
  final int selectedVariantIndex;
  final ValueChanged<int> onVariantChange;
  final Set<int> selectedAddonIds;
  final ValueChanged<int> onAddonToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (product.category != null)
                Text(product.category!.toUpperCase(), style: TpText.monoLabel)
              else
                const SizedBox.shrink(),
              if (product.rating != null)
                Text(
                  '★ ${product.rating!.toStringAsFixed(1)} (${product.reviewCount})',
                  style: TpText.bodyXs.copyWith(
                    color: TpColors.pink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(product.name, style: TpText.display3),
          const SizedBox(height: 8),
          Text(product.description, style: TpText.bodySm),

          if (product.variants.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('ขนาด · SIZE', style: TpText.monoLabel),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < product.variants.length; i++) ...[
                  Expanded(
                    child: _VariantChip(
                      variant: product.variants[i],
                      active: i == selectedVariantIndex,
                      onTap: () => onVariantChange(i),
                    ),
                  ),
                  if (i < product.variants.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ],

          if (product.addons.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('เพิ่มเติม · ADD-ONS', style: TpText.monoLabel),
            const SizedBox(height: 8),
            for (final a in product.addons)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AddonRow(
                  addon: a,
                  selected: selectedAddonIds.contains(a.id),
                  onTap: () => onAddonToggle(a.id),
                ),
              ),
          ],

          const SizedBox(height: 12),
          _SellerRow(product: product),
          const SizedBox(height: 14),
          if (product.affiliateCommissionPercent != null)
            _AffiliateCallout(product: product),
        ],
      ),
    );
  }
}

class _VariantChip extends StatelessWidget {
  const _VariantChip({required this.variant, required this.active, required this.onTap});
  final ProductVariant variant;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: active ? TpColors.pink : TpColors.card,
          borderRadius: BorderRadius.circular(14),
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
        child: Column(
          children: [
            Text(
              variant.label,
              style: TpText.titleMd.copyWith(
                fontSize: 13,
                color: active ? Colors.white : TpColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '฿${variant.priceThb.toStringAsFixed(0)}',
              style: TpText.monoTag.copyWith(
                fontSize: 11,
                color: active
                    ? Colors.white.withValues(alpha: 0.9)
                    : TpColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddonRow extends StatelessWidget {
  const _AddonRow({required this.addon, required this.selected, required this.onTap});
  final ProductAddon addon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClayCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: selected ? TpColors.mangoTint : TpColors.card,
        shadow: ClayShadow.small,
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? TpColors.deepInk : Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: selected ? null : Border.all(color: TpColors.muted.withValues(alpha: 0.3)),
              ),
              alignment: Alignment.center,
              child: selected
                  ? const Icon(Icons.check_rounded, color: TpColors.mango, size: 14)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(addon.label, style: TpText.bodySm.copyWith(fontWeight: FontWeight.w600))),
            Text('+฿${addon.priceThb.toStringAsFixed(0)}', style: TpText.monoTag),
          ],
        ),
      ),
    );
  }
}

class _SellerRow extends StatelessWidget {
  const _SellerRow({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final initial = product.shopName.isEmpty ? '?' : product.shopName.characters.first;
    return ClayCard(
      padding: const EdgeInsets.all(12),
      shadow: ClayShadow.small,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: TpColors.mango,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(initial, style: TpText.display4.copyWith(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(product.shopName, style: TpText.titleMd.copyWith(fontSize: 13)),
                Text('ตอบเร็ว · ร้านยืนยัน', style: TpText.monoLabel),
              ],
            ),
          ),
          PuffyButton(
            label: 'แชท',
            icon: Icons.chat_bubble_outline_rounded,
            variant: PuffyVariant.ghost,
            size: PuffySize.small,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _AffiliateCallout extends StatelessWidget {
  const _AffiliateCallout({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final pct = product.affiliateCommissionPercent ?? 8.5;
    final estThb = (product.priceThb * pct / 100).round();
    return ClayCard(
      padding: const EdgeInsets.all(12),
      color: TpColors.mint,
      child: Row(
        children: [
          const Coin(size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('แชร์แล้วได้ ฿$estThb ต่อออเดอร์',
                    style: TpText.titleMd.copyWith(fontWeight: FontWeight.w800, fontSize: 12)),
                Text('คัดลอกลิงก์ · ${pct.toStringAsFixed(1)}% commission',
                    style: TpText.bodyXs.copyWith(color: const Color(0xFF003028))),
              ],
            ),
          ),
          PuffyButton(
            label: 'แชร์',
            icon: Icons.ios_share_rounded,
            variant: PuffyVariant.ink,
            size: PuffySize.small,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _StickyCta extends StatelessWidget {
  const _StickyCta({required this.total, required this.onAdd});
  final double total;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TpColors.paper,
        border: Border(
          top: BorderSide(color: Color(0x1F2E1A5C)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('TOTAL', style: TpText.monoLabel),
                  Text('฿${total.toStringAsFixed(0)}', style: TpText.display3),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PuffyButton(
                  label: 'ใส่ตะกร้า · Add to bag',
                  variant: PuffyVariant.pink,
                  size: PuffySize.large,
                  fullWidth: true,
                  onPressed: onAdd,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading / error states
// ---------------------------------------------------------------------------

class _ProductSkeleton extends StatelessWidget {
  const _ProductSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: TpColors.pink),
    );
  }
}

class _ProductError extends StatelessWidget {
  const _ProductError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: TpColors.pink),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TpText.bodyMd,
            ),
            const SizedBox(height: 12),
            PuffyButton(
              label: 'ย้อนกลับ',
              variant: PuffyVariant.ink,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
