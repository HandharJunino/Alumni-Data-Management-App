import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alumni_app/functions/authentication.dart';
import 'dart:convert';

class MockHttpClient extends Mock implements http.Client {}

class MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthService authService;
  late MockHttpClient mockClient;
  late MockStorage mockStorage;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://example.com'));
  });

  setUp(() {
    mockClient = MockHttpClient();
    mockStorage = MockStorage();
    authService = AuthService(client: mockClient, storage: mockStorage);
  });

  group('loginUser', () {
    test('successful login stores both tokens and returns null', () async {
      when(() => mockClient.post(
            Uri.parse('${AuthService.baseUrl}login/'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({'token': 'access123', 'refresh': 'refresh123'}),
            200,
          ));
      when(() => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});

      final result = await authService.loginUser('user', 'pass');

      expect(result, isNull);
      verify(() => mockStorage.write(key: 'auth_token', value: 'access123'))
          .called(1);
      verify(() =>
              mockStorage.write(key: 'refresh_token', value: 'refresh123'))
          .called(1);
    });

    test('failed login returns the server error message', () async {
      when(() => mockClient.post(
            Uri.parse('${AuthService.baseUrl}login/'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({'detail': 'Invalid credentials'}),
            401,
          ));

      final result = await authService.loginUser('user', 'wrong');

      expect(result, 'Invalid credentials');
      verifyNever(() => mockStorage.write(
          key: any(named: 'key'), value: any(named: 'value')));
    });
  });

  group('registerUser', () {
    test('successful registration returns null', () async {
      when(() => mockClient.post(
            Uri.parse('${AuthService.baseUrl}register/'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({'id': 1, 'username': 'user'}),
            201,
          ));

      final result = await authService.registerUser(
          'user', 'user@example.com', 'pass', 'pass');

      expect(result, isNull);
    });
  });

  group('forgotPassword', () {
    test('returns the error message when the user is not found', () async {
      when(() => mockClient.post(
            Uri.parse('${AuthService.baseUrl}password-reset/'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({'error': 'User not found'}),
            404,
          ));

      final result = await authService.forgotPassword('nobody@example.com');

      expect(result, 'User not found');
    });
  });
}
