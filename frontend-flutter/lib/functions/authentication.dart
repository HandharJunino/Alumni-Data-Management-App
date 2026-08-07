import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = "https://alumni-data-management-app.onrender.com/api/";
  final http.Client _client;
  final FlutterSecureStorage storage;

  AuthService({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        storage = storage ?? const FlutterSecureStorage();

  Future<http.Response> _post(String path, Map<String, dynamic> body) {
    return _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  /// ** Register User with Error Handling **
  Future<String?> registerUser(
      String username, String email, String password, String password2) async {
    try {
      final response = await _post('register/', {
        "username": username, // Use email as username
        "email": email,
        "password": password,
        "password2": password2, // Confirm password
      });

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
      final response = await _post('login/', {
        "username": username,
        "password": password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: "auth_token", value: data['token']);
        await storage.write(key: "refresh_token", value: data['refresh']);
        return null; // Login successful (No error message)
      } else {
        final data = jsonDecode(response.body);
        // The backend returns errors under 'error', not 'detail' -
        // checking 'detail' first meant real error messages never surfaced.
        return data['error'] ?? data['detail'] ?? "Login failed!";
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
    final response = await _post('password-reset/', {"email": email});

    if (response.statusCode == 200) {
      return null; // Email sent successfully (No error message)
    } else {
      final data = jsonDecode(response.body);
      return data['error'] ?? "Failed to send email!";
    }
  }
}
