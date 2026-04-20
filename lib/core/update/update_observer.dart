import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../features/splash/splash_gate.dart';
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
///
/// Dialog plumbing: `UpdateObserver` sits in `MaterialApp.router`'s
/// `builder:` callback, which is ABOVE the router's Navigator. A raw
/// `showDialog(context: context, ...)` from here walks up the ancestor
/// chain and never finds a Navigator → assertion → swallowed by our
/// catch-all → user sees nothing. We route the dialog through the
/// router's [rootNavigatorKey] instead so the Navigator is always found.
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
    try {
      // Run the network check in parallel with the splash animation so
      // the dialog is ready to pop the moment the splash finishes.
      final svcFuture = ref.read(updateServiceProvider.future);
      final svc = await svcFuture;
      final status = await svc.checkForUpdate();
      if (!mounted) return;

      if (kDebugMode) {
        debugPrint('[UpdateObserver] check result: $status');
      }

      if (status is! UpdateAvailable) return;

      // Wait until the splash intro has finished before pushing a dialog.
      // Showing on /splash would paint the update sheet over the logo
      // animation; wait for the router to land on /onboarding or /home
      // so the dialog overlays an actual content frame.
      await _waitForSplashGate();
      if (!mounted) return;

      // Use the router's root Navigator rather than our own context
      // (see class doc above — builder-scope has no Navigator ancestor).
      final navCtx = rootNavigatorKey.currentContext;
      if (navCtx == null) {
        if (kDebugMode) {
          debugPrint(
              '[UpdateObserver] rootNavigatorKey has no context yet — skipping');
        }
        return;
      }
      await UpdateDialog.show(navCtx, status);
    } catch (e, st) {
      // Never block the user, but surface in debug so we don't silently
      // ship a regression like "dialog never shows".
      if (kDebugMode) {
        debugPrint('[UpdateObserver] check/show failed: $e\n$st');
      }
    }
  }

  /// Resolves as soon as [splashGateProvider] flips to `true`, or after
  /// a 3500 ms hard-ceiling so a stuck gate never permanently suppresses
  /// the update prompt.
  Future<void> _waitForSplashGate() async {
    if (ref.read(splashGateProvider)) return;
    final completer = Completer<void>();
    final sub = ref.listenManual<bool>(splashGateProvider, (_, next) {
      if (next && !completer.isCompleted) completer.complete();
    });
    Timer(const Duration(milliseconds: 3500), () {
      if (!completer.isCompleted) completer.complete();
    });
    try {
      await completer.future;
    } finally {
      sub.close();
    }
  }
}
