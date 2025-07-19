import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:alumni_app/functions/authentication.dart';
import 'dart:convert';

void main() {
  late TestableAuthService authService;

  setUp(() {
    authService = TestableAuthService();
  });

  test('Successful login', () async {
    // 1. Setup mock behavior
    TestableAuthService.mockPostHandler = (Uri url, {headers, body}) async {
      return http.Response(
        jsonEncode({'token': 'test123', 'refresh': 'refresh123'}),
        200,
      );
    };

    var storageCalled = false;
    TestableAuthService.mockStorageWriter = (String key, String value) async {
      if (key == 'auth_token') storageCalled = true;
    };

    // 2. Call the real method with mocked dependencies
    final result = await authService.loginUser('user', 'pass');

    // 3. Verify
    expect(result, isNull);
    expect(storageCalled, isTrue);
  });
}
