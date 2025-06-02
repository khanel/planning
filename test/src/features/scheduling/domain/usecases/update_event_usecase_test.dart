import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/repositories/scheduling_repository.dart';
import 'package:planning/src/features/scheduling/domain/usecases/update_event_usecase.dart';

// Create a fake ScheduleEvent class for registerFallbackValue
class FakeScheduleEvent extends Fake implements ScheduleEvent {}

class MockSchedulingRepository extends Mock implements SchedulingRepository {}

void main() {
  late UpdateEventUseCase usecase;
  late MockSchedulingRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeScheduleEvent());
  });

  setUp(() {
    mockRepository = MockSchedulingRepository();
    usecase = UpdateEventUseCase(mockRepository);
  });

  final now = DateTime.now();
  final tEvent = ScheduleEvent(
    id: 'test-event-1',
    title: 'Updated Test Event',
    description: 'Updated test description',
    startTime: DateTime(2025, 5, 30, 10, 0),
    endTime: DateTime(2025, 5, 30, 11, 0),
    isAllDay: false,
    createdAt: now,
    updatedAt: now,
    syncStatus: CalendarSyncStatus.synced,
    googleCalendarId: 'google-cal-123',
    linkedTaskId: 'task-456',
  );

  final tParams = UpdateEventParams(event: tEvent);

  group('UpdateEventUseCase', () {
    test('should update event via the repository when valid event is provided', () async {
      // arrange
      when(() => mockRepository.updateEvent(any()))
          .thenAnswer((_) async => Right(tEvent));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tEvent));
      verify(() => mockRepository.updateEvent(tEvent));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when repository returns failure', () async {
      // arrange
      const tFailure = CacheFailure('Update failed');
      when(() => mockRepository.updateEvent(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.updateEvent(tEvent));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure for event with empty title', () async {
      // arrange
      final invalidEvent = ScheduleEvent(
        id: 'test-event-1',
        title: '', // Empty title should cause validation failure
        description: 'Test description',
        startTime: DateTime(2025, 5, 30, 10, 0),
        endTime: DateTime(2025, 5, 30, 11, 0),
        isAllDay: false,
        createdAt: now,
        updatedAt: now,
        syncStatus: CalendarSyncStatus.notSynced,
      );
      final invalidParams = UpdateEventParams(event: invalidEvent);

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (event) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.updateEvent(any()));
    });

    test('should return ValidationFailure for event with start time after end time', () async {
      // arrange
      final invalidEvent = ScheduleEvent(
        id: 'test-event-1',
        title: 'Test Event',
        description: 'Test description',
        startTime: DateTime(2025, 5, 30, 12, 0), // After end time
        endTime: DateTime(2025, 5, 30, 11, 0),   // Before start time
        isAllDay: false,
        createdAt: now,
        updatedAt: now,
        syncStatus: CalendarSyncStatus.notSynced,
      );
      final invalidParams = UpdateEventParams(event: invalidEvent);

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (event) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.updateEvent(any()));
    });

    test('should return ValidationFailure for event with empty id', () async {
      // arrange
      final invalidEvent = ScheduleEvent(
        id: '', // Empty id should cause validation failure
        title: 'Test Event',
        description: 'Test description',
        startTime: DateTime(2025, 5, 30, 10, 0),
        endTime: DateTime(2025, 5, 30, 11, 0),
        isAllDay: false,
        createdAt: now,
        updatedAt: now,
        syncStatus: CalendarSyncStatus.notSynced,
      );
      final invalidParams = UpdateEventParams(event: invalidEvent);

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (event) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.updateEvent(any()));
    });

    test('should pass validation for all-day event without checking time order', () async {
      // arrange
      final allDayEvent = ScheduleEvent(
        id: 'test-event-1',
        title: 'All Day Event',
        description: 'Test description',
        startTime: DateTime(2025, 5, 30, 12, 0), // This would be invalid for non-all-day
        endTime: DateTime(2025, 5, 30, 11, 0),   // This would be invalid for non-all-day
        isAllDay: true, // All-day events don't need to follow time order validation
        createdAt: now,
        updatedAt: now,
        syncStatus: CalendarSyncStatus.notSynced,
      );
      final validParams = UpdateEventParams(event: allDayEvent);
      
      when(() => mockRepository.updateEvent(any()))
          .thenAnswer((_) async => Right(allDayEvent));

      // act
      final result = await usecase(validParams);

      // assert
      expect(result, Right(allDayEvent));
      verify(() => mockRepository.updateEvent(allDayEvent));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle network failure gracefully', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockRepository.updateEvent(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.updateEvent(tEvent));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
