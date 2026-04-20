import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/models/wallet.dart';
import '../../shared/widgets/blob_3d.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/coin.dart';
import '../../shared/widgets/nav_dock.dart';
import '../../shared/widgets/puff.dart';
import '../../shared/widgets/puffy_button.dart';
import '../../shared/widgets/section_header.dart';
import 'affiliate_repository.dart';

/// Port of `Affiliate` in screens-b.jsx.
class AffiliatePage extends ConsumerStatefulWidget {
  const AffiliatePage({super.key});

  @override
  ConsumerState<AffiliatePage> createState() => _AffiliatePageState();
}

class _AffiliatePageState extends ConsumerState<AffiliatePage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(affiliateSnapshotProvider);
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: Stack(
        children: [
          async.when(
            loading: () => const Center(child: CircularProgressIndicator(color: TpColors.pink)),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('โหลดข้อมูล Affiliate ไม่ได้: $e', style: TpText.bodyMd),
              ),
            ),
            data: (snapshot) => RefreshIndicator(
              color: TpColors.pink,
              onRefresh: () async => ref.invalidate(affiliateSnapshotProvider),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  _Hero(snapshot: snapshot),
                  _EarningsCard(snapshot: snapshot),
                  _ShareLinkRow(snapshot: snapshot),
                  _TabsRow(index: _tabIndex, onChange: (i) => setState(() => _tabIndex = i)),
                  const SectionHeader(
                    titleTh: 'สินค้าทำเงินสูงสุด',
                    titleEn: 'Top earning links',
                  ),
                  if (snapshot.topLinks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text('ยังไม่มีลิงก์ที่ทำเงิน · ไปแชร์สินค้าแรกกัน',
                            style: TpText.bodySm.copyWith(color: TpColors.muted)),
                      ),
                    )
                  else
                    for (final l in snapshot.topLinks)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: _LinkRow(link: l),
                      ),
                  const SectionHeader(
                    titleTh: 'ชวนเพื่อน',
                    titleEn: 'Invite & earn ฿50',
                  ),
                  _InviteCard(snapshot: snapshot),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: NavDock(
              active: NavTab.affiliate,
              onChange: (t) {
                switch (t) {
                  case NavTab.home:
                    context.go('/home');
                  case NavTab.wallet:
                    context.go('/wallet');
                  case NavTab.menu:
                    context.go('/settings');
                  case NavTab.affiliate:
                  case NavTab.me:
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero + Tier
// ---------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({required this.snapshot});
  final AffiliateSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.7, -1),
          end: Alignment(0.7, 1.1),
          colors: [TpColors.purple, TpColors.pink],
        ),
        border: Border(bottom: BorderSide(color: Color(0x1F2E1A5C))),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('AFFILIATE · ระบบแนะนำ',
                style: TpText.monoLabel.copyWith(color: Colors.white.withValues(alpha: 0.8))),
            const SizedBox(height: 4),
            Text(
              'แชร์ → เพื่อนซื้อ → รับเงิน',
              style: TpText.display2.copyWith(color: Colors.white, fontSize: 26),
            ),
            const SizedBox(height: 12),
            _TierCard(snapshot: snapshot),
          ],
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.snapshot});
  final AffiliateSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final nextTier = snapshot.tier.next;
    final sub = nextTier == null
        ? 'สูงสุดแล้ว · ${snapshot.commissionPercent.toStringAsFixed(1)}% ต่อออเดอร์'
        : '${snapshot.commissionPercent.toStringAsFixed(1)}% ต่อออเดอร์ · อีก '
            '${snapshot.invitesToNextTier} ครั้งเลื่อน ${nextTier.label}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Coin(size: 54, label: snapshot.tier.emoji),
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .rotate(duration: 22.seconds),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${snapshot.tier.label} Tier',
                    style: TpText.titleLg.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                Text(sub,
                    style: TpText.bodyXs.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Container(height: 8, color: Colors.black.withValues(alpha: 0.25)),
                      LayoutBuilder(
                        builder: (_, c) => Container(
                          width: c.maxWidth * snapshot.tierProgress,
                          height: 8,
                          decoration: BoxDecoration(
                            color: TpColors.mango,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Earnings card (overlap)
// ---------------------------------------------------------------------------

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.snapshot});
  final AffiliateSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('en_US');
    final now = DateTime.now();
    final monthLabel = DateFormat.yMMM('en_US').format(now);

    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClayCard(
          color: TpColors.paper,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('EARNINGS · ${monthLabel.toUpperCase()}', style: TpText.monoLabelSm),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('฿${fmt.format(snapshot.monthlyEarningsThb.round())}',
                      style: TpText.display1.copyWith(fontSize: 34)),
                  const SizedBox(width: 6),
                  if (snapshot.monthlyTrendPercent != 0)
                    Text(
                      '${snapshot.monthlyTrendPercent >= 0 ? '↑' : '↓'} ${snapshot.monthlyTrendPercent.abs().toStringAsFixed(0)}%',
                      style: TpText.bodyXs.copyWith(
                        color: snapshot.monthlyTrendPercent >= 0 ? TpColors.mint : TpColors.pink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'คลิก',
                      value: fmt.format(snapshot.monthlyClicks),
                      color: TpColors.mango,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _MiniStat(
                      label: 'ซื้อ',
                      value: '${snapshot.monthlyPurchases}',
                      color: TpColors.pink,
                      darkOnColor: false,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _MiniStat(
                      label: 'Conv',
                      value: '${snapshot.conversionRate.toStringAsFixed(1)}%',
                      color: TpColors.mint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    this.darkOnColor = true,
  });
  final String label;
  final String value;
  final Color color;
  final bool darkOnColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TpText.display4.copyWith(
                fontSize: 16,
                color: darkOnColor ? TpColors.deepInk : Colors.white,
              )),
          Text(label,
              style: TpText.monoLabelSm.copyWith(
                color: darkOnColor
                    ? TpColors.deepInk.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.85),
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Share link row + tabs
// ---------------------------------------------------------------------------

class _ShareLinkRow extends StatelessWidget {
  const _ShareLinkRow({required this.snapshot});
  final AffiliateSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClayCard(
          color: TpColors.deepInk,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  snapshot.referralUrl.isEmpty ? 'สร้างลิงก์ของคุณ…' : snapshot.referralUrl,
                  overflow: TextOverflow.ellipsis,
                  style: TpText.monoTag.copyWith(color: Colors.white, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: snapshot.referralUrl.isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: snapshot.referralUrl));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('คัดลอกแล้ว')),
                          );
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: TpColors.mango,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('คัดลอก',
                      style: TpText.btnSm.copyWith(color: TpColors.deepInk, fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabsRow extends StatelessWidget {
  const _TabsRow({required this.index, required this.onChange});
  final int index;
  final ValueChanged<int> onChange;

  static const _labels = ['ลิงก์ทั้งหมด', 'เพื่อนที่ชวน', 'Tier'];

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Row(
          children: [
            for (var i = 0; i < _labels.length; i++) ...[
              GestureDetector(
                onTap: () => onChange(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: i == index ? TpColors.pink : TpColors.card,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: i == index
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
                  child: Text(
                    _labels[i],
                    style: TpText.titleSm.copyWith(
                      fontSize: 11,
                      color: i == index ? Colors.white : TpColors.ink,
                    ),
                  ),
                ),
              ),
              if (i < _labels.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top links
// ---------------------------------------------------------------------------

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.link});
  final AffiliateLink link;

  @override
  Widget build(BuildContext context) {
    final hue = BlobHue.values[link.hue % BlobHue.values.length];
    final bgTint = hue == BlobHue.leaf || hue == BlobHue.mint
        ? TpColors.mintTint
        : hue == BlobHue.mango || hue == BlobHue.tomato
            ? TpColors.mangoTint
            : TpColors.pinkTint;

    return ClayCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgTint,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Puff(width: 44, height: 34, hue: hue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${link.productName} · ${link.shopName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TpText.titleMd.copyWith(fontSize: 12)),
                Text(
                  '${link.clicks} clicks · ${link.commissionPercent.toStringAsFixed(1)}% commission',
                  style: TpText.monoLabel,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('฿${link.earningsThb.round()}', style: TpText.display4.copyWith(fontSize: 15)),
              Text('EARNED',
                  style: TpText.monoLabelSm.copyWith(color: TpColors.mint)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Invite card
// ---------------------------------------------------------------------------

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.snapshot});
  final AffiliateSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: ClayCard(
        color: TpColors.mango,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _AvatarStack(invited: snapshot.invitedCount),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ชวนแล้ว ${snapshot.invitedCount} คน',
                          style: TpText.titleLg.copyWith(fontSize: 13, fontWeight: FontWeight.w800)),
                      Text(
                        snapshot.invitesToNextTier == 0
                            ? 'ยอดเยี่ยมมาก! 🎉'
                            : 'ชวนอีก ${snapshot.invitesToNextTier} คน → เลื่อน '
                                '${(snapshot.tier.next ?? snapshot.tier).label}',
                        style: TpText.bodyXs,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PuffyButton(
              label: '↗ แชร์ลิงก์ชวน',
              variant: PuffyVariant.ink,
              fullWidth: true,
              onPressed: snapshot.referralUrl.isEmpty
                  ? null
                  : () async {
                      await Clipboard.setData(ClipboardData(text: snapshot.referralUrl));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('คัดลอกลิงก์ชวนแล้ว')),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.invited});
  final int invited;

  static const _colors = [TpColors.pink, TpColors.mint, TpColors.purple];
  static const _labels = ['ฝ', 'ต', 'ส'];

  @override
  Widget build(BuildContext context) {
    final shown = _colors.length;
    final extra = invited > shown ? invited - shown : 0;
    return SizedBox(
      width: 34.0 * shown - 10.0 * (shown - 1) + (extra > 0 ? 24 : 0),
      height: 34,
      child: Stack(
        children: [
          for (var i = 0; i < shown; i++)
            Positioned(
              left: (i * 24).toDouble(),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _colors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: TpColors.mango, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(_labels[i],
                    style: TpText.titleMd.copyWith(color: Colors.white, fontSize: 13)),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: (shown * 24).toDouble(),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: TpColors.deepInk,
                  shape: BoxShape.circle,
                  border: Border.all(color: TpColors.mango, width: 2),
                ),
                alignment: Alignment.center,
                child: Text('+$extra',
                    style: TpText.titleMd.copyWith(color: TpColors.mango, fontSize: 11)),
              ),
            ),
        ],
      ),
    );
  }
}
