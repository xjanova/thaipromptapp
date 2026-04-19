// Wallet + Affiliate models.
//
// Backend mapping:
//   GET  /v1/wallet                → WalletSnapshot
//   GET  /v1/wallet/balance        → { balance, coins }
//   GET  /v1/wallet/transactions   → List<WalletTransaction>
//   POST /v1/wallet/topup          → TopupIntent  (returns PromptPay QR payload)
//   GET  /v1/wallet/lookup?addr=   → WalletLookup (recipient name for transfer)
//   POST /v1/wallet/transfer       → TransferResult (requires PIN)

import 'package:equatable/equatable.dart';

import 'commerce.dart' show hueForId;

int _i(dynamic v, [int fallback = 0]) =>
    v is int ? v : (v is num ? v.toInt() : (v is String ? int.tryParse(v) ?? fallback : fallback));
double _d(dynamic v, [double fallback = 0]) => v is num
    ? v.toDouble()
    : (v is String ? double.tryParse(v) ?? fallback : fallback);
String _s(dynamic v, [String f = '']) => v == null ? f : v.toString();

// ---------------------------------------------------------------------------
// Wallet
// ---------------------------------------------------------------------------

enum WalletTxType { purchase, topup, withdraw, transferIn, transferOut, affiliatePayout, refund, adjustment }

WalletTxType _txTypeFromRaw(String? raw) {
  return switch (raw) {
    'topup' => WalletTxType.topup,
    'withdraw' => WalletTxType.withdraw,
    'transfer_in' => WalletTxType.transferIn,
    'transfer_out' => WalletTxType.transferOut,
    'affiliate' || 'affiliate_payout' => WalletTxType.affiliatePayout,
    'refund' => WalletTxType.refund,
    'adjustment' => WalletTxType.adjustment,
    _ => WalletTxType.purchase,
  };
}

class WalletTransaction extends Equatable {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.type,
    required this.amountThb,
    required this.occurredAt,
    this.subtitle,
    this.iconGlyph,
  });

  final int id;
  final String title;
  final WalletTxType type;
  /// Signed: negative = outgoing, positive = incoming.
  final double amountThb;
  final DateTime occurredAt;
  final String? subtitle;
  final String? iconGlyph;

  bool get incoming => amountThb >= 0;

  factory WalletTransaction.fromJson(Map<String, dynamic> j) => WalletTransaction(
        id: _i(j['id']),
        title: _s(j['title'] ?? j['description']),
        type: _txTypeFromRaw(j['type']?.toString()),
        amountThb: _d(j['amount']),
        occurredAt: DateTime.tryParse(_s(j['occurred_at'] ?? j['created_at'])) ??
            DateTime.now(),
        subtitle: j['subtitle']?.toString(),
        iconGlyph: j['icon']?.toString(),
      );

  @override
  List<Object?> get props => [id, amountThb, occurredAt];
}

class WalletSnapshot extends Equatable {
  const WalletSnapshot({
    required this.balanceThb,
    required this.coins,
    required this.walletAddress,
    this.promptpayPayload,
    this.weeklySpend = const [],
    this.weeklySpendTrendPercent,
    this.recentTransactions = const [],
  });

  final double balanceThb;
  final int coins;
  final String walletAddress;
  final String? promptpayPayload;
  /// Seven values (Mon..Sun). Amount in THB. Empty list = chart hidden.
  final List<double> weeklySpend;
  final double? weeklySpendTrendPercent;
  final List<WalletTransaction> recentTransactions;

  factory WalletSnapshot.fromJson(Map<String, dynamic> j) => WalletSnapshot(
        balanceThb: _d(j['balance']),
        coins: _i(j['coins']),
        walletAddress: _s(j['wallet_address'] ?? j['address']),
        promptpayPayload: j['promptpay_payload']?.toString(),
        weeklySpend: (j['weekly_spend'] as List?)
                ?.map((v) => _d(v))
                .toList() ??
            const [],
        weeklySpendTrendPercent: j['weekly_spend_trend'] == null
            ? null
            : _d(j['weekly_spend_trend']),
        recentTransactions: (j['recent_transactions'] as List?)
                ?.map((v) => WalletTransaction.fromJson(v as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  static const empty = WalletSnapshot(balanceThb: 0, coins: 0, walletAddress: '');

  @override
  List<Object?> get props => [balanceThb, coins, walletAddress, weeklySpend];
}

class WalletLookup extends Equatable {
  const WalletLookup({required this.address, required this.recipientName, this.avatar});
  final String address;
  final String recipientName;
  final String? avatar;

  factory WalletLookup.fromJson(Map<String, dynamic> j) => WalletLookup(
        address: _s(j['address']),
        recipientName: _s(j['name'] ?? j['recipient_name']),
        avatar: j['avatar']?.toString(),
      );

  @override
  List<Object?> get props => [address, recipientName];
}

class TopupIntent extends Equatable {
  const TopupIntent({
    required this.intentRef,
    required this.amountThb,
    required this.promptpayPayload,
    required this.expiresAt,
  });
  final String intentRef;
  final double amountThb;
  final String promptpayPayload;
  final DateTime expiresAt;

  factory TopupIntent.fromJson(Map<String, dynamic> j) => TopupIntent(
        intentRef: _s(j['ref'] ?? j['intent_id']),
        amountThb: _d(j['amount']),
        promptpayPayload: _s(j['promptpay_payload'] ?? j['qr_payload']),
        expiresAt: DateTime.tryParse(_s(j['expires_at'])) ??
            DateTime.now().add(const Duration(minutes: 15)),
      );

  @override
  List<Object?> get props => [intentRef, amountThb];
}

class TransferResult extends Equatable {
  const TransferResult({
    required this.id,
    required this.amountThb,
    required this.recipientName,
    required this.newBalanceThb,
  });
  final int id;
  final double amountThb;
  final String recipientName;
  final double newBalanceThb;

  factory TransferResult.fromJson(Map<String, dynamic> j) => TransferResult(
        id: _i(j['id']),
        amountThb: _d(j['amount']),
        recipientName: _s(j['recipient_name']),
        newBalanceThb: _d(j['new_balance']),
      );

  @override
  List<Object?> get props => [id];
}

// ---------------------------------------------------------------------------
// Affiliate
// ---------------------------------------------------------------------------

enum AffiliateTier { bronze, silver, gold, platinum, diamond }

AffiliateTier _tierFromRaw(String? raw) {
  return switch (raw?.toLowerCase()) {
    'gold' => AffiliateTier.gold,
    'platinum' => AffiliateTier.platinum,
    'diamond' => AffiliateTier.diamond,
    'silver' => AffiliateTier.silver,
    _ => AffiliateTier.bronze,
  };
}

class AffiliateLink extends Equatable {
  const AffiliateLink({
    required this.id,
    required this.productId,
    required this.productName,
    required this.shopName,
    required this.clicks,
    required this.earningsThb,
    required this.commissionPercent,
    this.url,
  });

  final int id;
  final int productId;
  final String productName;
  final String shopName;
  final int clicks;
  final double earningsThb;
  final double commissionPercent;
  final String? url;

  int get hue => hueForId(productId).index;

  factory AffiliateLink.fromJson(Map<String, dynamic> j) => AffiliateLink(
        id: _i(j['id']),
        productId: _i(j['product_id']),
        productName: _s(j['product_name']),
        shopName: _s(j['shop_name']),
        clicks: _i(j['clicks']),
        earningsThb: _d(j['earnings']),
        commissionPercent: _d(j['commission_percent'], 8.5),
        url: j['url']?.toString(),
      );

  @override
  List<Object?> get props => [id, clicks, earningsThb];
}

class AffiliateSnapshot extends Equatable {
  const AffiliateSnapshot({
    required this.tier,
    required this.commissionPercent,
    required this.tierProgress,
    required this.invitesToNextTier,
    required this.monthlyEarningsThb,
    required this.monthlyTrendPercent,
    required this.monthlyClicks,
    required this.monthlyPurchases,
    required this.referralUrl,
    required this.invitedCount,
    this.topLinks = const [],
  });

  final AffiliateTier tier;
  final double commissionPercent;
  /// 0..1
  final double tierProgress;
  final int invitesToNextTier;

  final double monthlyEarningsThb;
  final double monthlyTrendPercent;
  final int monthlyClicks;
  final int monthlyPurchases;

  final String referralUrl;
  final int invitedCount;
  final List<AffiliateLink> topLinks;

  double get conversionRate =>
      monthlyClicks == 0 ? 0 : (monthlyPurchases / monthlyClicks * 100);

  factory AffiliateSnapshot.fromJson(Map<String, dynamic> j) => AffiliateSnapshot(
        tier: _tierFromRaw(j['tier']?.toString()),
        commissionPercent: _d(j['commission_percent'], 8.5),
        tierProgress: _d(j['tier_progress']).clamp(0, 1).toDouble(),
        invitesToNextTier: _i(j['invites_to_next_tier']),
        monthlyEarningsThb: _d(j['monthly_earnings']),
        monthlyTrendPercent: _d(j['monthly_trend_percent']),
        monthlyClicks: _i(j['monthly_clicks']),
        monthlyPurchases: _i(j['monthly_purchases']),
        referralUrl: _s(j['referral_url']),
        invitedCount: _i(j['invited_count']),
        topLinks: (j['top_links'] as List?)
                ?.map((v) => AffiliateLink.fromJson(v as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  static const empty = AffiliateSnapshot(
    tier: AffiliateTier.bronze,
    commissionPercent: 5.0,
    tierProgress: 0,
    invitesToNextTier: 10,
    monthlyEarningsThb: 0,
    monthlyTrendPercent: 0,
    monthlyClicks: 0,
    monthlyPurchases: 0,
    referralUrl: '',
    invitedCount: 0,
  );

  @override
  List<Object?> get props => [tier, monthlyEarningsThb, invitedCount];
}

extension AffiliateTierX on AffiliateTier {
  String get emoji => switch (this) {
        AffiliateTier.bronze => '🥉',
        AffiliateTier.silver => '🥈',
        AffiliateTier.gold => '🥇',
        AffiliateTier.platinum => '💎',
        AffiliateTier.diamond => '👑',
      };

  String get label => switch (this) {
        AffiliateTier.bronze => 'Bronze',
        AffiliateTier.silver => 'Silver',
        AffiliateTier.gold => 'Gold',
        AffiliateTier.platinum => 'Platinum',
        AffiliateTier.diamond => 'Diamond',
      };

  AffiliateTier? get next => switch (this) {
        AffiliateTier.bronze => AffiliateTier.silver,
        AffiliateTier.silver => AffiliateTier.gold,
        AffiliateTier.gold => AffiliateTier.platinum,
        AffiliateTier.platinum => AffiliateTier.diamond,
        AffiliateTier.diamond => null,
      };
}
