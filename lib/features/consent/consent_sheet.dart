import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/event_tracker.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puffy_button.dart';

/// One-time PDPA/analytics consent sheet.
///
/// Shown on first launch (after onboarding) before any analytics events fire.
/// The bool is persisted by [EventTracker.setConsent] so we don't re-ask.
class ConsentSheet extends ConsumerWidget {
  const ConsentSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ConsentSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ClayCard(
          color: TpColors.paper,
          padding: const EdgeInsets.all(20),
          shadow: ClayShadow.large,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ช่วยพัฒนา Thaiprompt ด้วยกันมั้ยคะ?',
                  style: TpText.display4),
              const SizedBox(height: 8),
              Text(
                'เราใช้ข้อมูลเบื้องต้น (หน้าที่เปิด · สินค้าที่ดู · พื้นที่ระดับ 5km) '
                'เพื่อแนะนำสินค้าให้ตรงใจและปรับปรุงแอพ '
                '· ไม่เก็บตำแหน่งแบบละเอียด · ไม่ขายข้อมูล · เปลี่ยนใจได้ตลอดในเมนูตั้งค่า',
                style: TpText.bodySm,
              ),
              const SizedBox(height: 16),
              const _Bullet(icon: Icons.location_on_outlined, text: 'ตำแหน่งแบบพื้นที่ (≈5 กม.)'),
              const _Bullet(icon: Icons.touch_app_outlined, text: 'การกด/ดูสินค้าและหมวด'),
              const _Bullet(icon: Icons.lock_outline_rounded, text: 'ไม่มีข้อมูลติดต่อ · ไม่มีข้อความแชท'),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: PuffyButton(
                      label: 'ไม่ตอนนี้',
                      variant: PuffyVariant.ghost,
                      fullWidth: true,
                      onPressed: () async {
                        await _set(ref, on: false);
                        if (context.mounted) Navigator.of(context).pop(false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PuffyButton(
                      label: 'อนุญาต',
                      variant: PuffyVariant.pink,
                      fullWidth: true,
                      onPressed: () async {
                        await _set(ref, on: true);
                        if (context.mounted) Navigator.of(context).pop(true);
                      },
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

  Future<void> _set(WidgetRef ref, {required bool on}) async {
    final tracker = await ref.read(eventTrackerProvider.future);
    await tracker.setConsent(on);
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: TpColors.muted),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TpText.bodySm)),
        ],
      ),
    );
  }
}
