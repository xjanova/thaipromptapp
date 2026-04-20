import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/models/wallet.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/coin.dart';
import '../../shared/widgets/nav_dock.dart';
import 'wallet_repository.dart';

/// Port of `Wallet` in screens-b.jsx.
class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(walletSnapshotProvider);
    return Scaffold(
      backgroundColor: TpColors.deepInk,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: TpColors.pink)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('โหลด Wallet ไม่ได้: $e',
                style: TpText.bodyMd.copyWith(color: Colors.white)),
          ),
        ),
        data: (snapshot) => Stack(
          children: [
            const _AmbientGlow(),
            RefreshIndicator(
              color: TpColors.pink,
              onRefresh: () async => ref.invalidate(walletSnapshotProvider),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  const SafeArea(child: _Header()),
                  const SizedBox(height: 4),
                  _BalanceCard(snapshot: snapshot),
                  const SizedBox(height: 14),
                  const _ActionRow(),
                  _PromptPayMini(payload: snapshot.promptpayPayload),
                  _SpendChart(snapshot: snapshot),
                  _History(transactions: snapshot.recentTransactions),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: NavDock(
                active: NavTab.wallet,
                onChange: (t) {
                  switch (t) {
                    case NavTab.home:
                      context.go('/home');
                    case NavTab.affiliate:
                      context.go('/affiliate');
                    case NavTab.menu:
                      context.go('/settings');
                    case NavTab.wallet:
                    case NavTab.me:
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ambient background
// ---------------------------------------------------------------------------

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -60,
            child: _Glow(color: TpColors.pink, size: 200),
          ),
          Positioned(
            top: 120,
            left: -80,
            child: _Glow(color: TpColors.purple, size: 200),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.5), Colors.transparent],
          stops: const [0, 0.7],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('MY WALLET',
                    style: TpText.monoLabel.copyWith(color: Colors.white.withValues(alpha: 0.6))),
                Text('กระเป๋าของฉัน',
                    style: TpText.titleLg.copyWith(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: TpColors.mango,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.settings_rounded, color: TpColors.deepInk),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Balance hero card
// ---------------------------------------------------------------------------

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.snapshot});
  final WalletSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('en_US');
    final whole = snapshot.balanceThb.floor();
    final frac = ((snapshot.balanceThb - whole) * 100).round().toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: ClayCard(
        padding: const EdgeInsets.all(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TpColors.pink, TpColors.tomato, TpColors.mango],
          stops: [0, 0.5, 1],
        ),
        shadow: ClayShadow.small,
        clipChildren: true,
        child: Stack(
          children: [
            // Shine sweep
            Positioned.fill(child: _ShineAnimation()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('BALANCE',
                              style: TpText.monoLabelSm.copyWith(
                                color: TpColors.ink.withValues(alpha: 0.8),
                              )),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '฿${fmt.format(whole)}',
                                style: TpText.display1.copyWith(fontSize: 38, height: 1),
                              ),
                              Text(
                                '.$frac',
                                style: TpText.titleLg.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                          Text('≈ ${fmt.format(whole)} Promptpay THB',
                              style: TpText.titleMd.copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                    const _ChipEmv(),
                  ],
                ),
                const SizedBox(height: 14),
                _CoinsStrip(coins: snapshot.coins),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShineAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.5),
              Colors.transparent,
            ],
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .slide(begin: const Offset(-2, 0), end: const Offset(3, 0), duration: 3000.ms),
    );
  }
}

class _ChipEmv extends StatelessWidget {
  const _ChipEmv();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD98C), Color(0xFF8B5A1B)],
        ),
      ),
      padding: const EdgeInsets.all(6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.black.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}

class _CoinsStrip extends StatelessWidget {
  const _CoinsStrip({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: TpColors.deepInk.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TpColors.deepInk.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          const Coin(size: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Cashback Coins',
                    style: TpText.titleMd.copyWith(fontSize: 11, fontWeight: FontWeight.w700)),
                Text('1 coin = ฿1',
                    style: TpText.monoLabelSm.copyWith(
                      color: TpColors.ink.withValues(alpha: 0.8),
                    )),
              ],
            ),
          ),
          Text('$coins', style: TpText.display4.copyWith(fontSize: 20)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action row
// ---------------------------------------------------------------------------

class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    const items = [
      _ActionItem('เติมเงิน', Icons.arrow_upward_rounded, TpColors.mint, '/wallet/topup'),
      _ActionItem('ถอน', Icons.arrow_downward_rounded, TpColors.mango, '/wallet/withdraw'),
      _ActionItem('โอน', Icons.compare_arrows_rounded, TpColors.pink, '/wallet/transfer'),
      _ActionItem('สแกน', Icons.qr_code_scanner_rounded, TpColors.purple, '/wallet/scan'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final a in items) ...[
            Expanded(child: _ActionTile(item: a)),
            if (a != items.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ActionItem {
  const _ActionItem(this.label, this.icon, this.color, this.route);
  final String label;
  final IconData icon;
  final Color color;
  final String route;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.item});
  final _ActionItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, color: TpColors.deepInk, size: 22),
          ),
          const SizedBox(height: 6),
          Text(item.label,
              style: TpText.bodyXs.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PromptPay mini card
// ---------------------------------------------------------------------------

class _PromptPayMini extends StatelessWidget {
  const _PromptPayMini({required this.payload});
  final String? payload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: ClayCard(
        color: TpColors.paper,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _QrBox(payload: payload ?? ''),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('PROMPTPAY · TH0066', style: TpText.monoLabelSm),
                  const SizedBox(height: 2),
                  Text('เติมเร็วผ่าน QR', style: TpText.titleMd.copyWith(fontSize: 14)),
                  Text('สแกน → รับเงินใน 2 วิ', style: TpText.bodyXs),
                ],
              ),
            ),
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => context.go('/wallet/topup'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: TpColors.pink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('เติม', style: TpText.btnSm.copyWith(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrBox extends StatelessWidget {
  const _QrBox({required this.payload});
  final String payload;

  @override
  Widget build(BuildContext context) {
    final hasPayload = payload.isNotEmpty;
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: hasPayload
          ? QrImageView(
              data: payload,
              version: QrVersions.auto,
              padding: EdgeInsets.zero,
            )
          : const Icon(Icons.qr_code_rounded, color: TpColors.ink),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekly spend chart
// ---------------------------------------------------------------------------

class _SpendChart extends StatelessWidget {
  const _SpendChart({required this.snapshot});
  final WalletSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.weeklySpend.isEmpty) return const SizedBox.shrink();

    final fmt = NumberFormat.decimalPattern('en_US');
    final total = snapshot.weeklySpend.fold<double>(0, (a, b) => a + b);
    final trend = snapshot.weeklySpendTrendPercent;
    final bestIndex = _indexOfMax(snapshot.weeklySpend);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: ClayCard(
        color: TpColors.paper,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('THIS WEEK', style: TpText.monoLabelSm),
                    const SizedBox(height: 2),
                    Text('ใช้จ่าย ฿${fmt.format(total.round())}',
                        style: TpText.titleLg.copyWith(fontSize: 15, fontWeight: FontWeight.w800)),
                  ],
                ),
                if (trend != null)
                  Text(
                    '${trend < 0 ? '↓' : '↑'} ${trend.abs().toStringAsFixed(0)}% vs last',
                    style: TpText.bodyXs.copyWith(
                      color: trend <= 0 ? TpColors.mint : TpColors.pink,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 84,
              child: _BarsRow(values: snapshot.weeklySpend, bestIndex: bestIndex),
            ),
          ],
        ),
      ),
    );
  }

  static int _indexOfMax(List<double> list) {
    var bi = 0;
    for (var i = 1; i < list.length; i++) {
      if (list[i] > list[bi]) bi = i;
    }
    return bi;
  }
}

class _BarsRow extends StatelessWidget {
  const _BarsRow({required this.values, required this.bestIndex});
  final List<double> values;
  final int bestIndex;

  static const _labels = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    final m = values.reduce((a, b) => a > b ? a : b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < values.length && i < _labels.length; i++) ...[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: (values[i] / m) * 72,
                  decoration: BoxDecoration(
                    color: i == bestIndex ? TpColors.pink : TpColors.mango,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: i == bestIndex
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                              spreadRadius: -2,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_labels[i], style: TpText.monoLabelSm),
              ],
            ),
          ),
          if (i < values.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// History
// ---------------------------------------------------------------------------

class _History extends StatelessWidget {
  const _History({required this.transactions});
  final List<WalletTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ประวัติ',
                  style: TpText.titleLg.copyWith(color: Colors.white, fontSize: 14)),
              Text('ALL →',
                  style: TpText.monoLabelSm.copyWith(color: Colors.white.withValues(alpha: 0.6))),
            ],
          ),
          const SizedBox(height: 8),
          for (final tx in transactions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HistoryRow(tx: tx),
            ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.tx});
  final WalletTransaction tx;

  @override
  Widget build(BuildContext context) {
    final c = _colorFor(tx.type);
    final g = tx.iconGlyph ?? _glyphFor(tx.type);
    final fmt = NumberFormat.decimalPattern('en_US');
    final amount = '${tx.amountThb >= 0 ? '+' : '-'}฿${fmt.format(tx.amountThb.abs().round())}';
    final timeText = _relative(tx.occurredAt);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(g,
                style: TpText.display4.copyWith(color: TpColors.deepInk, fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tx.title,
                    style: TpText.titleMd.copyWith(color: Colors.white, fontSize: 13)),
                Text(timeText,
                    style: TpText.monoLabelSm.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    )),
              ],
            ),
          ),
          Text(amount,
              style: TpText.display4.copyWith(
                fontSize: 15,
                color: tx.incoming ? TpColors.mint : Colors.white,
              )),
        ],
      ),
    );
  }

  static Color _colorFor(WalletTxType t) => switch (t) {
        WalletTxType.topup || WalletTxType.transferIn || WalletTxType.refund => TpColors.mint,
        WalletTxType.affiliatePayout => TpColors.mango,
        WalletTxType.purchase || WalletTxType.transferOut => TpColors.pink,
        WalletTxType.withdraw => TpColors.mango,
        WalletTxType.adjustment => TpColors.purple,
      };

  static String _glyphFor(WalletTxType t) => switch (t) {
        WalletTxType.topup || WalletTxType.transferIn || WalletTxType.refund => '⬆',
        WalletTxType.affiliatePayout => '◇',
        WalletTxType.purchase || WalletTxType.transferOut => '◉',
        WalletTxType.withdraw => '⬇',
        WalletTxType.adjustment => '⚙',
      };

  static String _relative(DateTime when) {
    final delta = DateTime.now().difference(when);
    if (delta.inMinutes < 1) return 'เมื่อกี้';
    if (delta.inMinutes < 60) return '${delta.inMinutes} นาทีที่แล้ว';
    if (delta.inHours < 24) {
      return '${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}';
    }
    if (delta.inDays == 1) return 'เมื่อวาน';
    return '${when.day}/${when.month}';
  }
}
