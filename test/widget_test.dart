// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roommate_finder/main.dart';

void main() {
  testWidgets('Splash screen shows roommate finder texts', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(
      hasLoggedInBefore: false,
      hasActiveSession: false,
    ));

    // Verify that our splash screen text is shown.
    expect(find.text('ROOMMATE'), findsOneWidget);
    expect(find.text('FINDER'), findsOneWidget);

    // Settle the navigation timer so the test can exit cleanly.
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
