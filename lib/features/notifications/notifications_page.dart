import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';

/// Notifications inbox · reference: `buyer-app.jsx` → `BuyerNoti`.

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _items = <_Notif>[
    _Notif('ออเดอร์ #TP-8821 ถึงแล้ว', '5 นาทีที่แล้ว', '📦', TpColors.mint, true),
    _Notif('คูปองใหม่! ลด ฿50', '30 นาทีที่แล้ว', '🎁', TpColors.pink, true),
    _Notif('ร้านนิดา ลดราคา 3 รายการ', '2 ชม.', '🏷', TpColors.mango, false),
    _Notif('MLM: คุณได้คอม ฿64', 'เช้า', '฿', TpColors.purple, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.go('/buyer'),
                      child: const SizedBox(width: 34, height: 34, child: Icon(Icons.arrow_back_rounded, size: 18, color: TpColors.ink)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NOTIFICATIONS', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, letterSpacing: 1.8, color: TpColors.muted, fontWeight: FontWeight.w600)),
                        Text('การแจ้งเตือน', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w900, fontSize: 16, color: TpColors.ink)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final n in _items) ...[
                    ClayCard(
                      padding: const EdgeInsets.all(12),
                      shadow: ClayShadow.small,
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: n.color, borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center,
                            child: Text(n.icon, style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.title, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w800, fontSize: 12, color: TpColors.ink)),
                                Text(n.when, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TpColors.muted)),
                              ],
                            ),
                          ),
                          if (n.unread)
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(color: TpColors.pink, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notif {
  const _Notif(this.title, this.when, this.icon, this.color, this.unread);
  final String title, when, icon;
  final Color color;
  final bool unread;
}
