// Basic smoke test for Tiz Mobile app

import 'package:flutter_test/flutter_test.dart';

import 'package:tiz_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TizApp());

    // Verify app loads without errors
    expect(find.text('Tiz Mobile'), findsWidgets);
  });
}
