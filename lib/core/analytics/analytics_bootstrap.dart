import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/consent/consent_sheet.dart';
import '../auth/auth_state.dart';
import 'event_tracker.dart';
import 'event_types.dart';

/// After auth resolves we:
///   1. Ask for analytics consent (once per install)
///   2. Bind app lifecycle observer (so background flushes)
///   3. Emit `session_start`
///
/// The observer is idempotent per process.
class AnalyticsBootstrap extends ConsumerStatefulWidget {
  const AnalyticsBootstrap({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AnalyticsBootstrap> createState() => _AnalyticsBootstrapState();
}

class _AnalyticsBootstrapState extends ConsumerState<AnalyticsBootstrap> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (_, next) {
      if (next is AuthAuthenticated && !_handled) {
        _handled = true;
        _bootstrap();
      }
    });
    return widget.child;
  }

  Future<void> _bootstrap() async {
    final tracker = await ref.read(eventTrackerProvider.future);
    tracker.bindAppLifecycle();

    if (!tracker.consented) {
      // Let the first frame paint before sheet.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      await ConsentSheet.show(context);
    }

    await tracker.track(EventNames.sessionStart);
    await tracker.track(EventNames.appOpen);
  }
}
