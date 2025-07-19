import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:alumni_app/functions/crud.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late ApiService apiService;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    apiService = ApiService();
  });

  group('Alumni CRUD Operations', () {
    test('createAlumni should return created alumni data on success', () async {
      final alumniData = {
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'phone': '1234567890',
      };

      final responseJson = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'phone': '1234567890',
      };

      when(mockHttpClient.post(
        Uri.parse('${ApiService.baseUrl}/alumni/'),
        headers: anyNamed('headers'),
        body: jsonEncode(alumniData),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseJson), 201));

      final result = await apiService.createAlumni(alumniData);

      expect(result, responseJson);
    });

    test('getAlumniList should return a list of alumni on success', () async {
      final responseJson = [
        {'id': 1, 'name': 'John Doe'},
        {'id': 2, 'name': 'Jane Doe'},
      ];

      when(mockHttpClient.get(
        Uri.parse('${ApiService.baseUrl}/alumni/'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseJson), 200));

      final result = await apiService.getAlumniList();

      expect(result, responseJson);
    });

    test('deleteAlumni should complete without throwing an exception',
        () async {
      when(mockHttpClient.delete(
        Uri.parse('${ApiService.baseUrl}/alumni/1/'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('', 204));

      expect(apiService.deleteAlumni(1), completes);
    });
  });

  group('Event CRUD Operations', () {
    test('createEvent should return created event data on success', () async {
      final eventData = {
        'name': 'Tech Conference',
        'date': '2025-05-01',
        'location': 'New York',
      };

      final responseJson = {
        'id': 1,
        'name': 'Tech Conference',
        'date': '2025-05-01',
        'location': 'New York',
      };

      when(mockHttpClient.post(
        Uri.parse('${ApiService.baseUrl}/events/'),
        headers: anyNamed('headers'),
        body: jsonEncode(eventData),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseJson), 201));

      final result = await apiService.createEvent(eventData);

      expect(result, responseJson);
    });

    test('getEventsList should return a list of events on success', () async {
      final responseJson = [
        {'id': 1, 'name': 'Tech Conference'},
        {'id': 2, 'name': 'AI Summit'},
      ];

      when(mockHttpClient.get(
        Uri.parse('${ApiService.baseUrl}/events/'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseJson), 200));

      final result = await apiService.getEventsList();

      expect(result, responseJson);
    });

    test('getEventDetails should return event details on success', () async {
      final responseJson = {
        'id': 1,
        'name': 'Tech Conference',
        'date': '2025-05-01',
        'location': 'New York',
      };

      when(mockHttpClient.get(
        Uri.parse('${ApiService.baseUrl}/events/1/'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseJson), 200));

      final result = await apiService.getEventDetails(1);

      expect(result, responseJson);
    });
  });
}
