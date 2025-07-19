import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alumni_app/pages/home.dart'; // Import your HomePageWidget
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:alumni_app/theme_notifier.dart';

void main() {
  testWidgets('HomePageWidget displays app bar, search bar, and lists',
      (WidgetTester tester) async {
    // Mock the ThemeNotifier
    final mockThemeNotifier = ThemeNotifier();

    // Build the HomePageWidget wrapped in MaterialApp and Provider
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeNotifier>.value(
        value: mockThemeNotifier,
        child: MaterialApp(
          home: HomePageWidget(),
        ),
      ),
    );

    // Verify that the app bar is displayed
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Alumni Network'), findsOneWidget);

    // Verify that the search bar is displayed
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Search Alumni...'), findsOneWidget);

    // Verify that the events list is displayed
    expect(find.byType(ListView),
        findsWidgets); // Assuming events and alumni lists are ListViews

    // Verify that the "Add Member" and "Add Event" buttons are present
    expect(find.byIcon(Icons.add_circle), findsOneWidget);

    // Tap the "Add Member" button and verify the dialog appears
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();
    expect(find.text('Add Member'), findsOneWidget);

    // Close the dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Tap the "Add Event" button and verify the dialog appears
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();
    expect(find.text('Add Event'), findsOneWidget);
  });
}
