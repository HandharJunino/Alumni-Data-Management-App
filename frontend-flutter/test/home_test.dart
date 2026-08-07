import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alumni_app/pages/home.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:alumni_app/theme_notifier.dart';
import 'package:alumni_app/functions/crud.dart';
import 'package:alumni_app/functions/authentication.dart';

class MockApiService extends Mock implements ApiService {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockApiService mockApiService;
  late MockAuthService mockAuthService;

  setUp(() {
    mockApiService = MockApiService();
    mockAuthService = MockAuthService();

    when(() => mockApiService.getAlumniList(
          search: any(named: 'search'),
          filters: any(named: 'filters'),
          ordering: any(named: 'ordering'),
        )).thenAnswer((_) async => [
          {'id': 1, 'name': 'Jane Doe', 'email': 'jane@example.com'},
        ]);

    when(() => mockApiService.getEventsList()).thenAnswer((_) async => [
          {'id': 1, 'name': 'Tech Conference', 'date': '2025-05-01'},
        ]);
  });

  testWidgets('HomePageWidget displays app bar, search bar, and lists',
      (WidgetTester tester) async {
    final mockThemeNotifier = ThemeNotifier();

    // Build the HomePageWidget wrapped in MaterialApp and Provider, with
    // mocked services so no real network call is made.
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeNotifier>.value(
        value: mockThemeNotifier,
        child: MaterialApp(
          home: HomePageWidget(
            apiService: mockApiService,
            authService: mockAuthService,
          ),
        ),
      ),
    );

    // Let the initial async load (Future.wait of alumni + events) resolve.
    await tester.pump();
    await tester.pump();

    // Verify that the app bar is displayed
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Alumni Network'), findsOneWidget);

    // Verify that the search bar is displayed
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Search Alumni...'), findsOneWidget);

    // Verify that the events and alumni lists are displayed
    expect(find.byType(ListView), findsWidgets);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('Tech Conference'), findsOneWidget);

    // Verify that the "Add Member" and "Add Event" buttons are present
    expect(find.byIcon(Icons.add_circle), findsOneWidget);

    // Open the overflow menu and tap "Add Member" to open the dialog
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Member'));
    await tester.pumpAndSettle();
    expect(find.text('Add Member'), findsOneWidget); // dialog title

    // Close the dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Open the overflow menu and tap "Add Event" to open the dialog
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Event'));
    await tester.pumpAndSettle();
    expect(find.text('Add Event'), findsOneWidget); // dialog title
  });
}
