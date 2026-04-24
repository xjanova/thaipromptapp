import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puffy_button.dart';

/// Order review · star rating + tags + optional comment.
/// Reference: `buyer-app.jsx` → `BuyerReview`.

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key, required this.orderId});
  final int orderId;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _star = 5;
  final Set<String> _tags = {'อร่อย', 'ส่งเร็ว', 'บรรจุดี'};
  static const _availableTags = ['อร่อย', 'ส่งเร็ว', 'บรรจุดี', 'คุ้มราคา', 'สะอาด', 'ไรเดอร์สุภาพ'];
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  String get _starLabel {
    return switch (_star) {
      5 => 'ดีเยี่ยม!',
      4 => 'ชอบมาก',
      3 => 'ใช้ได้',
      _ => 'ปรับปรุงนะ',
    };
  }

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
                      onTap: () => context.go('/buyer/orders'),
                      child: const SizedBox(width: 34, height: 34, child: Icon(Icons.arrow_back_rounded, size: 18, color: TpColors.ink)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('REVIEW', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, letterSpacing: 1.8, color: TpColors.muted, fontWeight: FontWeight.w600)),
                        Text('รีวิวออเดอร์', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w900, fontSize: 16, color: TpColors.ink)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClayCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(color: TpColors.mango, borderRadius: BorderRadius.circular(18), boxShadow: TpShadows.claySm),
                      alignment: Alignment.center,
                      child: const Text('🍜', style: TextStyle(fontSize: 30)),
                    ),
                    const SizedBox(height: 8),
                    const Text('ข้าวซอยไก่ · ครัวยายปราณี', style: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontWeight: FontWeight.w900, fontSize: 15, color: TpColors.ink)),
                    Text('ออเดอร์ #TP-${widget.orderId} · เมื่อวาน', style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 11, color: TpColors.muted)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClayCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('ให้คะแนน', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, letterSpacing: 1.5, color: TpColors.muted)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var n = 1; n <= 5; n++)
                          GestureDetector(
                            onTap: () => setState(() => _star = n),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Text(
                                '★',
                                style: TextStyle(
                                  fontSize: 36,
                                  color: n <= _star ? TpColors.mango : const Color(0xFFE0D9C6),
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_starLabel, style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 12, fontWeight: FontWeight.w700, color: TpColors.pink)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClayCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('แท็ก', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, letterSpacing: 1.5, color: TpColors.muted)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: [
                        for (final t in _availableTags)
                          GestureDetector(
                            onTap: () => setState(() {
                              if (_tags.contains(t)) {
                                _tags.remove(t);
                              } else {
                                _tags.add(t);
                              }
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                              decoration: BoxDecoration(
                                color: _tags.contains(t) ? TpColors.mango : Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: TpShadows.claySm,
                              ),
                              child: Text(
                                '✓ $t',
                                style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 10, fontWeight: FontWeight.w700, color: TpColors.ink),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClayCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ข้อความถึงร้าน (ไม่บังคับ)', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, letterSpacing: 1.5, color: TpColors.muted)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: TpColors.paper, borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        controller: _commentCtrl,
                        maxLines: 3,
                        minLines: 3,
                        style: const TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 12, color: TpColors.ink),
                        decoration: const InputDecoration(
                          hintText: 'ของอร่อย ส่งเร็วมากเลยค่ะ ขอบคุณมากนะคะ 🙏',
                          hintStyle: TextStyle(fontFamily: 'IBM Plex Sans Thai', fontSize: 12, color: TpColors.muted),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PuffyButton(label: 'ส่งรีวิว', variant: PuffyVariant.pink, fullWidth: true, size: PuffySize.large, onPressed: () => context.go('/buyer/orders')),
            ),
          ],
        ),
      ),
    );
  }
}
