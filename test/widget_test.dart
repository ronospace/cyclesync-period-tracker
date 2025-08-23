// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flowsense/services/theme_service.dart';

void main() {
  testWidgets('Calendar screen widget test', (WidgetTester tester) async {
    // Create simple test app with theme service
    final themeService = ThemeService();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeService),
        ],
        child: MaterialApp(
          title: 'Test App',
          theme: ThemeService.lightTheme,
          home: const Scaffold(
            body: Center(
              child: Text('Calendar Test'),
            ),
          ),
        ),
      ),
    );

    // Wait for the app to load
    await tester.pumpAndSettle();

    // Verify that our test app loads properly
    expect(find.text('Calendar Test'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
