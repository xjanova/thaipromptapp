import 'package:equatable/equatable.dart';

/// Lightweight user model parsed from `/v1/me`.
/// Full freezed+json_serializable model will replace this in Phase 2
/// once we run build_runner; for now keep it hand-written to keep the
/// toolchain free of codegen for the first screens.
class TpUser extends Equatable {
  const TpUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatar,
    this.referralCode,
    this.walletAddress,
    this.rankName,
    this.rankLevel,
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? referralCode;
  final String? walletAddress;
  final String? rankName;
  final int? rankLevel;

  /// Placeholder used when we trust a stored token but can't reach /me
  /// (transient network failure on cold start). Fields will fill in the
  /// next time /me succeeds — we re-invalidate the auth controller then.
  factory TpUser.placeholder() => const TpUser(id: 0, name: 'กำลังโหลด...');

  bool get isPlaceholder => id == 0;

  factory TpUser.fromJson(Map<String, dynamic> json) {
    // Backend returns user fields either at top level or nested under `user`.
    final u = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : json;
    return TpUser(
      id: (u['id'] as num).toInt(),
      name: (u['name'] ?? '').toString(),
      email: u['email']?.toString(),
      phone: u['phone']?.toString(),
      avatar: u['avatar']?.toString(),
      referralCode: u['referral_code']?.toString(),
      walletAddress: u['wallet_address']?.toString(),
      rankName: u['rank']?.toString(),
      rankLevel: u['rank_level'] is num ? (u['rank_level'] as num).toInt() : null,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, email, phone, avatar, referralCode, walletAddress, rankName, rankLevel];
}
