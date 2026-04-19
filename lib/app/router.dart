import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/cart/cart_page.dart';
import '../features/chat/chat_page.dart';
import '../features/home/home_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/product/product_page.dart';
import '../features/shop/shop_page.dart';
import '../features/splash/splash_page.dart';
import '../features/tracking/tracking_page.dart';

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

      // Authenticated
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
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('ไม่พบเส้นทาง: ${state.uri}')),
    ),
  );
});
