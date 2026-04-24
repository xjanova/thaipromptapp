import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/section_header.dart';

/// MLM feature pages. Dark page bg, mango accent — canonical reference:
/// `design_handoff_thaiprompt_marketplace/mlm-app.jsx`.

// ═══════════════════════════════════════════════════════════════════════
// M1 · Dashboard
// ═══════════════════════════════════════════════════════════════════════

class MlmDashboardPage extends StatelessWidget {
  const MlmDashboardPage({super.key});

  static const _activities = <_TeamActivity>[
    _TeamActivity('นิดา ขนมไทย', 'ขายได้ ฿1,280 · คุณได้ ฿64', '5 นาที', TpColors.pink),
    _TeamActivity('สมชาย ช่างไม้', 'ชวน 2 คนใหม่เข้าทีม', '1 ชม.', TpColors.mango),
    _TeamActivity('พี่แตง ครัวบ้านไทย', 'เลื่อนขั้นเป็น BRONZE', 'เช้า', TpColors.mint),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THAIPROMPT NETWORK',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  letterSpacing: 2.0,
                  color: Color(0x99FFFFFF),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'สวัสดี, '),
                    TextSpan(
                      text: 'พี่น้อย',
                      style: TextStyle(color: TpColors.mango),
                    ),
                    TextSpan(text: ' ✨'),
                  ],
                ),
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Thai',
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _RankCard(onTap: () {}),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'รายได้เดือนนี้',
                  value: '฿12,450',
                  sub: '↑ 18% vs เดือนก่อน',
                  color: TpColors.mango,
                  onTap: () => context.go('/mlm/earnings'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  label: 'ทีมรวม',
                  value: '48 คน',
                  sub: '3 ชั้น · Active 32',
                  color: const Color(0xFFC9B8FF),
                  onTap: () => context.go('/mlm/tree'),
                ),
              ),
            ],
          ),
        ),
        const SectionHeader(
          titleTh: 'ด่วน · ต้องทำ',
          titleEn: 'Quick actions',
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _QuickTile(
                  icon: '↗',
                  label: 'ชวน',
                  color: TpColors.mango,
                  onTap: () => context.go('/mlm/invite'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickTile(
                  icon: '◈',
                  label: 'ทีม',
                  color: TpColors.purple,
                  onTap: () => context.go('/mlm/tree'),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _QuickTile(
                  icon: '🏆',
                  label: 'ลีดเดอร์',
                  color: TpColors.pink,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _QuickTile(
                  icon: '🎓',
                  label: 'อบรม',
                  color: TpColors.mint,
                ),
              ),
            ],
          ),
        ),
        const SectionHeader(
          titleTh: 'กิจกรรมทีม',
          titleEn: 'Team activity',
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final a in _activities) ...[
                _ActivityRow(activity: a),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [TpColors.mango, TpColors.pink, TpColors.purple],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: TpColors.ink,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: TpShadows.claySm,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '◈',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
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
                          'RANK · SILVER',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: Color(0xD9FFFFFF),
                          ),
                        ),
                        Text(
                          'เงินสดใส 💎',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Thai',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'อีก 3 คน เพื่อขึ้น GOLD',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Thai',
                            fontSize: 11,
                            color: Color(0xE6FFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.7,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '7 / 10 สมาชิก',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Thai',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'ดูรายละเอียด →',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Thai',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.onTap,
  });
  final String label;
  final String value;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 9,
                  letterSpacing: 1.5,
                  color: Color(0xB3FFFFFF),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Thai',
                  fontSize: 10,
                  color: Color(0xCCFFFFFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: TpShadows.claySm,
                ),
                alignment: Alignment.center,
                child: Text(
                  icon,
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: TpColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Thai',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamActivity {
  const _TeamActivity(this.name, this.action, this.when, this.color);
  final String name;
  final String action;
  final String when;
  final Color color;
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});
  final _TeamActivity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: activity.color,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              activity.name[0],
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Thai',
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: TpColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  activity.action,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 10,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity.when,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 9,
              color: Color(0x99FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// M2 · Tree
// ═══════════════════════════════════════════════════════════════════════

class MlmTreePage extends StatelessWidget {
  const MlmTreePage({super.key});

  static const _l1 = <_TreeMember>[
    _TreeMember('นิดา ขนมไทย', 'BRONZE', 12, '฿3,200'),
    _TreeMember('สมชาย ช่างไม้', 'BRONZE', 8, '฿2,100'),
    _TreeMember('พี่แตง ครัวบ้าน', 'BRONZE', 15, '฿4,800'),
  ];
  static const _l2Under1 = ['ป้าจี๊ด', 'น้องฟ้า', 'ลุงโต'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const _MlmHeader(title: 'โครงสร้างทีม', sub: 'TEAM TREE'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: i == 0 ? TpColors.mango : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    ['ทั้งหมด (48)', 'Active (32)', 'Pending (16)'][i],
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Thai',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: i == 0 ? TpColors.ink : Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [TpColors.mango, TpColors.pink],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: TpShadows.clay,
            ),
            child: const Column(
              children: [
                Text(
                  'YOU · SILVER',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color: TpColors.ink,
                  ),
                ),
                Text(
                  'พี่น้อย',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: TpColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (var i = 0; i < _l1.length; i++) ...[
                _L1Row(member: _l1[i]),
                if (i == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 24),
                    child: Column(
                      children: [
                        for (var j = 0; j < _l2Under1.length; j++) ...[
                          if (j > 0) const SizedBox(height: 6),
                          _L2Row(name: _l2Under1[j]),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TreeMember {
  const _TreeMember(this.name, this.rank, this.downlines, this.sales);
  final String name;
  final String rank;
  final int downlines;
  final String sales;
}

class _L1Row extends StatelessWidget {
  const _L1Row({required this.member});
  final _TreeMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TpColors.mango.withValues(alpha: 0.1),
        border: Border.all(color: TpColors.mango.withValues(alpha: 0.2), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TpColors.mango,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              member.name[0],
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Thai',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: TpColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${member.rank} · ${member.downlines} คน · ${member.sales}',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: Color(0xB3FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '▾',
            style: TextStyle(fontSize: 18, color: Color(0x80FFFFFF)),
          ),
        ],
      ),
    );
  }
}

class _L2Row extends StatelessWidget {
  const _L2Row({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: Color(0x26FFFFFF), width: 2)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: TpColors.pink,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(
              name[0],
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Thai',
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Thai',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const Text(
            'L3',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 9,
              color: Color(0x99FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _MlmHeader extends StatelessWidget {
  const _MlmHeader({required this.title, required this.sub});
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sub,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 9,
              letterSpacing: 1.8,
              color: Color(0x99FFFFFF),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Thai',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// M3 · Earnings
// ═══════════════════════════════════════════════════════════════════════

class MlmEarningsPage extends StatelessWidget {
  const MlmEarningsPage({super.key});

  static const _levels = <_LevelEarning>[
    _LevelEarning('Direct (L1)', '฿5,200', '7 คน', TpColors.mango),
    _LevelEarning('Level 2', '฿3,800', '18 คน', TpColors.pink),
    _LevelEarning('Level 3', '฿2,150', '23 คน', TpColors.mint),
    _LevelEarning('Bonus', '฿1,300', 'Rank up', TpColors.purple),
  ];

  static const _log = <_CommissionLog>[
    _CommissionLog('นิดา · ข้าวซอย', 64, 'L1 · 5%'),
    _CommissionLog('ป้าจี๊ด · ขนมเปี๊ยะ', 28, 'L2 · 2%'),
    _CommissionLog('สมชาย · ไม้แกะสลัก', 150, 'L1 · 5%'),
    _CommissionLog('น้องฟ้า · น้ำพริก', 12, 'L3 · 1%'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const _MlmHeader(title: 'รายได้ของฉัน', sub: 'EARNINGS'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [TpColors.purple, TpColors.pink],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'รายได้สะสมรวม',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
                const Text(
                  '฿148,200',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: TpColors.mango,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'ถอนเงิน',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Thai',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: TpColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'ประวัติ',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Thai',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.1,
            children: [
              for (final l in _levels)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l.level.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: Color(0x99FFFFFF),
                        ),
                      ),
                      Text(
                        l.value,
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: l.color,
                        ),
                      ),
                      Text(
                        l.people,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Thai',
                          fontSize: 10,
                          color: Color(0xB3FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SectionHeader(
          titleTh: 'รายการรายได้',
          titleEn: 'Commission log',
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final e in _log) ...[
                _CommissionRow(log: e),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelEarning {
  const _LevelEarning(this.level, this.value, this.people, this.color);
  final String level;
  final String value;
  final String people;
  final Color color;
}

class _CommissionLog {
  const _CommissionLog(this.source, this.amount, this.level);
  final String source;
  final int amount;
  final String level;
}

class _CommissionRow extends StatelessWidget {
  const _CommissionRow({required this.log});
  final _CommissionLog log;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: TpColors.mango,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text(
              '฿',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: TpColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.source,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  log.level,
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: Color(0x99FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+฿${log.amount}',
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: TpColors.mint,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// M4 · Invite
// ═══════════════════════════════════════════════════════════════════════

class MlmInvitePage extends StatelessWidget {
  const MlmInvitePage({super.key});

  static const _shares = <_ShareOption>[
    _ShareOption('LINE', 'L', Color(0xFF06C755)),
    _ShareOption('เฟซ', '◉', Color(0xFF1877F2)),
    _ShareOption('IG', '▶', Color(0xFFE4405F)),
    _ShareOption('คัดลอก', '⎘', TpColors.purple),
  ];

  static const _rewards = <_InviteReward>[
    _InviteReward('ชวน 1 คน', 'รับโบนัส ฿50 ทันที', TpColors.mango),
    _InviteReward('ชวน 5 คน', 'ปลดล็อกอัตรา 6%', TpColors.pink),
    _InviteReward('ชวน 10 คน', 'เลื่อนขั้นเป็น GOLD', TpColors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const _MlmHeader(title: 'ชวนเพื่อนเข้าทีม', sub: 'INVITE'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [TpColors.mango, TpColors.tomato],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'YOUR INVITE CODE',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: TpColors.ink,
                  ),
                ),
                const Text(
                  'NOI-288',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.2,
                    color: TpColors.ink,
                  ),
                ),
                Container(
                  width: 140,
                  height: 140,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TpColors.ink,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: CustomPaint(painter: _InviteQrPainter()),
                ),
                const Text(
                  'สแกน หรือบอกรหัส',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: TpColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SectionHeader(
          titleTh: 'แชร์ผ่าน',
          titleEn: 'Share via',
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (var i = 0; i < _shares.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _ShareTile(share: _shares[i])),
              ],
            ],
          ),
        ),
        const SectionHeader(
          titleTh: 'สิทธิประโยชน์',
          titleEn: 'Rewards',
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final r in _rewards) ...[
                _RewardRow(reward: r),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ShareOption {
  const _ShareOption(this.label, this.icon, this.color);
  final String label;
  final String icon;
  final Color color;
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({required this.share});
  final _ShareOption share;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: share.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: TpShadows.claySm,
            ),
            alignment: Alignment.center,
            child: Text(
              share.icon,
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            share.label,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Thai',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteReward {
  const _InviteReward(this.title, this.desc, this.color);
  final String title;
  final String desc;
  final Color color;
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.reward});
  final _InviteReward reward;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: reward.color,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text('🎁', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  reward.desc,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Thai',
                    fontSize: 11,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteQrPainter extends CustomPainter {
  static const _onIndices = [0, 2, 3, 7, 8, 10, 15, 17, 20, 22, 26, 29, 31, 35, 38, 40, 43, 48, 50, 53, 56, 59, 62];

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 8;
    final cell = size.width / cols;
    final paint = Paint()..color = TpColors.mango;
    for (var i = 0; i < cols * cols; i++) {
      if (!_onIndices.contains(i)) continue;
      final x = i % cols;
      final y = i ~/ cols;
      canvas.drawRect(
        Rect.fromLTWH(x * cell, y * cell, cell, cell),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _InviteQrPainter old) => false;
}
