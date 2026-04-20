import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ai/ai_engine.dart';
import '../../core/ai/nong_ying_service.dart';
import '../../core/ai/prompts.dart';
import '../../core/analytics/event_tracker.dart';
import '../../core/analytics/event_types.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../core/tts/tts_service.dart';
import '../../shared/widgets/blob_3d.dart';
import '../../shared/widgets/clay_card.dart';

/// The chat page for "น้องหญิง".
///
/// Shown as a bottom sheet from the floating button, or as a full-screen
/// route when deep-linked.
class NongYingChatPage extends ConsumerStatefulWidget {
  const NongYingChatPage({
    super.key,
    this.initialContext = const {},
  });

  final Map<String, Object?> initialContext;

  static Future<void> show(BuildContext context, {Map<String, Object?> context0 = const {}}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.92,
        child: NongYingChatPage(initialContext: context0),
      ),
    );
  }

  @override
  ConsumerState<NongYingChatPage> createState() => _NongYingChatPageState();
}

class _NongYingChatPageState extends ConsumerState<NongYingChatPage> {
  final _composerCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<ChatTurn> _history = [];
  String _pendingReply = '';
  bool _streaming = false;
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    // Greeting from น้องหญิง — not sent to the model, just displayed.
    // If the on-device model isn't installed yet, switch to the install-
    // nudge greeting so the user's very first bubble invites them to
    // set up the model (with a [GO:/nong-ying/install] chip). Cloud mode
    // still works — the nudge is additive, not a block.
    _history.add(const ChatTurn(role: ChatRole.assistant, text: NongYingPrompts.greeting));
    _maybeSwapGreetingForInstallNudge();
  }

  Future<void> _maybeSwapGreetingForInstallNudge() async {
    try {
      final svc = await ref.read(nongYingServiceProvider.future);
      final installed = await svc.isOnDeviceInstalled();
      if (!mounted || installed) return;
      // Only replace the greeting if we haven't started a real conversation.
      final hasUserTurn = _history.any((t) => t.role == ChatRole.user);
      if (hasUserTurn) return;
      setState(() {
        _history
          ..clear()
          ..add(const ChatTurn(
            role: ChatRole.assistant,
            text: NongYingPrompts.greetingNotInstalled,
          ));
      });
    } catch (_) {
      // Swallow — the default greeting is a safe fallback.
    }
  }

  @override
  void dispose() {
    _composerCtrl.dispose();
    _scrollCtrl.dispose();
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _streaming) return;

    setState(() {
      _history.add(ChatTurn(role: ChatRole.user, text: trimmed));
      _composerCtrl.clear();
      _pendingReply = '';
      _streaming = true;
    });

    // Fire-and-forget analytics — don't await to avoid blocking the reply.
    unawaited(_trackQuery(trimmed));

    try {
      final service = await ref.read(nongYingServiceProvider.future);
      final stream = service.ask(
        history: _history,
        context: widget.initialContext,
      );
      // Strip any male polite particles before they reach the bubble.
      final sanitizer = ReplySanitizer();
      _sub = stream.listen((chunk) {
        final safe = sanitizer.process(chunk);
        if (safe.isEmpty) return;
        setState(() {
          _pendingReply += safe;
        });
        _scrollToBottom();
      }, onDone: () {
        final tail = sanitizer.flush();
        setState(() {
          if (tail.isNotEmpty) _pendingReply += tail;
          if (_pendingReply.isNotEmpty) {
            _history.add(ChatTurn(role: ChatRole.assistant, text: _pendingReply));
          }
          _pendingReply = '';
          _streaming = false;
        });
        // Do NOT auto-speak — users tap the "ฟังเสียง" button on a bubble to hear it.
      }, onError: (Object e) {
        setState(() {
          _history.add(
            ChatTurn(
              role: ChatRole.assistant,
              text: 'น้องเจอปัญหาค่ะ ขออภัยนะคะ · $e',
            ),
          );
          _pendingReply = '';
          _streaming = false;
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _history.add(
          ChatTurn(
            role: ChatRole.assistant,
            text: 'น้องยังไม่พร้อมค่ะ ($e)',
          ),
        );
        _streaming = false;
      });
    }
  }

  Future<void> _trackQuery(String text) async {
    try {
      final tracker = await ref.read(eventTrackerProvider.future);
      await tracker.track(EventNames.aiQuery, props: {
        'len': text.length,
        'context_keys': widget.initialContext.keys.toList(),
      });
    } catch (_) {
      // telemetry is best-effort
    }
  }

  Future<void> _speakText(String text) async {
    try {
      final tts = await ref.read(ttsServiceProvider.future);
      if (!tts.isReady) return;
      await tts.speak(text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('พูดไม่ได้ค่ะ · $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: Scaffold(
        backgroundColor: TpColors.paper,
        appBar: _Header(onClose: () => Navigator.of(context).maybePop()),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                children: [
                  for (final turn in _history)
                    _Bubble(turn: turn, onSpeak: turn.role == ChatRole.assistant ? _speakText : null),
                  if (_pendingReply.isNotEmpty)
                    _Bubble(turn: ChatTurn(role: ChatRole.assistant, text: _pendingReply)),
                  if (_streaming && _pendingReply.isEmpty) const _TypingIndicator(),
                ],
              ),
            ),
            _Suggestions(
              onTap: _streaming ? null : _send,
            ),
            _Composer(
              controller: _composerCtrl,
              onSend: () => _send(_composerCtrl.text),
              streaming: _streaming,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget implements PreferredSizeWidget {
  const _Header({required this.onClose});
  final VoidCallback onClose;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: const BoxDecoration(
        color: TpColors.mango,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Blob3D(size: 32, hue: BlobHue.pink),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('น้องหญิง', style: TpText.titleLg.copyWith(fontSize: 16)),
                  Text('ผู้ช่วยซื้อของที่น่ารักของคุณ', style: TpText.bodyXs),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.turn, this.onSpeak});
  final ChatTurn turn;
  final ValueChanged<String>? onSpeak;

  @override
  Widget build(BuildContext context) {
    final isMe = turn.role == ChatRole.user;
    final bg = isMe ? TpColors.pink : TpColors.card;
    final fg = isMe ? Colors.white : TpColors.ink;

    // Assistant bubbles may contain [GO:/path] tokens that we render as
    // tappable chips instead of leaving them in the prose.
    final links = isMe ? const <ReplyDeepLink>[] : ReplyDeepLink.extract(turn.text);
    final body = isMe ? turn.text : ReplyDeepLink.strip(turn.text);
    final showSpeak = !isMe && onSpeak != null && body.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (body.isNotEmpty)
                ClayCard(
                  color: bg,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shadow: ClayShadow.small,
                  child: Text(body,
                      style: TpText.bodySm.copyWith(color: fg, height: 1.45)),
                ),
              if (links.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [for (final l in links) _DeepLinkChip(link: l)],
                  ),
                ),
              if (showSpeak)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 6),
                  child: GestureDetector(
                    onTap: () => onSpeak!(body),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up_rounded, size: 14, color: TpColors.muted),
                        const SizedBox(width: 4),
                        Text('ฟังเสียง', style: TpText.bodyXs.copyWith(color: TpColors.muted)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill button that dismisses the chat sheet and navigates to the
/// linked path. Used to render `[GO:/path]` tokens in assistant replies.
class _DeepLinkChip extends StatelessWidget {
  const _DeepLinkChip({required this.link});
  final ReplyDeepLink link;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          // Close the bottom sheet first so the target route sits on top.
          final navigator = Navigator.of(context);
          if (navigator.canPop()) navigator.pop();
          context.go(link.path);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: TpColors.mangoTint,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: TpColors.mango, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_outward_rounded,
                  size: 14, color: TpColors.ink),
              const SizedBox(width: 5),
              Text(
                _labelFor(link.path),
                style: TpText.bodyXs.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: TpColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelFor(String path) {
    if (path.startsWith('/taladsod/listings?category=')) return 'เข้าหมวด';
    if (path.startsWith('/taladsod/listings/')) return 'ดูสินค้า';
    if (path.startsWith('/taladsod/sellers/')) return 'เข้าร้าน';
    if (path.startsWith('/shop/')) return 'เข้าร้าน';
    if (path.startsWith('/product/')) return 'ดูสินค้า';
    if (path == '/taladsod') return 'ไปตลาดสด';
    if (path == '/taladsod/listings') return 'ดูสินค้าทั้งหมด';
    if (path == '/taladsod/orders') return 'ออเดอร์ของฉัน';
    if (path == '/cart') return 'ตะกร้า';
    if (path == '/wallet') return 'Wallet';
    if (path == '/wallet/topup') return 'เติมเงิน';
    if (path == '/wallet/transfer') return 'โอน';
    if (path == '/wallet/scan') return 'สแกน QR';
    if (path == '/affiliate') return 'Affiliate';
    if (path == '/settings') return 'ตั้งค่า';
    if (path == '/nong-ying/install') return 'ติดตั้งน้องหญิง';
    return 'เปิดหน้า';
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ClayCard(
          color: TpColors.card,
          shadow: ClayShadow.small,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(index: 0),
              _Dot(index: 1),
              _Dot(index: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: const BoxDecoration(
        color: TpColors.muted,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .moveY(begin: 0, end: -3, duration: 500.ms, delay: (index * 120).ms)
        .then()
        .moveY(begin: -3, end: 0, duration: 500.ms);
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onTap});
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: NongYingPrompts.suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final s = NongYingPrompts.suggestions[i];
          return Center(
            child: GestureDetector(
              onTap: onTap == null ? null : () => onTap!(s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: TpColors.mangoTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(s,
                    style: TpText.bodySm.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.streaming,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool streaming;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        decoration: const BoxDecoration(
          color: TpColors.paper,
          border: Border(top: BorderSide(color: Color(0x1F2E1A5C))),
        ),
        child: Row(
          children: [
            Expanded(
              child: ClayCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shadow: ClayShadow.small,
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'พิมพ์คำถามให้น้องหญิง...',
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: streaming ? null : onSend,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: streaming ? TpColors.muted : TpColors.pink,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: streaming
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void unawaited(Future<void> f) {}
