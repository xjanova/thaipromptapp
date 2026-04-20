import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/models/commerce.dart';
import '../../shared/widgets/blob_3d.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/coin.dart';
import '../../shared/widgets/puff.dart';
import '../../shared/widgets/puffy_button.dart';
import 'cart_controller.dart';

/// Port of `Cart` in screens-b.jsx.
class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _useCoins = false;

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartControllerProvider);

    return Scaffold(
      backgroundColor: TpColors.paper,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: TpColors.pink)),
        error: (e, _) => _CartError(message: '$e'),
        data: (cart) => cart.items.isEmpty ? const _EmptyCart() : _Body(cart: cart, useCoins: _useCoins, onToggleCoins: (v) => setState(() => _useCoins = v)),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.cart, required this.useCoins, required this.onToggleCoins});
  final Cart cart;
  final bool useCoins;
  final ValueChanged<bool> onToggleCoins;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double coinsDiscount = useCoins ? _maxCoinsDiscount(cart).toDouble() : 0;
    final double finalTotal =
        (cart.totalThb - coinsDiscount).clamp(0.0, double.infinity);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            children: [
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ตะกร้า · CART', style: TpText.monoLabel),
                    Text.rich(
                      TextSpan(
                        style: TpText.display2,
                        children: [
                          const TextSpan(text: 'ของในตะกร้า '),
                          TextSpan(
                            text: '(${cart.itemCount})',
                            style: TpText.display2.copyWith(color: TpColors.pink),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (final item in cart.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CartItemRow(item: item),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              _CoinsToggle(
                cart: cart,
                on: useCoins,
                onChange: onToggleCoins,
              ),
              const SizedBox(height: 10),
              const _DeliveryCard(),
              const SizedBox(height: 14),
              _Summary(cart: cart, coinsDiscount: coinsDiscount, finalTotal: finalTotal.toDouble()),
            ],
          ),
        ),
        _StickyPay(walletBalance: cart.walletBalanceThb, total: finalTotal),
      ],
    );
  }

  static int _maxCoinsDiscount(Cart cart) {
    return cart.coinsAvailable.clamp(0, cart.subtotalThb.floor());
  }
}

class _CartItemRow extends ConsumerWidget {
  const _CartItemRow({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClayCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _bgForHue(item.hue),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Puff(width: 54, height: 40, hue: item.hue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.variantLabel == null ? item.name : '${item.name} (${item.variantLabel})',
                  style: TpText.titleMd.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(item.shopName, style: TpText.monoLabel),
                const SizedBox(height: 4),
                Text('฿${item.priceThb.toStringAsFixed(0)}', style: TpText.display4.copyWith(fontSize: 15)),
              ],
            ),
          ),
          _QtyStepper(
            qty: item.quantity,
            onDec: () => ref.read(cartControllerProvider.notifier).updateQty(item.id, item.quantity - 1),
            onInc: () => ref.read(cartControllerProvider.notifier).updateQty(item.id, item.quantity + 1),
          ),
        ],
      ),
    );
  }

  static Color _bgForHue(BlobHue h) {
    return switch (h) {
      BlobHue.pink => TpColors.pinkTint,
      BlobHue.mint || BlobHue.leaf => TpColors.mintTint,
      BlobHue.mango || BlobHue.tomato => TpColors.mangoTint,
      _ => const Color(0xFFEAE3FF),
    };
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.qty, required this.onDec, required this.onInc});
  final int qty;
  final VoidCallback onDec;
  final VoidCallback onInc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: TpColors.mangoTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(
            child: const Text('−',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            bg: Colors.white,
            fg: TpColors.ink,
            onTap: onDec,
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 14,
            child: Text('$qty',
                textAlign: TextAlign.center,
                style: TpText.monoTag.copyWith(fontSize: 13, color: TpColors.ink, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 6),
          _StepBtn(
            child: const Text('+',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: TpColors.mango)),
            bg: TpColors.deepInk,
            fg: TpColors.mango,
            onTap: onInc,
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.child, required this.bg, required this.fg, required this.onTap});
  final Widget child;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: DefaultTextStyle.merge(style: TextStyle(color: fg), child: child),
      ),
    );
  }
}

class _CoinsToggle extends StatelessWidget {
  const _CoinsToggle({required this.cart, required this.on, required this.onChange});
  final Cart cart;
  final bool on;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    final maxDiscount = cart.coinsAvailable.clamp(0, cart.subtotalThb.floor());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClayCard(
        color: TpColors.deepInk,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Coin(size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ใช้ Coins ลด ฿$maxDiscount',
                      style: TpText.titleMd.copyWith(fontSize: 13, color: Colors.white)),
                  Text(
                    '${cart.coinsAvailable} coins · 1 coin = ฿1',
                    style: TpText.monoLabel.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            Switch(
              value: on,
              onChanged: cart.coinsAvailable > 0 ? onChange : null,
              activeTrackColor: TpColors.mint,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClayCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('จัดส่ง', style: TpText.monoLabel),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: TpColors.mango,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🛵', style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ส่งโดยไรเดอร์ชุมชน · 15-25 นาที',
                          style: TpText.titleMd.copyWith(fontSize: 13)),
                      Text('ซ.สุขุมวิท 24 · 1.2km', style: TpText.monoLabel),
                    ],
                  ),
                ),
                Text('฿0', style: TpText.display4.copyWith(fontSize: 14, color: TpColors.mint)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.cart, required this.coinsDiscount, required this.finalTotal});
  final Cart cart;
  final double coinsDiscount;
  final double finalTotal;

  @override
  Widget build(BuildContext context) {
    String t(double v) => '฿${v.toStringAsFixed(0)}';
    final rows = [
      ('ราคาสินค้า', t(cart.subtotalThb)),
      ('ค่าจัดส่ง', t(cart.deliveryFeeThb)),
      if (coinsDiscount > 0) ('ส่วนลด Coins', '-${t(coinsDiscount)}'),
      if (cart.discountThb > 0) ('ส่วนลดโปรโมชั่น', '-${t(cart.discountThb)}'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: ClayCard(
        color: TpColors.mangoTint,
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(row.$1, style: TpText.bodySm.copyWith(fontWeight: FontWeight.w600)),
                    Text(row.$2, style: TpText.monoTag),
                  ],
                ),
              ),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: TpColors.deepInk,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('ทั้งหมด', style: TpText.titleLg.copyWith(fontSize: 15, fontWeight: FontWeight.w900)),
                Text('฿${finalTotal.toStringAsFixed(0)}', style: TpText.display3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyPay extends StatelessWidget {
  const _StickyPay({required this.walletBalance, required this.total});
  final double walletBalance;
  final double total;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TpColors.paper,
        border: Border(top: BorderSide(color: Color(0x1F2E1A5C))),
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
                  Text('WALLET', style: TpText.monoLabel),
                  Text('฿${walletBalance.toStringAsFixed(2)}',
                      style: TpText.titleMd.copyWith(fontSize: 13)),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PuffyButton(
                  label: 'จ่ายด้วย Wallet',
                  variant: PuffyVariant.pink,
                  size: PuffySize.large,
                  fullWidth: true,
                  onPressed: walletBalance >= total ? () => _checkout(context) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkout(BuildContext context) async {
    // Navigate to confirm screen / call API — wired in Phase 3 (Wallet + PIN)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ต่อหน้า checkout · จะต่อใน Phase 3 (Wallet + PIN)')),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_basket_outlined, size: 56, color: TpColors.muted),
            const SizedBox(height: 12),
            Text('ตะกร้ายังว่าง', style: TpText.display4),
            const SizedBox(height: 6),
            Text('ไปช้อปต่อที่หน้าแรกกันเถอะ', style: TpText.bodySm.copyWith(color: TpColors.muted)),
            const SizedBox(height: 20),
            PuffyButton(
              label: 'กลับหน้าแรก',
              variant: PuffyVariant.pink,
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartError extends StatelessWidget {
  const _CartError({required this.message});
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
            Text(message, textAlign: TextAlign.center, style: TpText.bodyMd),
          ],
        ),
      ),
    );
  }
}
