import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alumni_app/functions/crud.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late ApiService apiService;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://example.com'));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    apiService = ApiService(
      client: mockHttpClient,
      getToken: () async => 'test-token',
    );
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

      when(() => mockHttpClient.post(
            Uri.parse('${ApiService.baseUrl}/alumni/'),
            headers: any(named: 'headers'),
            body: jsonEncode(alumniData),
          )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseJson), 201));

      final result = await apiService.createAlumni(alumniData);

      expect(result, responseJson);
    });

    test('updateAlumni should return updated alumni data on success', () async {
      final alumniData = {'name': 'Jane Doe'};
      final responseJson = {
        'message': 'Alumni updated successfully',
        'data': {'id': 1, 'name': 'Jane Doe'},
      };

      when(() => mockHttpClient.put(
            Uri.parse('${ApiService.baseUrl}/alumni/1/'),
            headers: any(named: 'headers'),
            body: jsonEncode(alumniData),
          )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseJson), 200));

      final result = await apiService.updateAlumni(1, alumniData);

      expect(result, {'id': 1, 'name': 'Jane Doe'});
    });

    test('getUserDetails should return alumni details on success', () async {
      final responseJson = {'id': 1, 'name': 'John Doe'};

      when(() => mockHttpClient.get(
            Uri.parse('${ApiService.baseUrl}/alumni/1'),
            headers: any(named: 'headers'),
          )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseJson), 200));

      final result = await apiService.getUserDetails('1');

      expect(result, responseJson);
    });

    test('getAlumniList should return a list of alumni on success', () async {
      final responseJson = [
        {'id': 1, 'name': 'John Doe'},
        {'id': 2, 'name': 'Jane Doe'},
      ];

      when(() => mockHttpClient.get(
            Uri.parse('${ApiService.baseUrl}/alumni/'),
            headers: any(named: 'headers'),
          )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseJson), 200));

      final result = await apiService.getAlumniList();

      expect(result, responseJson);
    });

    test('getAlumniList should unwrap a paginated response', () async {
      final responseJson = {
        'count': 1,
        'next': null,
        'previous': null,
        'results': [
          {'id': 1, 'name': 'John Doe'},
        ],
      };

      when(() => mockHttpClient.get(
            Uri.parse('${ApiService.baseUrl}/alumni/'),
            headers: any(named: 'headers'),
          )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseJson), 200));

      final result = await apiService.getAlumniList();

      expect(result, [
        {'id': 1, 'name': 'John Doe'},
      ]);
    });

    test('deleteAlumni should complete without throwing an exception',
        () async {
      when(() => mockHttpClient.delete(
            Uri.parse('${ApiService.baseUrl}/alumni/1/'),
            headers: any(named: 'headers'),
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

      when(() => mockHttpClient.post(
            Uri.parse('${ApiService.baseUrl}/events/'),
            headers: any(named: 'headers'),
            body: jsonEncode(eventData),
          )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseJson), 201));

      final result = await apiService.createEvent(eventData);

      expect(result, responseJson);
    });

    test('getEventsList should return a list of events on success', () async {
      final responseJson = [
        {'id': 1, 'name': 'Tech Conference'},
        {'id': 2, 'name': 'AI Summit'},
      ];

      when(() => mockHttpClient.get(
            Uri.parse('${ApiService.baseUrl}/events/'),
            headers: any(named: 'headers'),
          )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseJson), 200));

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

      when(() => mockHttpClient.get(
            Uri.parse('${ApiService.baseUrl}/events/1/'),
            headers: any(named: 'headers'),
          )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseJson), 200));

      final result = await apiService.getEventDetails(1);

      expect(result, responseJson);
    });
  });

  group('Previous Contact Operations', () {
    test('getPreviousContacts should filter by alumni and return a list',
        () async {
      final responseJson = [
        {'id': 1, 'alumni': 5, 'mode_of_contact': 'Email'},
      ];

      when(() => mockHttpClient.get(
            Uri.parse('${ApiService.baseUrl}/previous-contacts/')
                .replace(queryParameters: {'alumni': '5'}),
            headers: any(named: 'headers'),
          )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseJson), 200));

      final result = await apiService.getPreviousContacts(alumniId: 5);

      expect(result, responseJson);
    });

    test('createContact should return created contact data on success',
        () async {
      final contactData = {
        'alumni': 5,
        'date': '2025-01-01',
        'mode_of_contact': 'Phone',
        'description': 'Discussed mentorship',
      };
      final responseJson = {'id': 1, ...contactData};

      when(() => mockHttpClient.post(
            Uri.parse('${ApiService.baseUrl}/previous-contacts/'),
            headers: any(named: 'headers'),
            body: jsonEncode(contactData),
          )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseJson), 201));

      final result = await apiService.createContact(contactData);

      expect(result, responseJson);
    });
  });

  group('Alumni Event Attendance Operations', () {
    test('getAlumniEvents should filter by alumni and return a list',
        () async {
      final responseJson = [
        {
          'id': 1,
          'alumni': 5,
          'event': 2,
          'event_detail': {'id': 2, 'name': 'Tech Conference'},
        },
      ];

      when(() => mockHttpClient.get(
            Uri.parse('${ApiService.baseUrl}/alumni-events/')
                .replace(queryParameters: {'alumni': '5'}),
            headers: any(named: 'headers'),
          )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseJson), 200));

      final result = await apiService.getAlumniEvents(5);

      expect(result, responseJson);
    });

    test('createAlumniEvent should return created attendance data on success',
        () async {
      final attendanceData = {
        'alumni': 5,
        'event': 2,
        'attendance_status': true,
        'attended_on': '2025-01-01T00:00:00.000',
      };
      final responseJson = {'id': 1, ...attendanceData};

      when(() => mockHttpClient.post(
            Uri.parse('${ApiService.baseUrl}/alumni-events/'),
            headers: any(named: 'headers'),
            body: jsonEncode(attendanceData),
          )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseJson), 201));

      final result = await apiService.createAlumniEvent(attendanceData);

      expect(result, responseJson);
    });
  });
}
