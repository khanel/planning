import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planning/src/features/calendar/data/datasources/google_calendar_datasource.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';

// Mock classes for testing
class MockCalendarApi extends Mock implements CalendarApi {}
class MockEventsResource extends Mock implements EventsResource {}
class MockAuthClient extends Mock implements AuthClient {}
class MockEvent extends Mock implements Event {}
class MockEventDateTime extends Mock implements EventDateTime {}

// Fake classes for mocktail fallback values
class FakeEvent extends Fake implements Event {}
class FakeEventDateTime extends Fake implements EventDateTime {}

// Concrete implementation we're testing (will be created in GREEN phase)
class GoogleCalendarDatasourceImpl implements GoogleCalendarDatasource {
  final CalendarApi calendarApi;

  GoogleCalendarDatasourceImpl({required this.calendarApi});

  @override
  Future<List<CalendarEvent>> getEvents({
    required DateTime timeMin,
    required DateTime timeMax,
    String? calendarId,
    int? maxResults,
  }) {
    // This will fail initially (RED phase)
    throw UnimplementedError('getEvents not implemented yet');
  }

  @override
  Future<CalendarEvent> createEvent({
    required CalendarEvent event,
    required String calendarId,
  }) {
    // This will fail initially (RED phase)
    throw UnimplementedError('createEvent not implemented yet');
  }

  @override
  Future<CalendarEvent> updateEvent({
    required CalendarEvent event,
    required String calendarId,
  }) {
    // This will fail initially (RED phase)
    throw UnimplementedError('updateEvent not implemented yet');
  }

  @override
  Future<bool> deleteEvent({
    required String eventId,
    required String calendarId,
  }) {
    // This will fail initially (RED phase)
    throw UnimplementedError('deleteEvent not implemented yet');
  }
}

void main() {
  late GoogleCalendarDatasourceImpl datasource;
  late MockCalendarApi mockCalendarApi;
  late MockEventsResource mockEventsResource;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeEvent());
    registerFallbackValue(FakeEventDateTime());
  });

  setUp(() {
    mockCalendarApi = MockCalendarApi();
    mockEventsResource = MockEventsResource();
    datasource = GoogleCalendarDatasourceImpl(calendarApi: mockCalendarApi);

    // Setup mock relationships
    when(() => mockCalendarApi.events).thenReturn(mockEventsResource);
  });

  group('GoogleCalendarDatasource', () {
    const String testCalendarId = 'test_calendar_id';
    const String testEventId = 'test_event_id';
    
    final testEvent = CalendarEvent(
      id: 'local_id_123',
      title: 'Test Event',
      description: 'Test Description',
      startTime: DateTime(2024, 1, 1, 10, 0),
      endTime: DateTime(2024, 1, 1, 11, 0),
      isAllDay: false,
      calendarId: testCalendarId,
      googleEventId: testEventId,
    );

    group('getEvents', () {
      test('should return list of calendar events from Google Calendar API', () async {
        // Arrange
        final mockGoogleEvent = Event();
        mockGoogleEvent.id = testEventId;
        mockGoogleEvent.summary = 'Test Event';
        mockGoogleEvent.description = 'Test Description';
        
        final mockStartDateTime = EventDateTime();
        mockStartDateTime.dateTime = DateTime(2024, 1, 1, 10, 0);
        mockGoogleEvent.start = mockStartDateTime;
        
        final mockEndDateTime = EventDateTime();
        mockEndDateTime.dateTime = DateTime(2024, 1, 1, 11, 0);
        mockGoogleEvent.end = mockEndDateTime;

        final mockEvents = Events();
        mockEvents.items = [mockGoogleEvent];

        when(() => mockEventsResource.list(
          testCalendarId,
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
          maxResults: any(named: 'maxResults'),
        )).thenAnswer((_) async => mockEvents);

        // Act
        final result = await datasource.getEvents(
          timeMin: DateTime(2024, 1, 1),
          timeMax: DateTime(2024, 1, 2),
          calendarId: testCalendarId,
          maxResults: 100,
        );

        // Assert
        expect(result, isA<List<CalendarEvent>>());
        expect(result.length, equals(1));
        expect(result.first.title, equals('Test Event'));
        expect(result.first.googleEventId, equals(testEventId));
        
        verify(() => mockEventsResource.list(
          testCalendarId,
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
          maxResults: 100,
        )).called(1);
      });

      test('should handle empty response from Google Calendar API', () async {
        // Arrange
        final mockEvents = Events();
        mockEvents.items = [];

        when(() => mockEventsResource.list(
          testCalendarId,
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
        )).thenAnswer((_) async => mockEvents);

        // Act
        final result = await datasource.getEvents(
          timeMin: DateTime(2024, 1, 1),
          timeMax: DateTime(2024, 1, 2),
          calendarId: testCalendarId,
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when Google Calendar API fails', () async {
        // Arrange
        when(() => mockEventsResource.list(
          any(),
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
        )).thenThrow(Exception('API Error'));

        // Act & Assert
        expect(
          () => datasource.getEvents(
            timeMin: DateTime(2024, 1, 1),
            timeMax: DateTime(2024, 1, 2),
            calendarId: testCalendarId,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createEvent', () {
      test('should create event in Google Calendar and return updated CalendarEvent', () async {
        // Arrange
        final mockGoogleEvent = Event();
        mockGoogleEvent.id = testEventId;
        mockGoogleEvent.summary = testEvent.title;
        mockGoogleEvent.description = testEvent.description;
        
        final mockStartDateTime = EventDateTime();
        mockStartDateTime.dateTime = testEvent.startTime;
        mockGoogleEvent.start = mockStartDateTime;
        
        final mockEndDateTime = EventDateTime();
        mockEndDateTime.dateTime = testEvent.endTime;
        mockGoogleEvent.end = mockEndDateTime;

        when(() => mockEventsResource.insert(
          any(),
          testCalendarId,
        )).thenAnswer((_) async => mockGoogleEvent);

        // Act
        final result = await datasource.createEvent(
          event: testEvent,
          calendarId: testCalendarId,
        );

        // Assert
        expect(result, isA<CalendarEvent>());
        expect(result.title, equals(testEvent.title));
        expect(result.googleEventId, equals(testEventId));
        
        verify(() => mockEventsResource.insert(
          any(),
          testCalendarId,
        )).called(1);
      });

      test('should throw exception when Google Calendar API fails to create event', () async {
        // Arrange
        when(() => mockEventsResource.insert(
          any(),
          testCalendarId,
        )).thenThrow(Exception('Create failed'));

        // Act & Assert
        expect(
          () => datasource.createEvent(
            event: testEvent,
            calendarId: testCalendarId,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateEvent', () {
      test('should update event in Google Calendar and return updated CalendarEvent', () async {
        // Arrange
        final mockGoogleEvent = Event();
        mockGoogleEvent.id = testEventId;
        mockGoogleEvent.summary = 'Updated Title';
        mockGoogleEvent.description = 'Updated Description';
        
        final mockStartDateTime = EventDateTime();
        mockStartDateTime.dateTime = testEvent.startTime;
        mockGoogleEvent.start = mockStartDateTime;
        
        final mockEndDateTime = EventDateTime();
        mockEndDateTime.dateTime = testEvent.endTime;
        mockGoogleEvent.end = mockEndDateTime;

        when(() => mockEventsResource.update(
          any(),
          testCalendarId,
          testEventId,
        )).thenAnswer((_) async => mockGoogleEvent);

        // Act
        final updatedEvent = testEvent.copyWith(
          title: 'Updated Title',
          description: 'Updated Description',
        );
        
        final result = await datasource.updateEvent(
          event: updatedEvent,
          calendarId: testCalendarId,
        );

        // Assert
        expect(result, isA<CalendarEvent>());
        expect(result.title, equals('Updated Title'));
        expect(result.googleEventId, equals(testEventId));
        
        verify(() => mockEventsResource.update(
          any(),
          testCalendarId,
          testEventId,
        )).called(1);
      });

      test('should throw exception when Google Calendar API fails to update event', () async {
        // Arrange
        when(() => mockEventsResource.update(
          any(),
          testCalendarId,
          any(),
        )).thenThrow(Exception('Update failed'));

        // Act & Assert
        expect(
          () => datasource.updateEvent(
            event: testEvent,
            calendarId: testCalendarId,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteEvent', () {
      test('should delete event from Google Calendar and return true', () async {
        // Arrange
        when(() => mockEventsResource.delete(
          testCalendarId,
          testEventId,
        )).thenAnswer((_) async {});

        // Act
        final result = await datasource.deleteEvent(
          eventId: testEventId,
          calendarId: testCalendarId,
        );

        // Assert
        expect(result, isTrue);
        
        verify(() => mockEventsResource.delete(
          testCalendarId,
          testEventId,
        )).called(1);
      });

      test('should throw exception when Google Calendar API fails to delete event', () async {
        // Arrange
        when(() => mockEventsResource.delete(
          testCalendarId,
          testEventId,
        )).thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(
          () => datasource.deleteEvent(
            eventId: testEventId,
            calendarId: testCalendarId,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should return false when event not found during deletion', () async {
        // Arrange
        when(() => mockEventsResource.delete(
          testCalendarId,
          testEventId,
        )).thenThrow(Exception('Not found'));

        // Act & Assert
        expect(
          () => datasource.deleteEvent(
            eventId: testEventId,
            calendarId: testCalendarId,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

// Extension to add copyWith method to CalendarEvent for testing
extension CalendarEventCopyWith on CalendarEvent {
  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? calendarId,
    String? googleEventId,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      calendarId: calendarId ?? this.calendarId,
      googleEventId: googleEventId ?? this.googleEventId,
    );
  }
}
