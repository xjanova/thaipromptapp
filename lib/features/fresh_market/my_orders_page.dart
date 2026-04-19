import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../shared/models/fresh_market.dart';
import '../../shared/widgets/blob_3d.dart';
import '../../shared/widgets/clay_card.dart';
import 'fresh_market_repository.dart';
import 'widgets/listing_card.dart';

/// Buyer's Fresh Market order history.
///
/// v1: simple list, no filters yet (server supports `?status=`). Pagination
/// is page-1 only — list rarely exceeds 15 items per buyer in early days.
class TaladsodMyOrdersPage extends ConsumerWidget {
  const TaladsodMyOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(_myOrdersProvider);

    return Scaffold(
      backgroundColor: TpColors.paper,
      appBar: AppBar(
        backgroundColor: TpColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('ออเดอร์ตลาดสด'),
        titleTextStyle: TpText.titleLg.copyWith(color: TpColors.ink),
        iconTheme: const IconThemeData(color: TpColors.ink),
      ),
      body: orders.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: TpColors.leaf),
        ),
        error: (e, _) => _ErrorView(error: '$e'),
        data: (items) {
          if (items.isEmpty) return const _Empty();
          return RefreshIndicator(
            color: TpColors.leaf,
            onRefresh: () async {
              ref.invalidate(_myOrdersProvider);
              await ref.read(_myOrdersProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _OrderTile(order: items[i]),
            ),
          );
        },
      ),
    );
  }
}

final _myOrdersProvider =
    FutureProvider<List<TmOrderListItem>>((ref) async {
  final repo = await ref.watch(freshMarketRepositoryProvider.future);
  return repo.myOrders();
});

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});
  final TmOrderListItem order;

  Color get _statusColor => switch (order.orderStatus) {
        'pending' => TpColors.mango,
        'accepted' || 'preparing' || 'ready' => TpColors.sky,
        'on_the_way' => TpColors.purple,
        'delivered' || 'completed' => TpColors.leaf,
        'cancelled' || 'refunded' => TpColors.pink,
        _ => TpColors.muted,
      };

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: order.listingImage != null && order.listingImage!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: order.listingImage!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 64, height: 64,
                      color: TpColors.paper2,
                    ),
                    errorWidget: (_, __, ___) => SizedBox(
                      width: 64,
                      height: 64,
                      child: Center(
                        child: Blob3D(size: 48, hue: listingHueFor(order.id)),
                      ),
                    ),
                  )
                : SizedBox(
                    width: 64,
                    height: 64,
                    child: Center(
                      child: Blob3D(size: 48, hue: listingHueFor(order.id)),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.listingTitle ?? '(ไม่พบสินค้า)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TpText.bodyMd.copyWith(
                          color: TpColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      formatBaht(order.totalAmount,
                          decimals: order.totalAmount % 1 != 0),
                      style: TpText.bodyMd.copyWith(
                        color: TpColors.leaf,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '#${order.orderNumber} · ${order.shopName ?? "?"} · จำนวน ${order.quantity}',
                  style: TpText.bodyXs.copyWith(color: TpColors.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.statusLabel,
                        style: TpText.bodyXs.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (order.cashbackAmount != null && order.cashbackAmount! > 0)
                      Text('🪙 +${formatBaht(order.cashbackAmount!)}',
                          style: TpText.bodyXs.copyWith(
                            color: const Color(0xFF8C6F00),
                            fontWeight: FontWeight.w700,
                          )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long, size: 48, color: TpColors.muted),
          const SizedBox(height: 12),
          Text('ยังไม่มีออเดอร์',
              style: TpText.titleLg.copyWith(color: TpColors.muted)),
          const SizedBox(height: 4),
          Text('สั่งของจากตลาดสดเลยค่ะ',
              style: TpText.bodySm.copyWith(color: TpColors.muted)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'โหลดประวัติออเดอร์ไม่สำเร็จ\n$error',
          textAlign: TextAlign.center,
          style: TpText.bodySm.copyWith(color: TpColors.pink),
        ),
      ),
    );
  }
}
