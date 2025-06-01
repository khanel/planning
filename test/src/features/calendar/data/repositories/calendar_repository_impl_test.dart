import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:planning/src/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:planning/src/features/calendar/data/datasources/google_calendar_datasource.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/errors/exceptions.dart';

// Mock classes
class MockGoogleCalendarDatasource extends Mock implements GoogleCalendarDatasource {}

void main() {
  group('CalendarRepositoryImpl', () {
    late CalendarRepository repository;
    late MockGoogleCalendarDatasource mockDatasource;

    setUp(() {
      mockDatasource = MockGoogleCalendarDatasource();
      repository = CalendarRepositoryImpl(datasource: mockDatasource);
    });

    group('getEvents', () {
      final tCalendarEvents = [
        CalendarEvent(
          id: '1',
          title: 'Test Event 1',
          description: 'Test Description',
          startTime: DateTime(2024, 1, 15, 10, 0),
          endTime: DateTime(2024, 1, 15, 11, 0),
          isAllDay: false,
        ),
        CalendarEvent(
          id: '2',
          title: 'Test Event 2',
          description: 'Test Description 2',
          startTime: DateTime(2024, 1, 16, 14, 0),
          endTime: DateTime(2024, 1, 16, 15, 0),
          isAllDay: false,
        ),
      ];

      test('should return list of CalendarEvent when call to datasource is successful', () async {
        // Arrange
        when(() => mockDatasource.getEvents(
          calendarId: any(named: 'calendarId'),
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
          maxResults: any(named: 'maxResults'),
        )).thenAnswer((_) async => tCalendarEvents);

        // Act
        final result = await repository.getEvents(
          calendarId: 'primary',
          timeMin: DateTime(2024, 1, 15),
          timeMax: DateTime(2024, 1, 16),
          maxResults: 100,
        );

        // Assert
        expect(result, isA<Right<Failure, List<CalendarEvent>>>());
        expect(result.fold((l) => null, (r) => r), tCalendarEvents);
        verify(() => mockDatasource.getEvents(
          calendarId: 'primary',
          timeMin: DateTime(2024, 1, 15),
          timeMax: DateTime(2024, 1, 16),
          maxResults: 100,
        )).called(1);
      });

      test('should return ServerFailure when call to datasource fails', () async {
        // Arrange
        when(() => mockDatasource.getEvents(
          calendarId: any(named: 'calendarId'),
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
          maxResults: any(named: 'maxResults'),
        )).thenThrow(const ServerException('API Error'));

        // Act
        final result = await repository.getEvents(
          calendarId: 'primary',
          timeMin: DateTime(2024, 1, 15),
          timeMax: DateTime(2024, 1, 16),
          maxResults: 100,
        );

        // Assert
        expect(result, isA<Left<Failure, List<CalendarEvent>>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
      });

      test('should return AuthFailure when authentication fails', () async {
        // Arrange
        when(() => mockDatasource.getEvents(
          calendarId: any(named: 'calendarId'),
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
          maxResults: any(named: 'maxResults'),
        )).thenThrow(const AuthException('Token expired'));

        // Act
        final result = await repository.getEvents(
          calendarId: 'primary',
          timeMin: DateTime(2024, 1, 15),
          timeMax: DateTime(2024, 1, 16),
          maxResults: 100,
        );

        // Assert
        expect(result, isA<Left<Failure, List<CalendarEvent>>>());
        expect(result.fold((l) => l, (r) => null), isA<AuthFailure>());
      });
    });

    group('createEvent', () {
      final tCalendarEvent = CalendarEvent(
        id: '1',
        title: 'New Test Event',
        description: 'New Test Description',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 11, 0),
        isAllDay: false,
      );

      test('should return CalendarEvent when event creation is successful', () async {
        // Arrange
        when(() => mockDatasource.createEvent(
          event: any(named: 'event'),
          calendarId: any(named: 'calendarId'),
        )).thenAnswer((_) async => tCalendarEvent);

        // Act
        final result = await repository.createEvent(
          event: tCalendarEvent,
          calendarId: 'primary',
        );

        // Assert
        expect(result, isA<Right<Failure, CalendarEvent>>());
        expect(result.fold((l) => null, (r) => r), tCalendarEvent);
        verify(() => mockDatasource.createEvent(
          event: tCalendarEvent,
          calendarId: 'primary',
        )).called(1);
      });

      test('should return ServerFailure when event creation fails', () async {
        // Arrange
        when(() => mockDatasource.createEvent(
          event: any(named: 'event'),
          calendarId: any(named: 'calendarId'),
        )).thenThrow(const ServerException('Creation failed'));

        // Act
        final result = await repository.createEvent(
          event: tCalendarEvent,
          calendarId: 'primary',
        );

        // Assert
        expect(result, isA<Left<Failure, CalendarEvent>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
      });
    });

    group('updateEvent', () {
      final tCalendarEvent = CalendarEvent(
        id: '1',
        title: 'Updated Test Event',
        description: 'Updated Test Description',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 11, 0),
        isAllDay: false,
      );

      test('should return CalendarEvent when event update is successful', () async {
        // Arrange
        when(() => mockDatasource.updateEvent(
          event: any(named: 'event'),
          calendarId: any(named: 'calendarId'),
        )).thenAnswer((_) async => tCalendarEvent);

        // Act
        final result = await repository.updateEvent(
          event: tCalendarEvent,
          calendarId: 'primary',
        );

        // Assert
        expect(result, isA<Right<Failure, CalendarEvent>>());
        expect(result.fold((l) => null, (r) => r), tCalendarEvent);
        verify(() => mockDatasource.updateEvent(
          event: tCalendarEvent,
          calendarId: 'primary',
        )).called(1);
      });

      test('should return ServerFailure when event update fails', () async {
        // Arrange
        when(() => mockDatasource.updateEvent(
          event: any(named: 'event'),
          calendarId: any(named: 'calendarId'),
        )).thenThrow(const ServerException('Update failed'));

        // Act
        final result = await repository.updateEvent(
          event: tCalendarEvent,
          calendarId: 'primary',
        );

        // Assert
        expect(result, isA<Left<Failure, CalendarEvent>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
      });
    });

    group('deleteEvent', () {
      test('should return true when event deletion is successful', () async {
        // Arrange
        when(() => mockDatasource.deleteEvent(
          eventId: any(named: 'eventId'),
          calendarId: any(named: 'calendarId'),
        )).thenAnswer((_) async => true);

        // Act
        final result = await repository.deleteEvent(
          eventId: '1',
          calendarId: 'primary',
        );

        // Assert
        expect(result, isA<Right<Failure, bool>>());
        expect(result.fold((l) => null, (r) => r), true);
        verify(() => mockDatasource.deleteEvent(
          eventId: '1',
          calendarId: 'primary',
        )).called(1);
      });

      test('should return ServerFailure when event deletion fails', () async {
        // Arrange
        when(() => mockDatasource.deleteEvent(
          eventId: any(named: 'eventId'),
          calendarId: any(named: 'calendarId'),
        )).thenThrow(const ServerException('Deletion failed'));

        // Act
        final result = await repository.deleteEvent(
          eventId: '1',
          calendarId: 'primary',
        );

        // Assert
        expect(result, isA<Left<Failure, bool>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
      });
    });
  });
}
