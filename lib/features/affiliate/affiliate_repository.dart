import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../shared/models/wallet.dart';

class AffiliateRepository {
  AffiliateRepository(this._api);
  final ApiClient _api;

  Future<AffiliateSnapshot> snapshot() async {
    // The backend splits this across several endpoints; we stitch them here so
    // the UI consumes one shape.
    final results = await Future.wait([
      _api.get<Map<String, dynamic>>(Api.dashboardCommissions),
      _api.get<Map<String, dynamic>>(Api.dashboardReferrals),
      _api.get<Map<String, dynamic>>(Api.dashboardCharts),
      _api.get<Map<String, dynamic>>(Api.dashboardReferralLink),
    ]);

    Map<String, dynamic> _payload(Map<String, dynamic> res) =>
        (res['data'] is Map<String, dynamic>) ? res['data'] as Map<String, dynamic> : res;

    final commissions = _payload(results[0]);
    final referrals = _payload(results[1]);
    final charts = _payload(results[2]);
    final link = _payload(results[3]);

    return AffiliateSnapshot.fromJson({
      ...commissions,
      ...referrals,
      ...charts,
      ...link,
    });
  }
}

final affiliateRepositoryProvider = FutureProvider<AffiliateRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return AffiliateRepository(api);
});

final affiliateSnapshotProvider = FutureProvider.autoDispose<AffiliateSnapshot>((ref) async {
  final repo = await ref.watch(affiliateRepositoryProvider.future);
  return repo.snapshot();
});
