import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/puffy_button.dart';

/// Stub — Transfer + PIN flow full implementation in Phase 3.3.
/// Uses [PinService] for constant-time HMAC verification.
class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.deepInk,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('โอนเงิน', style: TpText.titleLg.copyWith(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swap_horiz_rounded, size: 56, color: TpColors.pink),
              const SizedBox(height: 12),
              Text('โอนเงินพร้อม PIN', style: TpText.display3.copyWith(color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                'ระบุ wallet address ผู้รับ → ยืนยันด้วย PIN · Phase 3.3',
                textAlign: TextAlign.center,
                style: TpText.bodySm.copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 20),
              PuffyButton(
                label: 'กลับ',
                variant: PuffyVariant.pink,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
