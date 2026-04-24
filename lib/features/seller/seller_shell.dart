import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_tab_bar.dart';

/// ShellRoute wrapper for the Seller role. Keeps the [AppTabBar] persistent
/// across `/seller/*` sub-routes. Accent = tomato on white text
/// (see README §Bottom Nav).
class SellerShell extends StatelessWidget {
  const SellerShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  String get _currentTab {
    if (location.startsWith('/seller/orders')) return 'orders';
    if (location.startsWith('/seller/products')) return 'products';
    if (location.startsWith('/seller/reports')) return 'reports';
    if (location.startsWith('/seller/withdraw')) return 'withdraw';
    return 'dash';
  }

  void _go(BuildContext context, String id) {
    switch (id) {
      case 'dash':
        context.go('/seller');
      case 'orders':
        context.go('/seller/orders');
      case 'products':
        context.go('/seller/products');
      case 'reports':
        context.go('/seller/reports');
      case 'withdraw':
        context.go('/seller/withdraw');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: child,
      bottomNavigationBar: AppTabBar(
        items: RoleTabs.seller,
        currentId: _currentTab,
        onChanged: (id) => _go(context, id),
        accent: TpColors.tomato,
        accentText: Colors.white,
      ),
    );
  }
}
