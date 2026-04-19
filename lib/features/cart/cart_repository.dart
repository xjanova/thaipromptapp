import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../shared/models/commerce.dart';

class CartRepository {
  CartRepository(this._api);
  final ApiClient _api;

  Future<Cart> fetch() async {
    final res = await _api.get<Map<String, dynamic>>(Api.cart);
    final data = (res['data'] is Map<String, dynamic>)
        ? res['data'] as Map<String, dynamic>
        : res;
    return Cart.fromJson(data);
  }

  Future<Cart> add({
    required int productId,
    int quantity = 1,
    int? variantId,
    List<int> addonIds = const [],
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      Api.cartAdd,
      data: {
        'product_id': productId,
        'quantity': quantity,
        if (variantId != null) 'variant_id': variantId,
        if (addonIds.isNotEmpty) 'addon_ids': addonIds,
      },
    );
    return Cart.fromJson((res['data'] as Map<String, dynamic>?) ?? res);
  }

  Future<Cart> updateItem(int itemId, {required int quantity}) async {
    final res = await _api.put<Map<String, dynamic>>(
      Api.cartItem(itemId),
      data: {'quantity': quantity},
    );
    return Cart.fromJson((res['data'] as Map<String, dynamic>?) ?? res);
  }

  Future<Cart> remove(int itemId) async {
    final res = await _api.delete<Map<String, dynamic>>(Api.cartItem(itemId));
    return Cart.fromJson((res['data'] as Map<String, dynamic>?) ?? res);
  }

  Future<Cart> clear() async {
    final res = await _api.delete<Map<String, dynamic>>(Api.cartClear);
    return Cart.fromJson((res['data'] as Map<String, dynamic>?) ?? res);
  }

  Future<Cart> applyPromo(String code) async {
    final res = await _api.post<Map<String, dynamic>>(
      Api.cartPromo,
      data: {'code': code},
    );
    return Cart.fromJson((res['data'] as Map<String, dynamic>?) ?? res);
  }

  Future<OrderSummary> checkout({int coinsToUse = 0}) async {
    final res = await _api.post<Map<String, dynamic>>(
      Api.cartCheckout,
      data: {
        'coins_to_use': coinsToUse,
      },
    );
    final data = (res['data'] is Map<String, dynamic>)
        ? res['data'] as Map<String, dynamic>
        : res;
    return OrderSummary.fromJson(data);
  }
}

final cartRepositoryProvider = FutureProvider<CartRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return CartRepository(api);
});
