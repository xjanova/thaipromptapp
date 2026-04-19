import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../shared/models/commerce.dart';

class TrackingRepository {
  TrackingRepository(this._api);
  final ApiClient _api;

  Future<Tracking> forOrder(int orderId) async {
    final res = await _api.get<Map<String, dynamic>>(Api.orderTracking(orderId));
    final data = (res['data'] is Map<String, dynamic>)
        ? res['data'] as Map<String, dynamic>
        : res;
    return Tracking.fromJson(data);
  }
}

final trackingRepositoryProvider = FutureProvider<TrackingRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return TrackingRepository(api);
});

final trackingProvider =
    FutureProvider.autoDispose.family<Tracking, int>((ref, id) async {
  final repo = await ref.watch(trackingRepositoryProvider.future);
  return repo.forOrder(id);
});
