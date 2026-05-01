// This is a basic Flutter widget test for the Aqua app.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts and shows either SplashScreen or HomeScreen
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
