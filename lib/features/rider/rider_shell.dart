import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_tab_bar.dart';

/// ShellRoute wrapper for the Rider role. Dark ink background, mango accent
/// on ink text, onDark tab bar (see README §Bottom Nav).
class RiderShell extends StatelessWidget {
  const RiderShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  String get _currentTab {
    if (location.startsWith('/rider/jobs')) return 'jobs';
    if (location.startsWith('/rider/earnings')) return 'earnings';
    if (location.startsWith('/rider/profile')) return 'profile';
    return 'dash';
  }

  void _go(BuildContext context, String id) {
    switch (id) {
      case 'dash':
        context.go('/rider');
      case 'jobs':
        context.go('/rider/jobs');
      case 'earnings':
        context.go('/rider/earnings');
      case 'profile':
        context.go('/rider/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.deepInk,
      body: child,
      bottomNavigationBar: AppTabBar(
        items: RoleTabs.rider,
        currentId: _currentTab,
        onChanged: (id) => _go(context, id),
        onDark: true,
      ),
    );
  }
}
