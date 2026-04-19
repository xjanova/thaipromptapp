import 'package:flutter/material.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';

/// Bottom navigation dock with a curved notch for the floating Home FAB.
/// Port of `TabBar` + `DockBtn` from `thaiprompt/project/phone.jsx`.
enum NavTab { menu, wallet, home, affiliate, me }

class NavDock extends StatelessWidget {
  const NavDock({
    super.key,
    required this.active,
    required this.onChange,
  });

  final NavTab active;
  final ValueChanged<NavTab> onChange;

  static const _sides = <_SideItem>[
    _SideItem(NavTab.menu, 'เมนู', Icons.menu_rounded),
    _SideItem(NavTab.wallet, 'Wallet', Icons.account_balance_wallet_outlined),
    _SideItem(NavTab.affiliate, 'แนะนำ', Icons.share_outlined),
    _SideItem(NavTab.me, 'ฉัน', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: SizedBox(
          height: 90,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Dock body with notch
              Positioned.fill(
                child: CustomPaint(
                  painter: _DockPainter(),
                ),
              ),
              // Side buttons
              Positioned(
                left: 8,
                right: 8,
                top: 12,
                bottom: 0,
                child: Row(
                  children: [
                    _DockBtn(item: _sides[0], active: active, onChange: onChange),
                    _DockBtn(item: _sides[1], active: active, onChange: onChange),
                    const SizedBox(width: 88), // notch gap
                    _DockBtn(item: _sides[2], active: active, onChange: onChange),
                    _DockBtn(item: _sides[3], active: active, onChange: onChange),
                  ],
                ),
              ),
              // Center home FAB
              Positioned(
                top: -18,
                left: 0,
                right: 0,
                child: Center(
                  child: _HomeFab(
                    active: active == NavTab.home,
                    onTap: () => onChange(NavTab.home),
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

class _SideItem {
  const _SideItem(this.id, this.label, this.icon);
  final NavTab id;
  final String label;
  final IconData icon;
}

class _DockBtn extends StatelessWidget {
  const _DockBtn({
    required this.item,
    required this.active,
    required this.onChange,
  });

  final _SideItem item;
  final NavTab active;
  final ValueChanged<NavTab> onChange;

  @override
  Widget build(BuildContext context) {
    final isActive = active == item.id;
    return Expanded(
      child: InkWell(
        onTap: () => onChange(item.id),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        begin: Alignment(-0.7, -1),
                        end: Alignment(0.7, 1),
                        colors: [Color(0xFFFF5983), Color(0xFFC7502D)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFFC7502D).withValues(alpha: 0.5),
                          offset: const Offset(0, 8),
                          blurRadius: 14,
                          spreadRadius: -4,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                item.icon,
                size: 22,
                color: isActive ? Colors.white : TpColors.ink,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TpText.bodyXs.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isActive ? const Color(0xFFC7502D) : TpColors.ink2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeFab extends StatelessWidget {
  const _HomeFab({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.36, -0.44),
            radius: 0.85,
            colors: active
                ? const [Color(0xFFFFC99C), Color(0xFFFF7A3A), Color(0xFFC7502D)]
                : const [Color(0xFFFFF1D9), Color(0xFFFFC94D), Color(0xFFC9851B)],
            stops: const [0, 0.55, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: (active ? const Color(0xFFC7502D) : const Color(0xFFC9851B))
                  .withValues(alpha: 0.55),
              offset: const Offset(0, 14),
              blurRadius: 24,
              spreadRadius: -6,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.home_rounded,
              size: 28,
              color: active ? Colors.white : TpColors.ink,
            ),
            Positioned(
              bottom: -28,
              child: Text(
                'หน้าแรก',
                style: TpText.bodyXs.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: TpColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Cream gradient
    final rect = Rect.fromLTWH(0, 12, size.width, size.height - 12);
    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFDF7), Color(0xFFF3E7CF)],
    ).createShader(rect);

    final paint = Paint()
      ..shader = gradient
      ..isAntiAlias = true;

    // Soft drop shadow
    canvas.drawShadow(
      _dockPath(size),
      Colors.black.withValues(alpha: 0.2),
      14,
      false,
    );

    canvas.drawPath(_dockPath(size), paint);
  }

  Path _dockPath(Size s) {
    final w = s.width;
    final notchCenter = w / 2;
    const notchW = 88.0;
    const notchD = 26.0;
    const topY = 12.0;
    final bottomY = s.height;

    final leftNotch = notchCenter - notchW / 2;
    final rightNotch = notchCenter + notchW / 2;

    final path = Path()
      ..moveTo(28, topY)
      ..quadraticBezierTo(14, topY, 14, topY + 18)
      ..lineTo(14, bottomY - 14)
      ..quadraticBezierTo(14, bottomY, 28, bottomY)
      ..lineTo(w - 28, bottomY)
      ..quadraticBezierTo(w - 14, bottomY, w - 14, bottomY - 14)
      ..lineTo(w - 14, topY + 18)
      ..quadraticBezierTo(w - 14, topY, w - 28, topY)
      ..lineTo(rightNotch + 4, topY)
      ..quadraticBezierTo(rightNotch - 6, topY, rightNotch - 16, topY + 8)
      ..quadraticBezierTo(
        notchCenter + 18,
        topY + notchD,
        notchCenter,
        topY + notchD,
      )
      ..quadraticBezierTo(
        notchCenter - 18,
        topY + notchD,
        leftNotch + 16,
        topY + 8,
      )
      ..quadraticBezierTo(leftNotch + 6, topY, leftNotch - 4, topY)
      ..close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _DockPainter oldDelegate) => false;
}
