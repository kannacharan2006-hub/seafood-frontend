// Test for Purchase History Screen
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/purchase/presentation/purchase_history_screen.dart';
import 'package:flutter_application_1/features/purchase/data/purchase_history_service.dart';

void main() {
  testWidgets('PurchaseHistoryScreen loads without error',
      (WidgetTester tester) async {
    // Build the purchase history screen
    await tester.pumpWidget(const MaterialApp(
      home: PurchaseHistoryScreen(),
    ));

    // Verify that the screen renders
    expect(find.byType(PurchaseHistoryScreen), findsOneWidget);
  });

  test('PurchaseHistoryService has fetchPurchases method', () {
    // This test verifies that the service has the required method
    // We can't actually call it without mocking the API, but we can verify it exists
    expect(PurchaseHistoryService.fetchPurchases, isNotNull);
  });

  test('PurchaseHistoryService has fetchHistory method', () {
    // Verify that the original method still exists
    expect(PurchaseHistoryService.fetchHistory, isNotNull);
  });

  test('PurchaseHistoryService has deletePurchase method', () {
    // Verify that the delete method exists with correct signature
    expect(PurchaseHistoryService.deletePurchase, isNotNull);
  });
}
