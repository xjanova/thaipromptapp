import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';

/// Mode Select — post-login role picker.
///
/// See `design_handoff_thaiprompt_marketplace/screens-a.jsx` → `Onboarding`
/// and README §"Mode Select". Three stacked mode cards (Buyer / Seller /
/// Rider), each with its own gradient background, 3D blob decoration,
/// title/description, tags, and a CTA arrow button.
///
/// Persists the chosen mode to `SharedPreferences` as `last_mode`, so next
/// launch can auto-route to the last active mode (see §Navigation).
class ModeSelectPage extends StatefulWidget {
  const ModeSelectPage({super.key});

  @override
  State<ModeSelectPage> createState() => _ModeSelectPageState();
}

class _ModeSelectPageState extends State<ModeSelectPage> {
  static const _modes = <_ModeInfo>[
    _ModeInfo(
      id: 'buyer',
      route: '/buyer',
      th: 'โหมดผู้ใช้',
      en: 'Buyer Mode',
      desc: 'ซื้อของ สั่งอาหาร จากร้านใกล้บ้าน',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [TpColors.pink, TpColors.tomato],
      ),
      fg: Colors.white,
      accent: TpColors.mango,
      tags: ['ตลาดนัด', 'ส่งด่วน', 'Wallet'],
    ),
    _ModeInfo(
      id: 'seller',
      route: '/seller',
      th: 'โหมดร้านค้า',
      en: 'Seller Mode',
      desc: 'เปิดร้าน จัดการสินค้า รับออเดอร์ realtime',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [TpColors.mango, TpColors.tomato],
      ),
      fg: TpColors.ink,
      accent: TpColors.ink,
      tags: ['เพิ่มสินค้า', 'สถิติยอดขาย', 'พนักงาน'],
    ),
    _ModeInfo(
      id: 'rider',
      route: '/rider',
      th: 'โหมดไรเดอร์',
      en: 'Rider Mode',
      desc: 'รับงานส่งของใกล้ตัว หารายได้ตามเวลา',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [TpColors.ink, TpColors.purple],
      ),
      fg: Colors.white,
      accent: TpColors.mint,
      tags: ['Map routing', 'รายได้รายวัน', 'Online/Offline'],
    ),
  ];

  String? _activeMode;
  bool _adDismissed = false;

  @override
  void initState() {
    super.initState();
    _loadActiveMode();
  }

  Future<void> _loadActiveMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _activeMode = prefs.getString('last_mode'));
  }

  Future<void> _pickMode(_ModeInfo mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_mode', mode.id);
    if (!mounted) return;
    context.go(mode.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8EE),
              Color(0xFFFFE8F0),
              Color(0xFFDFFAF3),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _TopBar()),
              if (!_adDismissed)
                SliverToBoxAdapter(
                  child: _AdBanner(onClose: () => setState(() => _adDismissed = true)),
                ),
              const SliverToBoxAdapter(child: _Title()),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final mode = _modes[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ModeCard(
                          mode: mode,
                          active: mode.id == _activeMode,
                          onTap: () => _pickMode(mode),
                        ),
                      );
                    },
                    childCount: _modes.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _MlmQuickLink(onTap: () => context.go('/mlm')),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Thai',
                        fontSize: 11,
                        color: TpColors.muted,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('ออกจากระบบ · '),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text(
                              'Switch account',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: TpColors.deepInk,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeInfo {
  const _ModeInfo({
    required this.id,
    required this.route,
    required this.th,
    required this.en,
    required this.desc,
    required this.gradient,
    required this.fg,
    required this.accent,
    required this.tags,
  });

  final String id;
  final String route;
  final String th;
  final String en;
  final String desc;
  final LinearGradient gradient;
  final Color fg;
  final Color accent;
  final List<String> tags;
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TpColors.deepInk,
              borderRadius: BorderRadius.circular(12),
              boxShadow: TpShadows.claySm,
            ),
            alignment: Alignment.center,
            child: const Text(
              'T',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: TpColors.mango,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thaiprompt',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: -0.3,
                    color: TpColors.ink,
                  ),
                ),
                Text(
                  'สวัสดี 👋',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 9,
                    letterSpacing: 1.2,
                    color: TpColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: TpShadows.claySm,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.notifications_outlined, size: 18, color: TpColors.ink),
          ),
        ],
      ),
    );
  }
}

class _AdBanner extends StatelessWidget {
  const _AdBanner({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: ClayCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        radius: 18,
        shadow: ClayShadow.small,
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -0.5),
          end: Alignment(0.8, 0.5),
          colors: [TpColors.purple, TpColors.pink, TpColors.mango],
          stops: [0.0, 0.6, 1.0],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'AD',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 8,
                          letterSpacing: 1.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'REMOTE FEED · thaiprompt.online',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 9,
                        letterSpacing: 1.8,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'ยินดีต้อนรับสู่ Thaiprompt',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'เลือกโหมดที่ต้องการใช้งาน',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_DotIndicator(active: true), SizedBox(width: 4), _DotIndicator(), SizedBox(width: 4), _DotIndicator()],
                ),
              ],
            ),
            Positioned(
              top: -4,
              right: -4,
              child: InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({this.active = false});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 16 : 6,
      height: 4,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHOOSE YOUR MODE',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              letterSpacing: 1.5,
              color: TpColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'เข้าใช้งานเป็นใคร?',
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.4,
              color: TpColors.ink,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.active, required this.onTap});
  final _ModeInfo mode;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badgeTextColor = mode.fg == Colors.white ? TpColors.ink : Colors.white;

    return ClayCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      gradient: mode.gradient,
      clipChildren: true,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mode.en.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color: mode.fg.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        mode.th,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Thai',
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: mode.fg,
                        ),
                      ),
                    ),
                    if (active) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: mode.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'กำลังใช้',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Thai',
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  mode.desc,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 11,
                    color: mode.fg.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final tag in mode.tags)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: mode.fg,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: mode.accent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: TpShadows.claySm,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: mode.fg == Colors.white ? TpColors.ink : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MlmQuickLink extends StatelessWidget {
  const _MlmQuickLink({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      shadow: ClayShadow.small,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: TpColors.pinkTint,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.account_tree_rounded, size: 16, color: TpColors.pink),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'MLM Network',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                  TextSpan(
                    text: ' · ดูดาวน์ไลน์ + รายได้',
                    style: TextStyle(fontSize: 11, color: TpColors.ink2),
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: TpColors.muted),
        ],
      ),
    );
  }
}
