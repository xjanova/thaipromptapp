import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/section_header.dart';

/// Search page — hot searches + recent queries.
///
/// Reference: `design_handoff_thaiprompt_marketplace/buyer-app.jsx`
/// → `BuyerSearch`.
///
/// TODO(v1.0.23+): wire to a `search_controller.dart` that calls the
/// backend (`GET /v1/search/suggest` + `GET /v1/search/recent`) and
/// persists recent queries locally. For now the data is a static stub
/// matching the design mockup so the screen is demo-able.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;

  // Static stub data — replace with backend when the /search endpoints land.
  static const _hotSearches = [
    'ข้าวซอย',
    'ส้มตำ',
    'ขนมเปี๊ยะ',
    'หมูทอด',
    'น้ำพริก',
    'ปลาร้า',
  ];

  static const _recentSearches = [
    'ร้านครัวยายปราณี',
    'ลุงโต ก๋วยเตี๋ยว',
    'ขนมไทยนิดา',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String query) {
    if (query.trim().isEmpty) return;
    // TODO: push results page. For now, just pop back to home.
    context.go('/buyer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _SearchBar(
                controller: _controller,
                onSubmitted: _submit,
                onBack: () => context.go('/buyer'),
              ),
            ),
            const SliverToBoxAdapter(
              child: SectionHeader(titleTh: 'ยอดนิยม', titleEn: 'Hot searches'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < _hotSearches.length; i++)
                      _HotChip(
                        label: _hotSearches[i],
                        trending: i < 2,
                        onTap: () {
                          _controller.text = _hotSearches[i];
                          _submit(_hotSearches[i]);
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SectionHeader(titleTh: 'ค้นล่าสุด', titleEn: 'Recent'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              sliver: SliverList.separated(
                itemBuilder: (context, i) => _RecentRow(
                  label: _recentSearches[i],
                  onTap: () {
                    _controller.text = _recentSearches[i];
                    _submit(_recentSearches[i]);
                  },
                ),
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemCount: _recentSearches.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onSubmitted,
    required this.onBack,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TpColors.mango,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onBack,
              child: const SizedBox(
                width: 34,
                height: 34,
                child: Icon(Icons.arrow_back_rounded,
                    size: 18, color: TpColors.ink),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClayCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              radius: 14,
              shadow: ClayShadow.small,
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      size: 18, color: TpColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.search,
                      autofocus: true,
                      onSubmitted: onSubmitted,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Thai',
                        fontSize: 13,
                        color: TpColors.ink,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'ค้นหาร้าน · สินค้า · ของอร่อย',
                        hintStyle: TextStyle(
                          fontFamily: 'IBM Plex Sans Thai',
                          fontSize: 13,
                          color: TpColors.muted,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotChip extends StatelessWidget {
  const _HotChip({
    required this.label,
    required this.trending,
    required this.onTap,
  });

  final String label;
  final bool trending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = trending ? TpColors.pink : Colors.white;
    final fg = trending ? Colors.white : TpColors.deepInk;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            boxShadow: TpShadows.claySm,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trending) ...[
                const Text('🔥 ', style: TextStyle(fontSize: 11)),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Thai',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      radius: 14,
      shadow: ClayShadow.small,
      child: Row(
        children: [
          const Icon(Icons.history_rounded, size: 16, color: TpColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Thai',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: TpColors.ink,
              ),
            ),
          ),
          const Icon(Icons.north_west_rounded,
              size: 18, color: TpColors.muted),
        ],
      ),
    );
  }
}
