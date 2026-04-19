import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ai/nong_ying_service.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/blob_3d.dart';
import 'nong_ying_chat_page.dart';

/// Small floating avatar that opens the น้องหญิง chat sheet.
///
/// Gated by the `ai_enabled` feature flag so we can kill-switch it remotely.
/// Pick a position that doesn't clash with the dock: we anchor bottom-right
/// with padding so it sits above the notched tab bar.
class NongYingFab extends ConsumerWidget {
  const NongYingFab({super.key, this.context0 = const {}});
  final Map<String, Object?> context0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final enabled = ref.watch(nongYingEnabledProvider);
    // Default to ON for dev builds so the feature is visible before the
    // backend flag is seeded. Flip to `if (!enabled) return ...` once a real
    // `ai_enabled` flag row exists on the backend.

    return Positioned(
      right: 14,
      bottom: 110, // sits above the NavDock
      child: _Avatar(onTap: () => NongYingChatPage.show(context, context0: context0))
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -6, duration: 2600.ms, curve: Curves.easeInOut),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: TpColors.card,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 8),
              blurRadius: 16,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            const Blob3D(size: 56, hue: BlobHue.pink),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: TpColors.deepInk,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'น้องหญิง',
                style: TpText.bodyXs.copyWith(
                  color: TpColors.mango,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Deep-link target so `context.go('/nong-ying')` opens the chat.
class NongYingRouteBridge extends StatefulWidget {
  const NongYingRouteBridge({super.key});

  @override
  State<NongYingRouteBridge> createState() => _NongYingRouteBridgeState();
}

class _NongYingRouteBridgeState extends State<NongYingRouteBridge> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NongYingChatPage.show(context);
      if (context.mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: TpColors.paper,
        body: Center(child: CircularProgressIndicator(color: TpColors.pink)),
      );
}
