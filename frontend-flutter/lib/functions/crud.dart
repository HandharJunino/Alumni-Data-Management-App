import 'dart:convert';
import 'package:http/http.dart' as http;
import 'authentication.dart';

class ApiService {
  static const String baseUrl = "https://alumni-data-management-app.onrender.com/api";
  final http.Client _client;
  final Future<String?> Function() _getToken;

  ApiService({http.Client? client, Future<String?> Function()? getToken})
      : _client = client ?? http.Client(),
        _getToken = getToken ?? AuthService().getToken;

  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$baseUrl$path');
    return query == null || query.isEmpty
        ? uri
        : uri.replace(queryParameters: query);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final uri = _uri(path, query);
    final headers = await _getAuthHeaders();
    final encodedBody = body == null ? null : jsonEncode(body);
    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(uri, headers: headers, body: encodedBody);
      case 'PUT':
        return _client.put(uri, headers: headers, body: encodedBody);
      case 'DELETE':
        return _client.delete(uri, headers: headers);
      default:
        throw ArgumentError('Unsupported method: $method');
    }
  }

  dynamic _decode(http.Response response) =>
      response.body.isEmpty ? null : jsonDecode(response.body);

  List<Map<String, dynamic>> _unwrapList(dynamic decoded) {
    if (decoded is Map && decoded.containsKey('results')) {
      // Paginated response
      return List<Map<String, dynamic>>.from(decoded['results']);
    } else if (decoded is List) {
      return List<Map<String, dynamic>>.from(decoded);
    }
    throw Exception('Unexpected response format: ${decoded.runtimeType}');
  }

  Future<Map<String, dynamic>> createAlumni(
      Map<String, dynamic> alumniData) async {
    final response = await _send('POST', '/alumni/', body: alumniData);

    if (response.statusCode == 201) {
      final decoded = _decode(response);
      if (decoded is Map<String, dynamic>) {
        return decoded.containsKey('data') ? decoded['data'] : decoded;
      }
      throw Exception('Invalid response format');
    }

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
  }

  Future<Map<String, dynamic>> updateAlumni(
      int id, Map<String, dynamic> alumniData) async {
    final response = await _send('PUT', '/alumni/$id/', body: alumniData);
    if (response.statusCode == 200) return _decode(response)['data'];
    throw Exception("Failed to update alumni");
  }

  Future<void> deleteAlumni(int id) async {
    final response = await _send('DELETE', '/alumni/$id/');
    if (response.statusCode != 204) {
      throw Exception("Failed to delete alumni");
    }
  }

  // Previous Contacts Operations
  Future<List<Map<String, dynamic>>> getPreviousContacts({
    int? alumniId,
  }) async {
    final response = await _send(
      'GET',
      '/previous-contacts/',
      query: alumniId == null ? null : {'alumni': '$alumniId'},
    );
    if (response.statusCode == 200) return _unwrapList(_decode(response));
    throw Exception("Failed to load contacts");
  }

  Future<Map<String, dynamic>> createContact(
      Map<String, dynamic> contactData) async {
    final response =
        await _send('POST', '/previous-contacts/', body: contactData);
    if (response.statusCode == 201) return _decode(response);
    throw Exception("Failed to create contact");
  }

  // Alumni Event Attendance Operations
  Future<List<Map<String, dynamic>>> getAlumniEvents(int alumniId) async {
    final response = await _send(
      'GET',
      '/alumni-events/',
      query: {'alumni': '$alumniId'},
    );
    if (response.statusCode == 200) return _unwrapList(_decode(response));
    throw Exception("Failed to load attended events");
  }

  Future<Map<String, dynamic>> createAlumniEvent(
      Map<String, dynamic> attendanceData) async {
    final response =
        await _send('POST', '/alumni-events/', body: attendanceData);
    if (response.statusCode == 201) return _decode(response);
    throw Exception("Failed to record attendance");
  }

  // Recommended Alumni Operations
  Future<List<dynamic>> getRecommendedAlumni(int eventId) async {
    final response = await _send(
      'GET',
      '/recommended-alumni/',
      query: {'event_id': '$eventId'},
    );
    if (response.statusCode == 200) return _decode(response);
    throw Exception("Failed to load recommended alumni");
  }

  // Alumni List Operations
  Future<List<Map<String, dynamic>>> getAlumniList({
    String? search,
    Map<String, String>? filters,
    String? ordering,
  }) async {
    final query = <String, String>{
      if (search != null) 'search': search,
      if (ordering != null) 'ordering': ordering,
      ...?filters,
    };
    final response = await _send('GET', '/alumni/', query: query);
    if (response.statusCode == 200) return _unwrapList(_decode(response));
    throw Exception("Failed to load alumni");
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final response = await _send('GET', '/alumni/$userId');
    if (response.statusCode == 200) return _decode(response);
    throw Exception('Failed to load user details');
  }

  // event CRUD Operations
  Future<List<Map<String, dynamic>>> getEventsList({
    String? search,
    Map<String, String>? filters,
    String? ordering,
  }) async {
    final query = <String, String>{
      if (search != null) 'search': search,
      if (ordering != null) 'ordering': ordering,
      ...?filters,
    };
    final response = await _send('GET', '/events/', query: query);
    if (response.statusCode == 200) return _unwrapList(_decode(response));
    throw Exception("Failed to load events");
  }

  // Create a new event
  Future<Map<String, dynamic>> createEvent(
      Map<String, dynamic> eventData) async {
    final response = await _send('POST', '/events/', body: eventData);
    if (response.statusCode == 201) return _decode(response);
    throw Exception("Failed to create event: ${response.body}");
  }

  // Get details of a specific event
  Future<Map<String, dynamic>> getEventDetails(int eventId) async {
    final response = await _send('GET', '/events/$eventId/');
    if (response.statusCode == 200) return _decode(response);
    throw Exception("Failed to load event details");
  }
}
