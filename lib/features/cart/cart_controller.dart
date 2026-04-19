import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/commerce.dart';
import 'cart_repository.dart';

/// Cart state — starts empty and populates from backend on first read.
/// All mutations go through the backend (which owns pricing logic).
class CartController extends AsyncNotifier<Cart> {
  @override
  Future<Cart> build() async {
    final repo = await ref.watch(cartRepositoryProvider.future);
    try {
      return await repo.fetch();
    } catch (_) {
      return Cart.empty;
    }
  }

  Future<void> addProduct(int productId, {int qty = 1, int? variantId, List<int> addonIds = const []}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(cartRepositoryProvider.future);
      return repo.add(productId: productId, quantity: qty, variantId: variantId, addonIds: addonIds);
    });
  }

  Future<void> updateQty(int itemId, int qty) async {
    if (qty < 1) {
      await remove(itemId);
      return;
    }
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(cartRepositoryProvider.future);
      return repo.updateItem(itemId, quantity: qty);
    });
  }

  Future<void> remove(int itemId) async {
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(cartRepositoryProvider.future);
      return repo.remove(itemId);
    });
  }

  Future<void> setCoins(int coins) async {
    // Handled server-side during checkout call. Kept here for future client state.
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(Cart(
      items: cur.items,
      subtotalThb: cur.subtotalThb,
      deliveryFeeThb: cur.deliveryFeeThb,
      discountThb: coins.toDouble(),
      totalThb: cur.subtotalThb + cur.deliveryFeeThb - coins,
      coinsAvailable: cur.coinsAvailable,
      coinsApplied: coins,
      walletBalanceThb: cur.walletBalanceThb,
      deliveryEta: cur.deliveryEta,
      deliveryAddress: cur.deliveryAddress,
    ));
  }
}

final cartControllerProvider = AsyncNotifierProvider<CartController, Cart>(
  CartController.new,
);
