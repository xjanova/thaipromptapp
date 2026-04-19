import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'splash_gate.dart';

/// Animated cold-start splash.
///
/// Plays once per process: deep-navy gradient (matching the launcher icon)
/// with a halo of expanding rings, the logo zooming in with a soft bounce,
/// the brand title fading + sliding up, and a sparkle sweep — synced with
/// a 1.4s 16-bit chiptune (`assets/sfx/startup_16bit.wav`).
///
/// When the intro finishes it flips [splashGateProvider] to `true`, which
/// unblocks the router's redirect rule (see `lib/app/router.dart`) so the
/// user lands on `/onboarding` or `/home` based on auth state.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _ring;
  AudioPlayer? _player;
  Timer? _gateTimer;

  // Choreography (all relative to _intro 0..1, total ~2200ms):
  //   0.00–0.55  logo scale-in + soft bounce, gold glow grows
  //   0.20–0.75  title "ThaiPromptAPP" fade + slide up
  //   0.45–0.85  tagline fade in
  //   0.75–1.00  hold + gentle exhale before route handoff
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _glow;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _exhale;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.55, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 20,
      ),
    ]).animate(_intro);

    _logoOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.00, 0.35, curve: Curves.easeOut),
    );

    _glow = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.10, 0.85, curve: Curves.easeInOutCubic),
    );

    _titleOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.30, 0.70, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.30, 0.75, curve: Curves.easeOutCubic),
    ));

    _taglineOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.55, 0.95, curve: Curves.easeOut),
    );

    _exhale = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.75, 1.0, curve: Curves.easeInOutSine),
    );

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    // Light haptic to pair with the chiptune kick.
    HapticFeedback.lightImpact();

    _playStartupChiptune();
    _intro.forward();

    // Open the router gate slightly after the visual settles, so the
    // destination route can render its first frame under the fade-out.
    _gateTimer = Timer(const Duration(milliseconds: 2300), _openGate);
  }

  Future<void> _playStartupChiptune() async {
    try {
      final p = AudioPlayer();
      _player = p;
      await p.setAsset('assets/sfx/startup_16bit.wav');
      await p.setVolume(0.55);
      // Fire and forget; we don't await `play()` so a slow audio session
      // never delays the visual.
      unawaited(p.play());
    } catch (_) {
      // Silent: audio is decorative — never block boot if the device has
      // no audio session, the asset is missing, or another app holds focus.
    }
  }

  void _openGate() {
    if (!mounted) return;
    final notifier = ref.read(splashGateProvider.notifier);
    if (!notifier.state) notifier.state = true;
  }

  @override
  void dispose() {
    _gateTimer?.cancel();
    _intro.dispose();
    _ring.dispose();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SplashPalette.bgDeep,
      body: AnimatedBuilder(
        animation: Listenable.merge([_intro, _ring]),
        builder: (context, _) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: [
                  _SplashPalette.bgGlow,
                  _SplashPalette.bgMid,
                  _SplashPalette.bgDeep,
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Subtle vertical sheen sweep
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SheenPainter(progress: _intro.value),
                  ),
                ),
                // Expanding gold halo rings
                Center(
                  child: SizedBox.square(
                    dimension: 360,
                    child: CustomPaint(
                      painter: _RingPainter(
                        ringPhase: _ring.value,
                        intensity: _glow.value,
                      ),
                    ),
                  ),
                ),
                // Logo + brand stack
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value *
                              (1 - 0.04 * _exhale.value),
                          child: _LogoBadge(glow: _glow.value),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Opacity(
                        opacity: _titleOpacity.value,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: const _BrandTitle(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: _taglineOpacity.value,
                        child: const Text(
                          'ตลาดชุมชนไทย · Community Marketplace',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFE9D9A6),
                            fontSize: 13,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom dot indicator
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 56,
                  child: Center(
                    child: Opacity(
                      opacity: _taglineOpacity.value,
                      child: const _LoadingDots(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SplashPalette {
  const _SplashPalette._();
  static const bgDeep = Color(0xFF071A36);
  static const bgMid = Color(0xFF0E2A4F);
  static const bgGlow = Color(0xFF1B447C);
  static const gold = Color(0xFFFFD27A);
  static const goldDeep = Color(0xFFCB8A2A);
}

/// Faint diagonal sheen that sweeps across the screen during intro.
class _SheenPainter extends CustomPainter {
  _SheenPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = (progress * 1.4 - 0.2).clamp(0.0, 1.0);
    final dx = -size.width + (size.width * 2.0) * t;
    final rect = Rect.fromLTWH(dx, 0, size.width * 0.6, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.06 * (1 - (t - 0.5).abs() * 2)),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_SheenPainter old) => old.progress != progress;
}

/// Three concentric gold halo rings expanding outward on a loop.
class _RingPainter extends CustomPainter {
  _RingPainter({required this.ringPhase, required this.intensity});
  final double ringPhase;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide * 0.5;
    for (var i = 0; i < 3; i++) {
      final phase = (ringPhase + i / 3) % 1.0;
      final r = maxR * (0.35 + 0.65 * phase);
      final alpha = ((1 - phase) * 0.55 * intensity).clamp(0.0, 0.55);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _SplashPalette.gold.withValues(alpha: alpha);
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.ringPhase != ringPhase || old.intensity != intensity;
}

/// Logo image with a soft golden glow that pulses with `glow`.
class _LogoBadge extends StatelessWidget {
  const _LogoBadge({required this.glow});
  final double glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              boxShadow: [
                BoxShadow(
                  color: _SplashPalette.gold
                      .withValues(alpha: 0.28 + 0.22 * glow),
                  blurRadius: 60,
                  spreadRadius: 8 + 12 * glow,
                ),
                BoxShadow(
                  color: _SplashPalette.goldDeep.withValues(alpha: 0.35 * glow),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: Image.asset(
              'assets/images/logoapp.png',
              width: 168,
              height: 168,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          ),
          // Top-left specular highlight
          Positioned(
            top: 10,
            left: 14,
            child: Opacity(
              opacity: 0.45 * glow,
              child: Container(
                width: 50,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _SplashPalette.gold,
          Color(0xFFFFF1C0),
          _SplashPalette.gold,
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect),
      child: const Text(
        'ThaiPromptAPP',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          shadows: [
            Shadow(
              color: Color(0x66000000),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

/// Three pulsing dots, NES-status-bar style.
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = ((_c.value + i / 3) % 1.0);
            final scale = 0.7 + 0.6 * (0.5 + 0.5 * math.sin(phase * math.pi * 2));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _SplashPalette.gold.withValues(
                      alpha: 0.5 + 0.5 * (scale - 0.7) / 0.6,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
