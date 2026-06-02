import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ortakhesap/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: OrtakHesapApp(),
      ),
    );

    // Verify that our app widget is built.
    expect(find.byType(OrtakHesapApp), findsOneWidget);
  });
}
