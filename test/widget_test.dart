import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:thaipromptapp/app/app.dart';

void main() {
  testWidgets('App boots without throwing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ThaipromptApp()),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
