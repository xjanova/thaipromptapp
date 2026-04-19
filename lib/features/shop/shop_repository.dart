import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../shared/models/commerce.dart';

/// Shop profile. Backend endpoint path is /v1/shops/{id} — confirm with
/// backend team once implemented (not in the existing MobileApiController
/// audit, but trivially added).
class ShopRepository {
  ShopRepository(this._api);
  final ApiClient _api;

  Future<Shop> byId(int id) async {
    final res = await _api.get<Map<String, dynamic>>('/v1/shops/$id');
    final data = (res['data'] is Map<String, dynamic>)
        ? res['data'] as Map<String, dynamic>
        : res;
    return Shop.fromJson(data);
  }

  Future<List<Product>> products(int shopId) async {
    final res = await _api.get<Map<String, dynamic>>('/v1/shops/$shopId/products');
    final items = res['data'] is List ? res['data'] as List : (res['products'] as List? ?? []);
    return items
        .map((j) => Product.fromJson(j as Map<String, dynamic>))
        .toList(growable: false);
  }
}

final shopRepositoryProvider = FutureProvider<ShopRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return ShopRepository(api);
});

final shopDetailProvider =
    FutureProvider.autoDispose.family<Shop, int>((ref, id) async {
  final repo = await ref.watch(shopRepositoryProvider.future);
  return repo.byId(id);
});

final shopProductsProvider =
    FutureProvider.autoDispose.family<List<Product>, int>((ref, id) async {
  final repo = await ref.watch(shopRepositoryProvider.future);
  return repo.products(id);
});
