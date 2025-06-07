import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:planning/src/core/auth/google_auth_service.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/services/core/session_aware_calendar_service.dart';

// Mock classes
class MockGoogleAuthService extends Mock implements GoogleAuthService {}
class MockCalendarApi extends Mock implements calendar.CalendarApi {}

void main() {
  group('SessionAwareCalendarService - Refactored Tests', () {
    late SessionAwareCalendarService service;
    late MockGoogleAuthService mockAuthService;
    late MockCalendarApi mockCalendarApi;

    setUp(() {
      mockAuthService = MockGoogleAuthService();
      mockCalendarApi = MockCalendarApi();
      service = SessionAwareCalendarService(authService: mockAuthService);
    });

    group('session management', () {
      test('should reuse calendar service across multiple operations', () async {
        // Arrange
        when(() => mockAuthService.getCalendarApi())
            .thenAnswer((_) async => Right(mockCalendarApi));

        final startTime = DateTime(2025, 6, 2, 0, 0);
        final endTime = DateTime(2025, 6, 2, 23, 59);

        // Act - First call
        final result1 = await service.getEvents(
          timeMin: startTime,
          timeMax: endTime,
        );

        // Act - Second call (should reuse the same service)
        final result2 = await service.getEvents(
          timeMin: startTime,
          timeMax: endTime,
        );

        // Assert
        expect(result1, isA<Either<Failure, List<CalendarEvent>>>());
        expect(result2, isA<Either<Failure, List<CalendarEvent>>>());
        
        // Verify getCalendarApi was called only once (service was reused)
        verify(() => mockAuthService.getCalendarApi()).called(1);
      });

      test('should clear session and force re-authentication', () async {
        // Arrange
        when(() => mockAuthService.getCalendarApi())
            .thenAnswer((_) async => Right(mockCalendarApi));

        final startTime = DateTime(2025, 6, 2, 0, 0);
        final endTime = DateTime(2025, 6, 2, 23, 59);

        // Act - First call
        await service.getEvents(timeMin: startTime, timeMax: endTime);
        
        // Clear session
        service.clearSession();
        
        // Second call after clearing session
        await service.getEvents(timeMin: startTime, timeMax: endTime);

        // Assert - getCalendarApi should be called twice (once for each session)
        verify(() => mockAuthService.getCalendarApi()).called(2);
      });
    });

    group('error handling', () {
      test('should return AuthFailure when authentication fails', () async {
        // Arrange
        const authFailure = AuthFailure();
        when(() => mockAuthService.getCalendarApi())
            .thenAnswer((_) async => const Left(authFailure));

        final startTime = DateTime(2025, 6, 2, 0, 0);
        final endTime = DateTime(2025, 6, 2, 23, 59);

        // Act
        final result = await service.getEvents(
          timeMin: startTime,
          timeMax: endTime,
        );

        // Assert
        expect(result, const Left(AuthFailure()));
      });

      test('should handle exceptions during calendar service creation', () async {
        // Arrange
        when(() => mockAuthService.getCalendarApi())
            .thenThrow(Exception('Network error'));

        final startTime = DateTime(2025, 6, 2, 0, 0);
        final endTime = DateTime(2025, 6, 2, 23, 59);

        // Act
        final result = await service.getEvents(
          timeMin: startTime,
          timeMax: endTime,
        );

        // Assert
        expect(result, const Left(AuthFailure()));
      });
    });

    group('calendar operations', () {
      setUp(() {
        when(() => mockAuthService.getCalendarApi())
            .thenAnswer((_) async => Right(mockCalendarApi));
      });

      test('should handle createEvent through session-aware service', () async {
        // Arrange
        final event = CalendarEvent(
          id: 'test-id',
          title: 'Test Event',
          description: 'Test Description',
          startTime: DateTime(2025, 6, 2, 10, 0),
          endTime: DateTime(2025, 6, 2, 11, 0),
          isAllDay: false,
        );

        // Act
        final result = await service.createEvent(event);

        // Assert
        expect(result, isA<Either<Failure, CalendarEvent>>());
        verify(() => mockAuthService.getCalendarApi()).called(1);
      });

      test('should handle updateEvent through session-aware service', () async {
        // Arrange
        final event = CalendarEvent(
          id: 'test-id',
          title: 'Updated Event',
          description: 'Updated Description',
          startTime: DateTime(2025, 6, 2, 10, 0),
          endTime: DateTime(2025, 6, 2, 11, 0),
          isAllDay: false,
        );

        // Act
        final result = await service.updateEvent(event);

        // Assert
        expect(result, isA<Either<Failure, CalendarEvent>>());
        verify(() => mockAuthService.getCalendarApi()).called(1);
      });

      test('should handle deleteEvent through session-aware service', () async {
        // Arrange
        const eventId = 'event-to-delete';

        // Act
        final result = await service.deleteEvent(eventId: eventId);

        // Assert
        expect(result, isA<Either<Failure, bool>>());
        verify(() => mockAuthService.getCalendarApi()).called(1);
      });
    });
  });
}
