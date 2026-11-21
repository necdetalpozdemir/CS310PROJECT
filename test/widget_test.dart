import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myhabits/main.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MyHabitsApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
