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
      // products, shops, settings (on-device AI/voice install, About),
      // นง'หญิง FAB, and tracking pages (Tracking is read-only by token).
      // The auth-gate on truly user-scoped routes (cart checkout, wallet,
      // affiliate dashboard, my orders) is enforced here — tapping them
      // redirects to /login. The login/register screens give a "ข้ามไปก่อน"
      // escape hatch back to /home so the user never dead-ends.
      //
      // First launch (cold start, no token): splash → /onboarding so the
      // user sees the "ตลาดนัดอยู่ในมือ" intro card. "เริ่มใช้เลย" on
      // that card lands them on /home as a guest; "เข้าสู่ระบบ" goes to
      // /login. Subsequent launches (warm start, still unauthenticated)
      // also pass through splash → /onboarding so the brand intro is the
      // stable entry point rather than dumping straight into home.
      const guestAllowedExact = {
        '/home',
        '/taladsod',
        '/taladsod/listings',
        '/settings',        // on-device AI model install · About · no PII
        '/nong-ying',       // local Gemma chat · prompts only, no account
        '/nong-ying/install',
      };
      final isGuestAllowedPrefix = here.startsWith('/product/')
          || here.startsWith('/shop/')
          || here.startsWith('/taladsod/listings/')
          || here.startsWith('/taladsod/sellers/')
          || here.startsWith('/orders/') && here.endsWith('/tracking');

      if (auth is AuthUnauthenticated) {
        if (here == '/splash') return '/onboarding';
        if (isAuthRoute) return null;
        if (guestAllowedExact.contains(here) || isGuestAllowedPrefix) {
          return null;
        }
        // Anything else (cart, wallet, affiliate, my orders, ...) needs auth.
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
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.explore_off_rounded,
                    size: 48, color: Color(0xFFD97706)),
                const SizedBox(height: 12),
                const Text(
                  'อุ๊ย · หน้านี้ไม่ว่างในตอนนี้',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'กลับไปหน้าแรกก่อนนะคะ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                  ),
                  onPressed: () => context.go('/home'),
                  child: const Text('กลับหน้าแรก'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
});
