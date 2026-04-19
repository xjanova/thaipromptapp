import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../features/affiliate/affiliate_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/cart/cart_page.dart';
import '../features/chat/chat_page.dart';
import '../features/home/home_page.dart';
import '../features/nong_ying/install_model_page.dart';
import '../features/nong_ying/nong_ying_fab.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/product/product_page.dart';
import '../features/settings/settings_page.dart';
import '../features/shop/shop_page.dart';
import '../features/splash/splash_page.dart';
import '../features/tracking/tracking_page.dart';
import '../features/wallet/qr_scan_page.dart';
import '../features/wallet/topup_page.dart';
import '../features/wallet/transfer_page.dart';
import '../features/wallet/wallet_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final here = state.matchedLocation;

      if (auth is AuthUnknown) {
        return here == '/splash' ? null : '/splash';
      }

      final isAuthRoute = const {
        '/onboarding',
        '/login',
        '/register',
      }.contains(here);

      if (auth is AuthUnauthenticated) {
        if (here == '/splash') return '/onboarding';
        return isAuthRoute ? null : '/onboarding';
      }

      if (here == '/splash' || isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
      GoRoute(path: '/cart', builder: (_, __) => const CartPage()),
      GoRoute(
        path: '/product/:id',
        builder: (_, state) => ProductPage(productId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/shop/:id',
        builder: (_, state) => ShopPage(shopId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/orders/:id/tracking',
        builder: (_, state) => TrackingPage(orderId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/orders/:id/chat',
        builder: (_, state) {
          final shop = state.uri.queryParameters['shop'];
          return ChatPage(
            orderId: int.parse(state.pathParameters['id']!),
            shopName: shop,
          );
        },
      ),

      // Money
      GoRoute(path: '/wallet', builder: (_, __) => const WalletPage()),
      GoRoute(path: '/wallet/topup', builder: (_, __) => const TopupPage()),
      GoRoute(path: '/wallet/transfer', builder: (_, __) => const TransferPage()),
      GoRoute(path: '/wallet/scan', builder: (_, __) => const QrScanPage()),
      GoRoute(path: '/wallet/withdraw', builder: (_, __) => const TopupPage()), // stub
      GoRoute(path: '/affiliate', builder: (_, __) => const AffiliatePage()),

      // AI น้องหญิง
      GoRoute(path: '/nong-ying', builder: (_, __) => const NongYingRouteBridge()),
      GoRoute(path: '/nong-ying/install', builder: (_, __) => const InstallModelPage()),

      // Settings
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('ไม่พบเส้นทาง: ${state.uri}')),
    ),
  );
});
