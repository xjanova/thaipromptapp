import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/puffy_button.dart';

/// Stub — full Topup flow lands in Phase 3.2 (QR generator via walletTopup API,
/// amount keypad, expiry timer). Screen exists so routing works end-to-end.
class TopupPage extends StatelessWidget {
  const TopupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.deepInk,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('เติมเงิน', style: TpText.titleLg.copyWith(color: Colors.white)),
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
              const Icon(Icons.construction_rounded, size: 56, color: TpColors.mango),
              const SizedBox(height: 12),
              Text('กำลังจะเปิดใช้งานเร็ว ๆ นี้',
                  style: TpText.display3.copyWith(color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                'หน้านี้จะสร้าง QR PromptPay สำหรับเติมเงินเข้ากระเป๋า · Phase 3.2',
                textAlign: TextAlign.center,
                style: TpText.bodySm.copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 20),
              PuffyButton(
                label: 'กลับ',
                variant: PuffyVariant.mango,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
