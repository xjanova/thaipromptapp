import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exceptions.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../shared/models/fresh_market.dart';
import 'fresh_market_repository.dart';

/// Modal bottom sheet that walks the buyer through quantity, delivery, and
/// payment for a single listing, then submits to `/v1/fresh-market/orders`.
///
/// On success → pops the sheet, shows a success snackbar, navigates to the
/// freshly-created order's detail screen.
/// On error → renders the localized error in-sheet so the buyer can retry
/// without losing their picks.
class OrderSheet extends ConsumerStatefulWidget {
  const OrderSheet({super.key, required this.detail});

  final TmListingDetail detail;

  @override
  ConsumerState<OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends ConsumerState<OrderSheet> {
  int _qty = 1;
  TmDeliveryType _delivery = TmDeliveryType.rider;
  TmPaymentMethod _payment = TmPaymentMethod.wallet;
  final _addressCtl = TextEditingController();
  final _notesCtl = TextEditingController();
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _addressCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  TmListing get _l => widget.detail.listing;

  double get _subtotal => _l.price * _qty;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final repo = await ref.read(freshMarketRepositoryProvider.future);
      final order = await repo.placeOrder(
        listingId: _l.id,
        quantity: _qty,
        deliveryType: _delivery,
        paymentMethod: _payment,
        deliveryAddress: _addressCtl.text.trim().isEmpty
            ? null
            : _addressCtl.text.trim(),
        deliveryNotes:
            _notesCtl.text.trim().isEmpty ? null : _notesCtl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: TpColors.leaf,
          content: Text('สั่งซื้อสำเร็จ · เลขที่ ${order.orderNumber}'),
        ),
      );
      // Take buyer to their orders list — order detail screen is next phase.
      context.push('/taladsod/orders');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = 'เกิดข้อผิดพลาด: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxQty = _l.quantityAvailable;

    return Container(
      decoration: const BoxDecoration(
        color: TpColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: TpColors.muted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('สั่งซื้อ', style: TpText.display3.copyWith(color: TpColors.ink)),
          const SizedBox(height: 4),
          Text(_l.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TpText.bodyMd.copyWith(color: TpColors.muted)),
          const SizedBox(height: 18),

          // Qty stepper
          Row(
            children: [
              Text('จำนวน',
                  style: TpText.bodyMd.copyWith(
                      color: TpColors.ink, fontWeight: FontWeight.w700)),
              const Spacer(),
              _Stepper(
                value: _qty,
                min: 1,
                max: maxQty,
                onChanged: (v) => setState(() => _qty = v),
              ),
              const SizedBox(width: 8),
              Text(_l.unit, style: TpText.bodySm.copyWith(color: TpColors.muted)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text('คงเหลือ ${_l.quantityAvailable} ${_l.unit}',
                style: TpText.bodyXs.copyWith(color: TpColors.muted)),
          ),

          const SizedBox(height: 18),
          Text('การจัดส่ง',
              style: TpText.bodyMd.copyWith(
                  color: TpColors.ink, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TmDeliveryType.values
                .map((t) => ChoiceChip(
                      label: Text(t.label),
                      selected: _delivery == t,
                      onSelected: (_) => setState(() => _delivery = t),
                    ))
                .toList(),
          ),
          if (_delivery != TmDeliveryType.pickup) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _addressCtl,
              decoration: const InputDecoration(
                hintText: 'ที่อยู่จัดส่ง (บ้านเลขที่ ถนน ตำบล ...)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
          ],

          const SizedBox(height: 16),
          Text('วิธีชำระเงิน',
              style: TpText.bodyMd.copyWith(
                  color: TpColors.ink, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TmPaymentMethod.values
                .map((p) => ChoiceChip(
                      label: Text(p.label),
                      selected: _payment == p,
                      onSelected: (_) => setState(() => _payment = p),
                    ))
                .toList(),
          ),

          const SizedBox(height: 14),
          TextField(
            controller: _notesCtl,
            decoration: const InputDecoration(
              hintText: 'หมายเหตุถึงผู้ขาย (ไม่บังคับ)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 18),
          // Subtotal row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: TpColors.mintTint,
              borderRadius: BorderRadius.circular(TpRadii.medium),
            ),
            child: Row(
              children: [
                Text('รวม',
                    style: TpText.bodyMd.copyWith(
                        color: TpColors.ink, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(formatBaht(_subtotal, decimals: _subtotal % 1 != 0),
                    style: TpText.titleLg
                        .copyWith(color: TpColors.leaf, fontSize: 22)),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(_errorMessage!,
                style: TpText.bodySm.copyWith(color: TpColors.pink)),
          ],
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _submitting ? null : _submit,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: _submitting ? TpColors.muted : TpColors.leaf,
                borderRadius: BorderRadius.circular(TpRadii.button),
                boxShadow: _submitting ? null : TpShadows.clay,
              ),
              alignment: Alignment.center,
              child: Text(
                _submitting ? 'กำลังสั่ง ...' : 'ยืนยันคำสั่งซื้อ',
                style: TpText.bodyMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TpColors.card,
        borderRadius: BorderRadius.circular(TpRadii.button),
        boxShadow: TpShadows.claySm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            color: value > min ? TpColors.ink : TpColors.muted,
            onPressed: value > min ? () => onChanged(value - 1) : null,
            visualDensity: VisualDensity.compact,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 36),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TpText.bodyMd.copyWith(
                color: TpColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            color: value < max ? TpColors.ink : TpColors.muted,
            onPressed: value < max ? () => onChanged(value + 1) : null,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
