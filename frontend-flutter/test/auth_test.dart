import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alumni_app/pages/auth.dart'; // Import your AuthPageWidget
import 'package:mockito/mockito.dart';
import 'package:alumni_app/functions/authentication.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  testWidgets('AuthPageWidget displays sign-in form and handles login',
      (WidgetTester tester) async {
    // Mock successful login
    when(mockAuthService.loginUser('test@example.com', 'password123'))
        .thenAnswer((_) async => null);

    // Build the AuthPageWidget
    await tester.pumpWidget(
      MaterialApp(
        home: AuthPageWidget(),
      ),
    );

    // Verify that the sign-in form is displayed
    expect(find.text('Sign In'), findsWidgets); // Multiple "Sign In" texts
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Enter email and password
    await tester.enterText(
        find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Tap the "Sign In" button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump();

    // Verify that no error message is displayed
    expect(find.text('Please enter both email and password'), findsNothing);
  });

  testWidgets('AuthPageWidget displays sign-up form and handles registration',
      (WidgetTester tester) async {
    // Mock successful registration
    when(mockAuthService.registerUser(
      'testuser',
      'test@example.com',
      'password123',
      'password123',
    )).thenAnswer((_) async => null);

    // Build the AuthPageWidget
    await tester.pumpWidget(
      MaterialApp(
        home: AuthPageWidget(),
      ),
    );

    // Switch to the "Sign Up" tab
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify that the sign-up form is displayed
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);

    // Enter sign-up details
    await tester.enterText(find.byType(TextFormField).at(0), 'testuser');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');

    // Tap the "Create Account" button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump();

    // Verify that no error message is displayed
    expect(find.text('Passwords don\'t match!'), findsNothing);
  });
}
