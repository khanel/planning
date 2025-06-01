import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:planning/src/features/calendar/domain/usecases/get_events.dart';
import 'package:planning/src/core/errors/failures.dart';

// Mock classes
class MockCalendarRepository extends Mock implements CalendarRepository {}

void main() {
  group('GetEvents', () {
    late GetEvents usecase;
    late MockCalendarRepository mockRepository;

    setUp(() {
      mockRepository = MockCalendarRepository();
      usecase = GetEvents(repository: mockRepository);
    });

    final tParams = GetEventsParams(
      calendarId: 'primary',
      timeMin: DateTime(2024, 1, 15),
      timeMax: DateTime(2024, 1, 16),
      maxResults: 100,
    );

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

    test('should get events from the repository', () async {
      // Arrange
      when(() => mockRepository.getEvents(
        calendarId: any(named: 'calendarId'),
        timeMin: any(named: 'timeMin'),
        timeMax: any(named: 'timeMax'),
        maxResults: any(named: 'maxResults'),
      )).thenAnswer((_) async => Right(tCalendarEvents));

      // Act
      final result = await usecase.call(tParams);

      // Assert
      expect(result, Right(tCalendarEvents));
      verify(() => mockRepository.getEvents(
        calendarId: 'primary',
        timeMin: DateTime(2024, 1, 15),
        timeMax: DateTime(2024, 1, 16),
        maxResults: 100,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository call fails', () async {
      // Arrange
      const tFailure = ServerFailure();
      when(() => mockRepository.getEvents(
        calendarId: any(named: 'calendarId'),
        timeMin: any(named: 'timeMin'),
        timeMax: any(named: 'timeMax'),
        maxResults: any(named: 'maxResults'),
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase.call(tParams);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.getEvents(
        calendarId: 'primary',
        timeMin: DateTime(2024, 1, 15),
        timeMax: DateTime(2024, 1, 16),
        maxResults: 100,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
