import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/update/update_dialog.dart';
import '../auth/auth_state.dart';
import 'update_service.dart';

/// Listens for the first successful auth state and triggers an update check.
/// If a newer release is available we surface [UpdateDialog].
///
/// Intentionally idempotent per app-launch — we don't re-prompt after dismissal
/// unless the user relaunches.
class UpdateObserver extends ConsumerStatefulWidget {
  const UpdateObserver({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<UpdateObserver> createState() => _UpdateObserverState();
}

class _UpdateObserverState extends ConsumerState<UpdateObserver> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    // Sideload update path is Android-only.
    if (Platform.isAndroid) {
      ref.listen(authControllerProvider, (prev, next) {
        if (next is AuthAuthenticated && !_checked) {
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
