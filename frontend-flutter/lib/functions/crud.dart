import 'dart:convert';
import 'package:http/http.dart' as http;
import 'authentication.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";
  final AuthService authService = AuthService();

  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await authService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // Alumni CRUD Operations old
  /*Future<List<dynamic>> getAlumniList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/alumni/'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to load alumni");
  }*/

  Future<Map<String, dynamic>> createAlumni(
      Map<String, dynamic> alumniData) async {
    try {
      print('Creating alumni with data: $alumniData'); // Debug print

      final response = await http.post(
        Uri.parse('$baseUrl/alumni/'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(alumniData),
      );

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 201) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse is Map<String, dynamic>) {
          // Return the whole response if there's no 'data' key
          return decodedResponse.containsKey('data')
              ? decodedResponse['data']
              : decodedResponse;
        }
        throw Exception('Invalid response format');
      }

      // Handle specific error cases
      switch (response.statusCode) {
        case 400:
          throw Exception('Invalid data: ${response.body}');
        case 401:
          throw Exception('Unauthorized: Please log in again');
        case 403:
          throw Exception('Permission denied');
        default:
          throw Exception('Failed to create alumni: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating alumni: $e'); // Debug print
      throw Exception('Failed to create alumni: $e');
    }
  }

  Future<Map<String, dynamic>> updateAlumni(
      int id, Map<String, dynamic> alumniData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/alumni/$id/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode(alumniData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception("Failed to update alumni");
  }

  Future<void> deleteAlumni(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/alumni/$id/'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception("Failed to delete alumni");
    }
  }

  // Previous Contacts Operations
  Future<List<dynamic>> getPreviousContacts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/previous-contacts/'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to load contacts");
  }

  Future<Map<String, dynamic>> createContact(
      Map<String, dynamic> contactData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/previous-contacts/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode(contactData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to create contact");
  }

  // Recommended Alumni Operations
  Future<List<dynamic>> getRecommendedAlumni(int eventId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recommended-alumni/?event_id=$eventId'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to load recommended alumni");
  }

  // Alumni List Operations
  Future<List<Map<String, dynamic>>> getAlumniList({
    String? search,
    Map<String, String>? filters,
    String? ordering,
  }) async {
    // Build query parameters
    final queryParams = <String, String>{};
    if (search != null) queryParams['search'] = search;
    if (ordering != null) queryParams['ordering'] = ordering;
    if (filters != null) queryParams.addAll(filters);

    final uri =
        Uri.parse('$baseUrl/alumni/').replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final dynamic decodedResponse = jsonDecode(response.body);

      if (decodedResponse is Map && decodedResponse.containsKey('results')) {
        // Handle paginated response
        return List<Map<String, dynamic>>.from(decodedResponse['results']);
      } else if (decodedResponse is List) {
        // Handle direct list response
        return List<Map<String, dynamic>>.from(decodedResponse);
      } else {
        throw Exception(
            'Unexpected response format: ${decodedResponse.runtimeType}');
      }
    }
    throw Exception("Failed to load alumni");
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alumni/$userId'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      throw Exception('Error fetching user details: $e');
    }
  }

  // event CRUD Operations
  Future<List<Map<String, dynamic>>> getEventsList({
    String? search,
    Map<String, String>? filters,
    String? ordering,
  }) async {
    // Build query parameters
    final queryParams = <String, String>{};
    if (search != null) queryParams['search'] = search;
    if (ordering != null) queryParams['ordering'] = ordering;
    if (filters != null) queryParams.addAll(filters);

    final uri =
        Uri.parse('$baseUrl/events/').replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final dynamic decodedResponse = jsonDecode(response.body);

      if (decodedResponse is Map && decodedResponse.containsKey('results')) {
        // Handle paginated response
        return List<Map<String, dynamic>>.from(decodedResponse['results']);
      } else if (decodedResponse is List) {
        // Handle direct list response
        return List<Map<String, dynamic>>.from(decodedResponse);
      } else {
        throw Exception(
            'Unexpected response format: ${decodedResponse.runtimeType}');
      }
    }
    throw Exception("Failed to load events");
  }

  // Create a new event
  Future<Map<String, dynamic>> createEvent(
      Map<String, dynamic> eventData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events/'),
      headers: await _getAuthHeaders(),
      body: jsonEncode(eventData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create event: ${response.body}");
    }
  }

  // Get details of a specific event
  Future<Map<String, dynamic>> getEventDetails(int eventId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events/$eventId/'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load event details");
    }
  }
}
