import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/blob_3d.dart';
import '../../shared/widgets/chip_tag.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/coin.dart';
import '../../shared/widgets/puffy_button.dart';

/// Port of `Onboarding` in screens-a.jsx.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: Stack(
        children: [
          const _BackgroundGradient(),
          const _DotsOverlay(),
          ..._floatingBlobs(),
          const _LogoMark(),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                _BottomCard(
                  // "เริ่มใช้เลย" = enter the app as a guest (browse-first).
                  // Login/register is optional — guest can check out fresh
                  // listings, shops, AI น้องหญิง, and settings without a
                  // token. Auth-gated actions (cart checkout, wallet,
                  // affiliate, my orders) will bounce to /login when
                  // tapped, with a "ข้ามไปก่อน" escape hatch back to home.
                  onStart: () => context.go('/home'),
                  onLogin: () => context.go('/login'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _floatingBlobs() => [
        Positioned(
          top: 30,
          right: -20,
          child: const Blob3D(size: 110, hue: BlobHue.pink).animate(
            onPlay: (c) => c.repeat(reverse: true),
          ).moveY(
              begin: 0, end: -12, duration: 3500.ms, curve: Curves.easeInOut),
        ),
        Positioned(
          top: 120,
          left: -30,
          child: const Blob3D(size: 80, hue: BlobHue.mango).animate(
            onPlay: (c) => c.repeat(reverse: true),
            delay: 500.ms,
          ).moveY(begin: 0, end: -10, duration: 3200.ms, curve: Curves.easeInOut),
        ),
        Positioned(
          top: 200,
          right: 30,
          child: const Blob3D(size: 60, hue: BlobHue.mint).animate(
            onPlay: (c) => c.repeat(reverse: true),
            delay: 300.ms,
          ).moveY(begin: 0, end: -8, duration: 3800.ms, curve: Curves.easeInOut),
        ),
        Positioned(
          top: 260,
          left: 40,
          child: const Coin(size: 56).animate(
            onPlay: (c) => c.repeat(reverse: true),
            delay: 700.ms,
          ).moveY(begin: 0, end: -10, duration: 3000.ms, curve: Curves.easeInOut),
        ),
        Positioned(
          top: 320,
          right: 80,
          child: const Blob3D(size: 44, hue: BlobHue.purple).animate(
            onPlay: (c) => c.repeat(reverse: true),
            delay: 900.ms,
          ).moveY(begin: 0, end: -7, duration: 3100.ms, curve: Curves.easeInOut),
        ),
      ];
}

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(gradient: TpGradients.onboardingBg),
        child: SizedBox.expand(),
      );
}

class _DotsOverlay extends StatelessWidget {
  const _DotsOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.3,
        child: CustomPaint(painter: _DotsPainter()),
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

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: TpColors.deepInk,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'T',
                style: GoogleFonts.spaceGrotesk(
                  color: TpColors.mango,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thaiprompt',
                  style: TpText.display4.copyWith(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                Text('ไทยพร๊อม', style: TpText.monoLabelSm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomCard extends StatelessWidget {
  const _BottomCard({required this.onStart, required this.onLogin});
  final VoidCallback onStart;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: ClayCard(
        color: TpColors.paper,
        padding: const EdgeInsets.all(22),
        shadow: ClayShadow.large,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const TpChip(
              label: 'ตลาดของชุมชน · v1.0',
              color: TpColors.mango,
              icon: _ChipDot(),
            ),
            const SizedBox(height: 14),
            RichText(
              text: TextSpan(
                style: TpText.display2,
                children: [
                  const TextSpan(text: 'ตลาดนัด\n'),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: _HighlightedPill(text: 'อยู่ในมือ'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ซื้อของจากร้านเพื่อนบ้าน · เติมเงิน PromptPay · แชร์ลิงก์หารายได้จากการแนะนำ',
              style: TpText.bodySm,
            ),
            const SizedBox(height: 18),
            const _FeaturesRow(),
            const SizedBox(height: 16),
            PuffyButton(
              label: 'เริ่มใช้เลย · Get started',
              variant: PuffyVariant.pink,
              size: PuffySize.large,
              fullWidth: true,
              onPressed: onStart,
            ),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: onLogin,
                child: Text.rich(TextSpan(
                  style: TpText.bodySm.copyWith(color: TpColors.muted),
                  children: [
                    const TextSpan(text: 'มีบัญชีแล้ว? '),
                    TextSpan(
                      text: 'เข้าสู่ระบบ',
                      style: TpText.bodySm.copyWith(
                        color: TpColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipDot extends StatelessWidget {
  const _ChipDot();
  @override
  Widget build(BuildContext context) => Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: TpColors.deepInk,
          shape: BoxShape.circle,
        ),
      );
}

class _HighlightedPill extends StatelessWidget {
  const _HighlightedPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.035,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: TpColors.pink,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              offset: const Offset(0, 4),
              blurRadius: 8,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Text(
          text,
          style: TpText.display2.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _FeaturesRow extends StatelessWidget {
  const _FeaturesRow();

  @override
  Widget build(BuildContext context) {
    const items = [
      _FeatureItem(label: 'Wallet', glyph: '◈', color: TpColors.mint),
      _FeatureItem(label: 'Affiliate', glyph: '◇', color: TpColors.mango),
      _FeatureItem(label: 'ส่งใกล้บ้าน', glyph: '◉', color: TpColors.pink),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(child: items[i]),
          if (i < items.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.label, required this.glyph, required this.color});
  final String label;
  final String glyph;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
      decoration: BoxDecoration(
        color: TpColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              glyph,
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: TpColors.deepInk,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TpText.bodyXs.copyWith(fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
