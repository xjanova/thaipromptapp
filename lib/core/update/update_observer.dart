import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/update/update_dialog.dart';
import '../auth/auth_state.dart';
import 'update_service.dart';

/// Triggers an update check as soon as auth state resolves — whether the
/// user is logged in OR browsing as a guest. The endpoint is public, so
/// gating on AuthAuthenticated meant guest users (the majority on first
/// launch) never saw the update prompt and got stranded on whatever
/// version they sideloaded weeks ago.
///
/// Intentionally idempotent per app-launch: we don't re-prompt after the
/// user dismisses unless they relaunch the app.
class UpdateObserver extends ConsumerStatefulWidget {
  const UpdateObserver({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<UpdateObserver> createState() => _UpdateObserverState();
}

class _UpdateObserverState extends ConsumerState<UpdateObserver> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    // If auth has already resolved by the time we mount (warm start /
    // hot reload), kick the check ourselves — `ref.listen` only fires
    // on FUTURE state changes, not the current value.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _checked || !Platform.isAndroid) return;
      final auth = ref.read(authControllerProvider);
      if (auth is! AuthUnknown) {
        _checked = true;
        _runCheck();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sideload update path is Android-only.
    if (Platform.isAndroid) {
      ref.listen(authControllerProvider, (prev, next) {
        // Fire on the FIRST resolved state — Authenticated or Unauthenticated
        // (i.e. anything other than the initial Unknown).
        if (!_checked && next is! AuthUnknown) {
          _checked = true;
          _runCheck();
        }
      });
    }
    return widget.child;
  }

  Future<void> _runCheck() async {
    // Tiny delay so the first frame gets to paint before we show a dialog.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    try {
      final svc = await ref.read(updateServiceProvider.future);
      final status = await svc.checkForUpdate();
      if (!mounted) return;
      if (status is UpdateAvailable) {
        await UpdateDialog.show(context, status);
      }
    } catch (_) {
      // Silent: update checks should never block the user.
    }
  }
}
