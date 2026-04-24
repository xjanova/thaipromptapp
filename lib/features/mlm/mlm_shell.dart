import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_tab_bar.dart';

/// ShellRoute wrapper for the MLM / Affiliate role. Same dark bg as Rider,
/// mango accent. Extends the existing `features/affiliate/` UX into a 4-tab
/// shell per the design spec.
class MlmShell extends StatelessWidget {
  const MlmShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  String get _currentTab {
    if (location.startsWith('/mlm/tree')) return 'tree';
    if (location.startsWith('/mlm/earnings')) return 'earnings';
    if (location.startsWith('/mlm/invite')) return 'invite';
    return 'dash';
  }

  void _go(BuildContext context, String id) {
    switch (id) {
      case 'dash':
        context.go('/mlm');
      case 'tree':
        context.go('/mlm/tree');
      case 'earnings':
        context.go('/mlm/earnings');
      case 'invite':
        context.go('/mlm/invite');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.deepInk,
      body: child,
      bottomNavigationBar: AppTabBar(
        items: RoleTabs.mlm,
        currentId: _currentTab,
        onChanged: (id) => _go(context, id),
        onDark: true,
      ),
    );
  }
}
