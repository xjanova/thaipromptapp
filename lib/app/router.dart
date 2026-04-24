import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../features/affiliate/affiliate_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/cart/cart_page.dart';
import '../features/chat/chat_page.dart';
import '../features/checkout/checkout_pages.dart';
import '../features/fresh_market/listing_detail_page.dart';
import '../features/fresh_market/listings_page.dart';
import '../features/fresh_market/my_orders_page.dart';
import '../features/fresh_market/seller_page.dart';
import '../features/fresh_market/taladsod_home_page.dart';
import '../features/home/categories_page.dart';
import '../features/home/home_page.dart';
import '../features/home/search_page.dart';
import '../features/mlm/mlm_pages.dart';
import '../features/mlm/mlm_shell.dart';
import '../features/nong_ying/install_model_page.dart';
import '../features/nong_ying/nong_ying_fab.dart';
import '../features/notifications/notifications_page.dart';
import '../features/onboarding/mode_select_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/orders/orders_pages.dart';
import '../features/product/product_page.dart';
import '../features/profile/profile_pages.dart';
import '../features/review/review_page.dart';
import '../features/rider/rider_pages.dart';
import '../features/rider/rider_shell.dart';
import '../features/seller/seller_pages.dart';
import '../features/seller/seller_shell.dart';
import '../features/settings/settings_page.dart';
import '../features/shop/shop_page.dart';
import '../features/splash/splash_gate.dart';
import '../features/splash/splash_page.dart';
import '../features/tracking/tracking_page.dart';
import '../features/wallet/qr_scan_page.dart';
import '../features/wallet/topup_page.dart';
import '../features/wallet/transfer_page.dart';
import '../features/wallet/wallet_page.dart';

/// Exposes the router's Navigator to widgets that sit in `MaterialApp.router`'s
/// `builder:` callback — above the router tree — so they can still call
/// `showDialog` / `Navigator.push`. Most notably [UpdateObserver], which
/// otherwise silently fails because its BuildContext has no Navigator
/// ancestor (the Navigator lives BELOW the builder, not above).
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root-nav');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    navigatorKey: rootNavigatorKey,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final splashDone = ref.read(splashGateProvider);
      final here = state.matchedLocation;

      if (!splashDone && here == '/splash') return null;

      if (auth is AuthUnknown) {
        return here == '/splash' ? null : '/splash';
      }

      final isAuthRoute = const {
        '/onboarding',
        '/login',
        '/register',
      }.contains(here);

      // Guest mode: browse-without-login for home, taladsod, products,
      // shops, settings, and tracking (read-only by token). Everything
      // else (cart, wallet, affiliate, checkout, mode-specific shells)
      // requires auth.
      const guestAllowedExact = {
        '/home',
        '/buyer',
        '/buyer/search',
        '/buyer/categories',
        '/taladsod',
        '/taladsod/listings',
        '/settings',
        '/nong-ying',
        '/nong-ying/install',
      };
      final isGuestAllowedPrefix = here.startsWith('/product/')
          || here.startsWith('/shop/')
          || here.startsWith('/buyer/product/')
          || here.startsWith('/buyer/shop/')
          || here.startsWith('/taladsod/listings/')
          || here.startsWith('/taladsod/sellers/')
          || (here.startsWith('/orders/') && here.endsWith('/tracking'));

      if (auth is AuthUnauthenticated) {
        if (here == '/splash') return '/onboarding';
        if (isAuthRoute) return null;
        if (guestAllowedExact.contains(here) || isGuestAllowedPrefix) {
          return null;
        }
        return '/login';
      }

      if (here == '/splash' || isAuthRoute) return '/mode';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      // Mode Select — post-login role picker (v1.0.22)
      GoRoute(path: '/mode', builder: (_, __) => const ModeSelectPage()),

      // ═══════════════════════════════════════════════════════════════
      // BUYER — existing home lives at /home for back-compat; new
      // design uses /buyer + nested routes. Home redirects to /buyer.
      // ═══════════════════════════════════════════════════════════════
      GoRoute(path: '/home', redirect: (_, __) => '/buyer'),
      GoRoute(path: '/buyer', builder: (_, __) => const HomePage()),
      GoRoute(path: '/buyer/search', builder: (_, __) => const SearchPage()),
      GoRoute(path: '/buyer/categories', builder: (_, __) => const CategoriesPage()),
      GoRoute(
        path: '/buyer/product/:id',
        builder: (_, state) =>
            ProductPage(productId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/buyer/shop/:id',
        builder: (_, state) =>
            ShopPage(shopId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: '/buyer/cart', redirect: (_, __) => '/cart'),
      GoRoute(path: '/buyer/orders', builder: (_, __) => const OrdersPage()),
      GoRoute(
        path: '/buyer/tracking/:id',
        builder: (_, state) =>
            TrackingPage(orderId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/buyer/chat/:id',
        builder: (_, state) {
          final shop = state.uri.queryParameters['shop'];
          return ChatPage(
            orderId: int.parse(state.pathParameters['id']!),
            shopName: shop,
          );
        },
      ),
      GoRoute(
        path: '/buyer/review/:id',
        builder: (_, state) =>
            ReviewPage(orderId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: '/buyer/notifications', builder: (_, __) => const NotificationsPage()),
      GoRoute(path: '/buyer/profile', builder: (_, __) => const ProfilePage()),
      GoRoute(path: '/buyer/addresses', builder: (_, __) => const AddressBookPage()),
      GoRoute(path: '/buyer/coupons', builder: (_, __) => const CouponsPage()),
      GoRoute(path: '/buyer/wallet', redirect: (_, __) => '/wallet'),
      GoRoute(path: '/buyer/affiliate', redirect: (_, __) => '/affiliate'),

      // Checkout flow (/buyer/checkout/*)
      GoRoute(
        path: '/buyer/checkout/address',
        builder: (_, __) => const CheckoutAddressPage(),
      ),
      GoRoute(
        path: '/buyer/checkout/payment',
        builder: (_, __) => const CheckoutPaymentPage(),
      ),
      GoRoute(
        path: '/buyer/checkout/qr',
        builder: (_, __) => const CheckoutQrPage(),
      ),
      GoRoute(
        path: '/buyer/checkout/paid',
        builder: (_, __) => const CheckoutPaidPage(),
      ),
      GoRoute(
        path: '/buyer/checkout/receipt/:orderId',
        builder: (_, state) => CheckoutReceiptPage(
          orderId: int.parse(state.pathParameters['orderId']!),
        ),
      ),

      // Legacy (pre-v1.0.22) routes — kept as redirects so deep-links don't break
      GoRoute(path: '/cart', builder: (_, __) => const CartPage()),
      GoRoute(
        path: '/product/:id',
        builder: (_, state) =>
            ProductPage(productId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/shop/:id',
        builder: (_, state) =>
            ShopPage(shopId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/orders/:id/tracking',
        builder: (_, state) =>
            TrackingPage(orderId: int.parse(state.pathParameters['id']!)),
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

      // Wallet (flat — no shell)
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

      // ═══════════════════════════════════════════════════════════════
      // SELLER shell (/seller/*)
      // ═══════════════════════════════════════════════════════════════
      ShellRoute(
        builder: (context, state, child) => SellerShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(path: '/seller', builder: (_, __) => const SellerDashboardPage()),
          GoRoute(path: '/seller/orders', builder: (_, __) => const SellerOrdersPage()),
          GoRoute(path: '/seller/products', builder: (_, __) => const SellerProductsPage()),
          GoRoute(path: '/seller/promos', builder: (_, __) => const SellerPromosPage()),
          GoRoute(path: '/seller/reports', builder: (_, __) => const SellerReportsPage()),
          GoRoute(path: '/seller/withdraw', builder: (_, __) => const SellerWithdrawPage()),
        ],
      ),
      // Leaf seller routes without shell (so detail pages take full screen)
      GoRoute(
        path: '/seller/orders/:id',
        builder: (_, __) => const SellerOrderDetailPage(orderId: 0),
      ),
      GoRoute(
        path: '/seller/products/:id',
        builder: (_, state) => SellerProductEditPage(
          productId: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
        ),
      ),

      // ═══════════════════════════════════════════════════════════════
      // RIDER shell (/rider/*)
      // ═══════════════════════════════════════════════════════════════
      ShellRoute(
        builder: (context, state, child) => RiderShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(path: '/rider', builder: (_, __) => const RiderDashboardPage()),
          GoRoute(path: '/rider/jobs', builder: (_, __) => const RiderJobsPage()),
          GoRoute(path: '/rider/earnings', builder: (_, __) => const RiderEarningsPage()),
          GoRoute(path: '/rider/profile', builder: (_, __) => const RiderProfilePage()),
        ],
      ),
      GoRoute(
        path: '/rider/jobs/:id',
        builder: (_, state) => RiderJobDetailPage(
          jobId: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
        ),
      ),

      // ═══════════════════════════════════════════════════════════════
      // MLM shell (/mlm/*)
      // ═══════════════════════════════════════════════════════════════
      ShellRoute(
        builder: (context, state, child) => MlmShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(path: '/mlm', builder: (_, __) => const MlmDashboardPage()),
          GoRoute(path: '/mlm/tree', builder: (_, __) => const MlmTreePage()),
          GoRoute(path: '/mlm/earnings', builder: (_, __) => const MlmEarningsPage()),
          GoRoute(path: '/mlm/invite', builder: (_, __) => const MlmInvitePage()),
        ],
      ),
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
                  onPressed: () => context.go('/buyer'),
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
