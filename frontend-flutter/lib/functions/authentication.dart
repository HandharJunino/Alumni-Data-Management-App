import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000/api/";
  final storage = FlutterSecureStorage();

  /// ** Register User with Error Handling **
  Future<String?> registerUser(
      String username, String email, String password, String password2) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}register/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username, // Use email as username
          "email": email,
          "password": password,
          "password2": password2, // Confirm password
        }),
      );

      if (response.statusCode == 201) {
        return null; // Registration successful (No error message)
      } else {
        final data = jsonDecode(response.body);
        return data['error'] ??
            "Registration failed! ${data['error'] ?? data}"; // Return API error message
      }
    } catch (e) {
      return "Failed to fetch: ${e.toString()}";
    }
  }

  /// ** Login User & Get Token **
  Future<String?> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}login/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: "auth_token", value: data['token']);
        await storage.write(key: "refresh_token", value: data['refresh']);
        return null; // Login successful (No error message)
      } else {
        final data = jsonDecode(response.body);
        return data['detail'] ?? "Login failed!"; // Return API error message
      }
    } catch (e) {
      return "Failed to fetch: ${e.toString()}";
    }
  }

  /// ** Logout (Delete Token) **
  Future<void> logout() async {
    await storage.delete(key: "auth_token");
  }

  /// ** Get Token from Storage **
  Future<String?> getToken() async {
    return await storage.read(key: "auth_token");
  }

  /// ** Check if User is Logged In **
  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }

  /// ** Forgot Password **
  Future<String?> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('${baseUrl}password-reset/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
      }),
    );

    if (response.statusCode == 200) {
      return null; // Email sent successfully (No error message)
    } else {
      final data = jsonDecode(response.body);
      return data['error'] ?? "Failed to send email!";
    }
  }
}

class TestableAuthService extends AuthService {
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body}) {
    // Implement mock behavior here
    return mockPostHandler(url, headers: headers, body: body);
  }

  static Future<http.Response> Function(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) mockPostHandler =
      (Uri url, {Map<String, String>? headers, Object? body}) async {
    // Default implementation forwards to real service
    return http.Client().post(url, headers: headers, body: body);
  };

  Future<void> writeSecureStorage(String key, String value) async {
    // Implement mock storage here
    return mockStorageWriter(key, value);
  }

  static Future<void> Function(String key, String value) mockStorageWriter =
      (String key, String value) async {
    // Default implementation uses real storage
    return const FlutterSecureStorage().write(key: key, value: value);
  };
}
