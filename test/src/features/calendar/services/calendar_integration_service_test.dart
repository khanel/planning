import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:planning/src/features/calendar/services/calendar_integration_service.dart';

// Mock classes
class MockCalendarRepository extends Mock implements CalendarRepository {}
class MockCalendarApi extends Mock implements calendar.CalendarApi {}

// Fake classes for mocktail fallback values
class FakeCalendarEvent extends Fake implements CalendarEvent {}

void main() {
  group('CalendarIntegrationService - Refactored Tests', () {
    late CalendarIntegrationService service;
    late MockCalendarRepository mockRepository;
    late MockCalendarApi mockCalendarApi;

    setUpAll(() {
      registerFallbackValue(FakeCalendarEvent());
    });

    setUp(() {
      mockRepository = MockCalendarRepository();
      mockCalendarApi = MockCalendarApi();
      service = CalendarIntegrationService(repository: mockRepository);
    });

    group('fromCalendarApi factory constructor', () {
      test('should create service from valid CalendarApi', () {
        // Act
        final result = CalendarIntegrationService.fromCalendarApi(mockCalendarApi);

        // Assert
        expect(result, isA<CalendarIntegrationService>());
      });

      test('should throw TypeError when CalendarApi is null', () {
        // Act & Assert
        expect(
          () => CalendarIntegrationService.fromCalendarApi(null as dynamic),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('createEvent', () {
      test('should delegate to repository and return success', () async {
        // Arrange
        final event = CalendarEvent(
          id: 'test-id',
          title: 'Test Event',
          description: 'Test Description',
          startTime: DateTime(2025, 6, 2, 10, 0),
          endTime: DateTime(2025, 6, 2, 11, 0),
          isAllDay: false,
        );
        when(() => mockRepository.createEvent(
          event: any(named: 'event'),
          calendarId: any(named: 'calendarId'),
        )).thenAnswer((_) async => Right(event));

        // Act
        final result = await service.createEvent(event);

        // Assert
        expect(result, Right(event));
        verify(() => mockRepository.createEvent(
          event: event,
          calendarId: 'primary',
        )).called(1);
      });

      test('should return failure when repository fails', () async {
        // Arrange
        final event = CalendarEvent(
          id: 'test-id',
          title: 'Test Event',
          description: 'Test Description',
          startTime: DateTime(2025, 6, 2, 10, 0),
          endTime: DateTime(2025, 6, 2, 11, 0),
          isAllDay: false,
        );
        const failure = ServerFailure();
        when(() => mockRepository.createEvent(
          event: any(named: 'event'),
          calendarId: any(named: 'calendarId'),
        )).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await service.createEvent(event);

        // Assert
        expect(result, const Left(failure));
      });
    });

    group('getEvents', () {
      test('should delegate to repository with correct parameters', () async {
        // Arrange
        final startTime = DateTime(2025, 6, 2, 0, 0);
        final endTime = DateTime(2025, 6, 2, 23, 59);
        final events = <CalendarEvent>[];
        when(() => mockRepository.getEvents(
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
          calendarId: any(named: 'calendarId'),
          maxResults: any(named: 'maxResults'),
        )).thenAnswer((_) async => Right(events));

        // Act
        final result = await service.getEvents(
          timeMin: startTime,
          timeMax: endTime,
          maxResults: 50,
        );

        // Assert
        expect(result, Right(events));
        verify(() => mockRepository.getEvents(
          timeMin: startTime,
          timeMax: endTime,
          calendarId: 'primary',
          maxResults: 50,
        )).called(1);
      });
    });

    group('updateEvent', () {
      test('should delegate to repository for event updates', () async {
        // Arrange
        final event = CalendarEvent(
          id: 'test-id',
          title: 'Updated Event',
          description: 'Updated Description',
          startTime: DateTime(2025, 6, 2, 10, 0),
          endTime: DateTime(2025, 6, 2, 11, 0),
          isAllDay: false,
        );
        when(() => mockRepository.updateEvent(
          event: any(named: 'event'),
          calendarId: any(named: 'calendarId'),
        )).thenAnswer((_) async => Right(event));

        // Act
        final result = await service.updateEvent(event);

        // Assert
        expect(result, Right(event));
        verify(() => mockRepository.updateEvent(
          event: event,
          calendarId: 'primary',
        )).called(1);
      });
    });

    group('deleteEvent', () {
      test('should delegate to repository for event deletion', () async {
        // Arrange
        const eventId = 'event-to-delete';
        when(() => mockRepository.deleteEvent(
          eventId: any(named: 'eventId'),
          calendarId: any(named: 'calendarId'),
        )).thenAnswer((_) async => const Right(true));

        // Act
        final result = await service.deleteEvent(eventId: eventId);

        // Assert
        expect(result, const Right(true));
        verify(() => mockRepository.deleteEvent(
          eventId: eventId,
          calendarId: 'primary',
        )).called(1);
      });
    });
  });
}
