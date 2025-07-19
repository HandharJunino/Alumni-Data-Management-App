import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockClient extends Mock implements http.Client {}

class MockStorage extends Mock implements FlutterSecureStorage {}

// Test configuration
void setupTestFallbacks() {
  registerFallbackValue(Uri.parse('http://example.com'));
  registerFallbackValue(<String, String>{});
}
