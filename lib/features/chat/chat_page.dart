import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_state.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/models/commerce.dart';
import '../../shared/widgets/blob_3d.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puff.dart';
import 'chat_repository.dart';

/// Port of `Chat` in screens-b.jsx.
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.orderId, this.shopName});
  final int orderId;
  final String? shopName;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _composerCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _composerCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _composerCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _composerCtrl.clear();

    try {
      final auth = ref.read(authControllerProvider);
      final userId = auth is AuthAuthenticated ? auth.user.id : -1;
      final repo = await ref.read(chatRepositoryProvider.future);
      await repo.send(widget.orderId, text: text, currentUserId: userId);
      ref.invalidate(chatMessagesProvider(widget.orderId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ส่งไม่ได้: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(widget.orderId));

    return Scaffold(
      backgroundColor: TpColors.paper,
      body: Column(
        children: [
          _Header(shopName: widget.shopName ?? 'ร้านค้า'),
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator(color: TpColors.pink)),
              error: (e, _) => Center(child: Text('โหลดข้อความไม่ได้: $e', style: TpText.bodyMd)),
              data: (msgs) => _MessageList(messages: msgs, controller: _scrollCtrl),
            ),
          ),
          _Composer(
            controller: _composerCtrl,
            onSend: _send,
            sending: _sending,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.shopName});
  final String shopName;

  @override
  Widget build(BuildContext context) {
    final initial = shopName.characters.first;
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: const BoxDecoration(
          color: TpColors.mango,
          border: Border(bottom: BorderSide(color: Color(0x1F2E1A5C))),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: TpColors.pink,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(initial,
                  style: TpText.display4.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(shopName, style: TpText.titleMd.copyWith(fontSize: 13)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: TpColors.mint,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('ออนไลน์ · ตอบเร็ว', style: TpText.bodyXs.copyWith(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone_rounded, size: 20),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Messages
// ---------------------------------------------------------------------------

class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages, required this.controller});
  final List<ChatMessage> messages;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'เริ่มคุยกันเลย ทักทายร้านได้เลยค่ะ',
          style: TpText.bodyMd.copyWith(color: TpColors.muted),
        ),
      );
    }

    return Container(
      color: TpColors.paper,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(opacity: 0.4, child: CustomPaint(painter: _DotsPainter())),
            ),
          ),
          ListView.builder(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            itemCount: messages.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) return _DateHeader();
              final m = messages[i - 1];
              return _Bubble(msg: m);
            },
          ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Center(
        child: Text(
          'วันนี้ · ${now.day} ${thMonths[now.month - 1]}',
          style: TpText.monoLabel.copyWith(fontSize: 10),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});
  final ChatMessage msg;

  @override
  Widget build(BuildContext context) {
    final isMe = msg.side == MessageSide.me;
    final bg = isMe ? TpColors.pink : TpColors.card;
    final fg = isMe ? Colors.white : TpColors.ink;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.76,
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 6),
                    bottomRight: Radius.circular(isMe ? 6 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: TpText.bodySm.copyWith(color: fg, height: 1.45),
                ),
              ),
              if (msg.attachment != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _AttachmentCard(attachment: msg.attachment!),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(msg.timeText, style: TpText.monoLabelSm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  const _AttachmentCard({required this.attachment});
  final ChatAttachment attachment;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(8),
      shadow: ClayShadow.small,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TpColors.pinkTint,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Puff(width: 32, height: 24, hue: BlobHue.tomato),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(attachment.productName, style: TpText.titleSm.copyWith(fontSize: 11)),
                Text(
                  '฿${attachment.priceThb.toStringAsFixed(0)}${attachment.freeDelivery ? ' · ส่งฟรี' : ''}',
                  style: TpText.monoLabel,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/product/${attachment.productId}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: TpColors.pink,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'สั่ง',
                style: TpText.btnSm.copyWith(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Composer
// ---------------------------------------------------------------------------

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend, required this.sending});
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: TpColors.paper,
          border: Border(top: BorderSide(color: Color(0x1F2E1A5C))),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: TpColors.mango,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.add_rounded, size: 18),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClayCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shadow: ClayShadow.small,
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'พิมพ์ข้อความ...',
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: sending ? null : onSend,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: sending ? TpColors.muted : TpColors.pink,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: sending
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = TpColors.ink.withValues(alpha: 0.18);
    for (double y = 0; y < size.height; y += 14) {
      for (double x = 0; x < size.width; x += 14) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
