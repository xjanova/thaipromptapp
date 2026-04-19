import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../features/affiliate/affiliate_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/cart/cart_page.dart';
import '../features/chat/chat_page.dart';
import '../features/fresh_market/listing_detail_page.dart';
import '../features/fresh_market/listings_page.dart';
import '../features/fresh_market/my_orders_page.dart';
import '../features/fresh_market/seller_page.dart';
import '../features/fresh_market/taladsod_home_page.dart';
import '../features/home/home_page.dart';
import '../features/nong_ying/install_model_page.dart';
import '../features/nong_ying/nong_ying_fab.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/product/product_page.dart';
import '../features/settings/settings_page.dart';
import '../features/shop/shop_page.dart';
import '../features/splash/splash_gate.dart';
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
      final splashDone = ref.read(splashGateProvider);
      final here = state.matchedLocation;

      // Cold-start: keep user on /splash until the animated intro finishes,
      // even if auth resolves first. Splash flips the gate when its anim ends.
      if (!splashDone && here == '/splash') return null;

      if (auth is AuthUnknown) {
        return here == '/splash' ? null : '/splash';
      }

      final isAuthRoute = const {
        '/onboarding',
        '/login',
        '/register',
      }.contains(here);

      // ───────── Guest mode ────────────────────────────────────────────────
      // Browse-without-login: anyone can wander the home grid, ตลาดสด,
      // products, shops, and tracking pages (Tracking is read-only by token,
      // not by user-id). The auth-gate on protected routes (cart checkout,
      // wallet, profile, my orders) is enforced by the screens themselves —
      // they push to /login with a snackbar when an action requires a
      // userId. The router stays out of the way so the user never hits a
      // dead-end onboarding screen on first launch.
      const guestAllowedExact = {
        '/home',
        '/taladsod',
        '/taladsod/listings',
      };
      final isGuestAllowedPrefix = here.startsWith('/product/')
          || here.startsWith('/shop/')
          || here.startsWith('/taladsod/listings/')
          || here.startsWith('/taladsod/sellers/')
          || here.startsWith('/orders/') && here.endsWith('/tracking');

      if (auth is AuthUnauthenticated) {
        if (here == '/splash') return '/home';
        if (isAuthRoute) return null;
        if (guestAllowedExact.contains(here) || isGuestAllowedPrefix) {
          return null;
        }
        // Anything else (cart, wallet, settings, my orders, ...) needs auth.
        return '/login';
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

      // ตลาดสด (Fresh Market)
      GoRoute(path: '/taladsod', builder: (_, __) => const TaladsodHomePage()),
      GoRoute(
        path: '/taladsod/listings',
        builder: (_, state) {
          final cat = state.uri.queryParameters['category'];
          return TaladsodListingsPage(
            initialCategoryId: cat == null ? null : int.tryParse(cat),
          );
        },
      ),
      GoRoute(
        path: '/taladsod/listings/:id',
        builder: (_, state) =>
            TaladsodListingDetailPage(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/taladsod/sellers/:id',
        builder: (_, state) =>
            TaladsodSellerPage(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/taladsod/orders',
        builder: (_, __) => const TaladsodMyOrdersPage(),
      ),

      // Settings
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('ไม่พบเส้นทาง: ${state.uri}')),
    ),
  );
});
