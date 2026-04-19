import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../shared/models/wallet.dart';

class WalletRepository {
  WalletRepository(this._api);
  final ApiClient _api;

  Future<WalletSnapshot> snapshot() async {
    final res = await _api.get<Map<String, dynamic>>(Api.wallet);
    final data = (res['data'] is Map<String, dynamic>)
        ? res['data'] as Map<String, dynamic>
        : res;
    return WalletSnapshot.fromJson(data);
  }

  Future<List<WalletTransaction>> transactions({int page = 1, int perPage = 30}) async {
    final res = await _api.get<Map<String, dynamic>>(
      Api.walletTransactions,
      query: {'page': page, 'per_page': perPage},
    );
    final list = res['data'] is List ? res['data'] as List : (res['transactions'] as List? ?? []);
    return list
        .map((j) => WalletTransaction.fromJson(j as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<TopupIntent> initTopup(double amountThb) async {
    final res = await _api.post<Map<String, dynamic>>(
      Api.walletTopup,
      data: {'amount': amountThb},
    );
    final data = (res['data'] is Map<String, dynamic>)
        ? res['data'] as Map<String, dynamic>
        : res;
    return TopupIntent.fromJson(data);
  }

  Future<WalletLookup> lookup(String address) async {
    final res = await _api.get<Map<String, dynamic>>(
      Api.walletLookup,
      query: {'address': address},
    );
    final data = (res['data'] is Map<String, dynamic>)
        ? res['data'] as Map<String, dynamic>
        : res;
    return WalletLookup.fromJson(data);
  }

  /// [pin] should already be hashed by the caller (never send raw pin).
  Future<TransferResult> transfer({
    required String toAddress,
    required double amountThb,
    required String pinHash,
    String? note,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      Api.walletTransfer,
      data: {
        'to_address': toAddress,
        'amount': amountThb,
        'pin_hash': pinHash,
        if (note != null) 'note': note,
      },
    );
    final data = (res['data'] is Map<String, dynamic>)
        ? res['data'] as Map<String, dynamic>
        : res;
    return TransferResult.fromJson(data);
  }
}

final walletRepositoryProvider = FutureProvider<WalletRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return WalletRepository(api);
});

final walletSnapshotProvider = FutureProvider.autoDispose<WalletSnapshot>((ref) async {
  final repo = await ref.watch(walletRepositoryProvider.future);
  return repo.snapshot();
});
