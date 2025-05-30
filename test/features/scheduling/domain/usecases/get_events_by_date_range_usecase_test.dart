import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/repositories/scheduling_repository.dart';
import 'package:planning/src/features/scheduling/domain/usecases/get_events_by_date_range_usecase.dart';

class MockSchedulingRepository extends Mock implements SchedulingRepository {}

void main() {
  late GetEventsByDateRangeUseCase usecase;
  late MockSchedulingRepository mockRepository;

  setUp(() {
    mockRepository = MockSchedulingRepository();
    usecase = GetEventsByDateRangeUseCase(mockRepository);
  });

  final tStartDate = DateTime(2025, 5, 30);
  final tEndDate = DateTime(2025, 6, 5);
  final tParams = GetEventsByDateRangeParams(
    startDate: tStartDate,
    endDate: tEndDate,
  );

  final tEvents = [
    ScheduleEvent(
      id: 'event-1',
      title: 'Event 1',
      description: 'Test event 1',
      startTime: DateTime(2025, 6, 1, 10, 0),
      endTime: DateTime(2025, 6, 1, 11, 0),
      isAllDay: false,
      createdAt: DateTime(2025, 5, 30),
      updatedAt: DateTime(2025, 5, 30),
      syncStatus: CalendarSyncStatus.notSynced,
    ),
    ScheduleEvent(
      id: 'event-2',
      title: 'Event 2',
      description: 'Test event 2',
      startTime: DateTime(2025, 6, 3, 14, 0),
      endTime: DateTime(2025, 6, 3, 15, 0),
      isAllDay: false,
      createdAt: DateTime(2025, 5, 30),
      updatedAt: DateTime(2025, 5, 30),
      syncStatus: CalendarSyncStatus.synced,
    ),
  ];

  group('GetEventsByDateRangeUseCase', () {
    test('should get events in date range via the repository when valid dates are provided', () async {
      // arrange
      when(() => mockRepository.getEventsByDateRange(any(), any()))
          .thenAnswer((_) async => Right(tEvents));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tEvents));
      // Verify that dates are normalized (start of day for start, end of day for end)
      final expectedStartDate = DateTime(2025, 5, 30, 0, 0, 0, 0); // Start of day
      final expectedEndDate = DateTime(2025, 6, 5, 23, 59, 59, 999); // End of day
      verify(() => mockRepository.getEventsByDateRange(expectedStartDate, expectedEndDate));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when repository returns failure', () async {
      // arrange
      const tFailure = CacheFailure('Failed to get events by date range');
      when(() => mockRepository.getEventsByDateRange(any(), any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      // Verify that dates are normalized (start of day for start, end of day for end)
      final expectedStartDate = DateTime(2025, 5, 30, 0, 0, 0, 0); // Start of day
      final expectedEndDate = DateTime(2025, 6, 5, 23, 59, 59, 999); // End of day
      verify(() => mockRepository.getEventsByDateRange(expectedStartDate, expectedEndDate));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no events in date range', () async {
      // arrange
      when(() => mockRepository.getEventsByDateRange(any(), any()))
          .thenAnswer((_) async => const Right(<ScheduleEvent>[]));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right(<ScheduleEvent>[]));
      // Verify that dates are normalized (start of day for start, end of day for end)
      final expectedStartDate = DateTime(2025, 5, 30, 0, 0, 0, 0); // Start of day
      final expectedEndDate = DateTime(2025, 6, 5, 23, 59, 59, 999); // End of day
      verify(() => mockRepository.getEventsByDateRange(expectedStartDate, expectedEndDate));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when start date is after end date', () async {
      // arrange
      final invalidParams = GetEventsByDateRangeParams(
        startDate: DateTime(2025, 6, 5), // After end date
        endDate: DateTime(2025, 5, 30),   // Before start date
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (events) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.getEventsByDateRange(any(), any()));
    });

    test('should handle same start and end date (single day)', () async {
      // arrange
      final sameDate = DateTime(2025, 6, 1);
      final singleDayParams = GetEventsByDateRangeParams(
        startDate: sameDate,
        endDate: sameDate,
      );
      final singleDayEvents = [tEvents.first];

      when(() => mockRepository.getEventsByDateRange(any(), any()))
          .thenAnswer((_) async => Right(singleDayEvents));

      // act
      final result = await usecase(singleDayParams);

      // assert
      expect(result, Right(singleDayEvents));
      final expectedSameDate = DateTime(2025, 6, 1, 0, 0, 0, 0); // Start of day
      final expectedEndOfDay = DateTime(2025, 6, 1, 23, 59, 59, 999); // End of day
      verify(() => mockRepository.getEventsByDateRange(expectedSameDate, expectedEndOfDay));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle network failure gracefully', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockRepository.getEventsByDateRange(any(), any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      // Verify that dates are normalized (start of day for start, end of day for end)
      final expectedStartDate = DateTime(2025, 5, 30, 0, 0, 0, 0); // Start of day
      final expectedEndDate = DateTime(2025, 6, 5, 23, 59, 59, 999); // End of day
      verify(() => mockRepository.getEventsByDateRange(expectedStartDate, expectedEndDate));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should normalize dates to start of day and end of day', () async {
      // arrange
      final startWithTime = DateTime(2025, 6, 1, 15, 30, 45); // Mid-day with time
      final endWithTime = DateTime(2025, 6, 5, 8, 15, 30);    // Morning with time
      final paramsWithTime = GetEventsByDateRangeParams(
        startDate: startWithTime,
        endDate: endWithTime,
      );

      when(() => mockRepository.getEventsByDateRange(any(), any()))
          .thenAnswer((_) async => Right(tEvents));

      // act
      final result = await usecase(paramsWithTime);

      // assert
      expect(result, Right(tEvents));
      
      // Verify that dates are normalized (start of day for start, end of day for end)
      final expectedStartDate = DateTime(2025, 6, 1, 0, 0, 0); // Start of day
      final expectedEndDate = DateTime(2025, 6, 5, 23, 59, 59, 999); // End of day
      
      verify(() => mockRepository.getEventsByDateRange(expectedStartDate, expectedEndDate));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
