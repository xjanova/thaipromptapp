import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_state.dart';
import '../core/theme/clay_theme.dart';
import '../core/update/update_observer.dart';
import 'router.dart';

class ThaipromptApp extends ConsumerWidget {
  const ThaipromptApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for auth state changes so router redirect picks them up.
    ref.listen(authControllerProvider, (_, __) {
      ref.read(routerProvider).refresh();
    });

    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Thaiprompt',
      debugShowCheckedModeBanner: false,
      theme: buildThaipromptTheme(),
      routerConfig: router,
      supportedLocales: const [Locale('th', 'TH'), Locale('en', 'US')],
      locale: const Locale('th', 'TH'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => UpdateObserver(child: child ?? const SizedBox.shrink()),
    );
  }
}
