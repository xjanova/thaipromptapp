import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// Item rendered in [AppTabBar].
///
/// [id]     — route suffix or enum string used as the tab identity.
/// [label]  — Thai label shown when the tab is active (expanded state).
/// [icon]   — icon drawn at all times.
/// [badge]  — optional numeric badge (1–99+). Rendered as a pink pill.
class AppTabItem {
  const AppTabItem({
    required this.id,
    required this.label,
    required this.icon,
    this.badge,
  });

  final String id;
  final String label;
  final IconData icon;
  final int? badge;
}

/// Dark-floating-pill bottom nav from the v2 design handoff.
///
/// Canonical spec (see `design_handoff_thaiprompt_marketplace/buyer-app.jsx`
/// → `AppTabBar`):
///
/// - Pill bar: `#0E0B1F`, 22px radius, 6px inner pad, 4px item gap, 46px tall.
/// - Active tab: flex-grows to fill the rest, accent fill, accent text color,
///   16px radius, 16px horizontal pad, icon + label side-by-side.
/// - Inactive tab: 46×46 square, transparent fill, icon-only, rgba-white-78%.
/// - Transition: 280ms `cubic-bezier(.5, 1.4, .5, 1)` on everything (width,
///   fill color, text opacity).
/// - Accent per role: Buyer/Rider/MLM → mango `#FFC94D` on ink text; Seller →
///   tomato `#FF7A3A` on white text.
/// - Top fade: a gradient strip above the pill to soften the transition from
///   the underlying screen. Uses the cream or ink-dark gradient depending on
///   [onDark].
/// - Badge: pink pill, 2px ink-color border-box separator so it reads clearly
///   over the dark nav.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.items,
    required this.currentId,
    required this.onChanged,
    this.accent = TpColors.mango,
    this.accentText = TpColors.deepInk,
    this.onDark = false,
  });

  /// Tabs rendered left-to-right.
  final List<AppTabItem> items;

  /// Id of the currently-active tab (matches [AppTabItem.id]).
  final String currentId;

  /// Fired when the user taps a tab. Receives the tapped tab's id.
  final ValueChanged<String> onChanged;

  /// Fill color of the active tab. Defaults to mango (Buyer/Rider/MLM).
  /// Seller should pass [TpColors.tomato].
  final Color accent;

  /// Text + icon color of the active tab. Buyer/Rider/MLM use ink; Seller
  /// should pass `Colors.white`.
  final Color accentText;

  /// Set to true when the underlying page has a dark background (Rider, MLM).
  /// Flips the top fade from cream → transparent to ink-dark → transparent.
  final bool onDark;

  static const _transitionDuration = Duration(milliseconds: 280);
  static const _springCurve = Cubic(0.5, 1.4, 0.5, 1.0);

  @override
  Widget build(BuildContext context) {
    final topFadeColors = onDark
        ? const [Color(0xE60E0B1F), Color(0x000E0B1F)]
        : const [Color(0xE6FFF8EE), Color(0x00FFF8EE)];

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: const [0.55, 1.0],
            colors: topFadeColors,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: TpColors.deepInk,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x8C0E0B1F),
                    offset: Offset(0, 10),
                    blurRadius: 28,
                    spreadRadius: -10,
                  ),
                ],
                // Inset 1px white hairline approximation — true inset shadows
                // need a custom painter, but this `Border.all` on the same
                // dark fill reads as the intended subtle highlight.
                border: Border.all(
                  color: const Color(0x0FFFFFFF),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      _TabButton(
                        item: items[i],
                        active: items[i].id == currentId,
                        accent: accent,
                        accentText: accentText,
                        onTap: () => onChanged(items[i].id),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.active,
    required this.accent,
    required this.accentText,
    required this.onTap,
  });

  final AppTabItem item;
  final bool active;
  final Color accent;
  final Color accentText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Flex grow when active — the inactive tabs stay at 46×46 squares.
    // AnimatedContainer handles the width/fill tween; we wrap it in
    // Expanded(flex:) for active and a fixed SizedBox for inactive so the
    // Row allocates space correctly during the transition.
    final button = Semantics(
      label: item.label,
      selected: active,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppTabBar._transitionDuration,
            curve: AppTabBar._springCurve,
            height: 46,
            padding: EdgeInsets.symmetric(horizontal: active ? 16 : 0),
            decoration: BoxDecoration(
              color: active ? accent : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.6),
                        offset: const Offset(0, 10),
                        blurRadius: 18,
                        spreadRadius: -8,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 22,
                      color: active
                          ? accentText
                          : const Color(0xC7FFFFFF), // rgba(255,255,255,.78)
                    ),
                    // AnimatedSize would be ideal here but the parent
                    // AnimatedContainer already handles the width tween
                    // via flex. We simply fade the label in when active.
                    AnimatedSize(
                      duration: AppTabBar._transitionDuration,
                      curve: AppTabBar._springCurve,
                      alignment: Alignment.centerLeft,
                      child: active
                          ? Padding(
                              padding: const EdgeInsets.only(left: 7),
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Thai',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 0.12,
                                  color: accentText,
                                  height: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                if (item.badge != null && item.badge! > 0)
                  Positioned(
                    top: -2,
                    right: active ? 6 : -2,
                    child: _Badge(count: item.badge!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (active) {
      return Expanded(child: button);
    }
    return SizedBox(width: 46, child: button);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: TpColors.pink,
        borderRadius: BorderRadius.circular(999),
        // 2px ink-color border separator so the badge reads on the dark
        // nav even when partially behind an accent-filled active tab.
        border: Border.all(color: TpColors.deepInk, width: 2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'IBM Plex Sans Thai',
          fontWeight: FontWeight.w800,
          fontSize: 9,
          color: Colors.white,
          height: 1.0,
        ),
      ),
    );
  }
}

/// Pre-built tab sets per role. Keep these colocated with the widget so the
/// canonical per-role accent + item list live in one place.
class RoleTabs {
  const RoleTabs._();

  static const buyer = <AppTabItem>[
    AppTabItem(id: 'home', label: 'หน้าแรก', icon: Icons.home_rounded),
    AppTabItem(id: 'categories', label: 'หมวด', icon: Icons.grid_view_rounded),
    AppTabItem(id: 'orders', label: 'ออเดอร์', icon: Icons.shopping_bag_outlined),
    AppTabItem(id: 'wallet', label: 'Wallet', icon: Icons.account_balance_wallet_outlined),
    AppTabItem(id: 'profile', label: 'ฉัน', icon: Icons.person_outline_rounded),
  ];

  static const seller = <AppTabItem>[
    AppTabItem(id: 'dash', label: 'แดชบอร์ด', icon: Icons.dashboard_rounded),
    AppTabItem(id: 'orders', label: 'ออเดอร์', icon: Icons.shopping_bag_outlined),
    AppTabItem(id: 'products', label: 'สินค้า', icon: Icons.inventory_2_outlined),
    AppTabItem(id: 'reports', label: 'รายงาน', icon: Icons.bar_chart_rounded),
    AppTabItem(id: 'withdraw', label: 'ถอน', icon: Icons.account_balance_wallet_outlined),
  ];

  static const rider = <AppTabItem>[
    AppTabItem(id: 'dash', label: 'งาน', icon: Icons.map_rounded),
    AppTabItem(id: 'jobs', label: 'คิว', icon: Icons.list_alt_rounded),
    AppTabItem(id: 'earnings', label: 'รายได้', icon: Icons.monetization_on_outlined),
    AppTabItem(id: 'profile', label: 'ฉัน', icon: Icons.person_outline_rounded),
  ];

  static const mlm = <AppTabItem>[
    AppTabItem(id: 'dash', label: 'แดชบอร์ด', icon: Icons.dashboard_rounded),
    AppTabItem(id: 'tree', label: 'ทีม', icon: Icons.account_tree_rounded),
    AppTabItem(id: 'earnings', label: 'รายได้', icon: Icons.monetization_on_outlined),
    AppTabItem(id: 'invite', label: 'เชิญ', icon: Icons.person_add_alt_rounded),
  ];
}
