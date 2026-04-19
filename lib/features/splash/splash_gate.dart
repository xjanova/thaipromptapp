import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cold-start splash gate.
///
/// `false` until the animated splash on `/splash` finishes its intro
/// (logo zoom + glow + 16-bit chiptune). The router checks this flag
/// alongside auth state — it will NOT redirect away from `/splash`
/// while the gate is still closed, so the animation always plays in
/// full instead of being yanked the instant auth resolves.
///
/// Flipped to `true` exactly once per process by [SplashPage] and
/// stays true for the rest of the session (so navigating back to
/// `/splash` later — e.g. after logout — does not re-block routing).
final splashGateProvider = StateProvider<bool>((_) => false);
