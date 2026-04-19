import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../shared/models/commerce.dart';

class ProductRepository {
  ProductRepository(this._api);
  final ApiClient _api;

  Future<Product> byId(int id) async {
    final res = await _api.get<Map<String, dynamic>>(Api.product(id));
    // Laravel APIResource usually wraps in "data"
    final data = (res['data'] is Map<String, dynamic>)
        ? res['data'] as Map<String, dynamic>
        : res;
    return Product.fromJson(data);
  }

  Future<List<Product>> list({String? category, String? search, int page = 1}) async {
    final res = await _api.get<Map<String, dynamic>>(
      Api.products,
      query: {
        if (category != null) 'category': category,
        if (search != null && search.isNotEmpty) 'q': search,
        'page': page,
      },
    );
    final items = res['data'] is List ? res['data'] as List : (res['products'] as List? ?? []);
    return items
        .map((j) => Product.fromJson(j as Map<String, dynamic>))
        .toList(growable: false);
  }
}

final productRepositoryProvider = FutureProvider<ProductRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return ProductRepository(api);
});

final productDetailProvider =
    FutureProvider.autoDispose.family<Product, int>((ref, id) async {
  final repo = await ref.watch(productRepositoryProvider.future);
  return repo.byId(id);
});
