import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';
import 'package:planning/src/features/scheduling/domain/repositories/scheduling_repository.dart';
import 'package:planning/src/features/scheduling/domain/usecases/get_events_usecase.dart';

class MockSchedulingRepository extends Mock implements SchedulingRepository {}

void main() {
  late GetEventsUseCase usecase;
  late MockSchedulingRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockRepository = MockSchedulingRepository();
    usecase = GetEventsUseCase(mockRepository);
  });

  final testEvents = [
    ScheduleEvent(
      id: 'test-id-1',
      title: 'Test Event 1',
      description: 'Test Description 1',
      startTime: DateTime(2025, 5, 30, 10, 0),
      endTime: DateTime(2025, 5, 30, 11, 0),
      isAllDay: false,
      createdAt: DateTime(2025, 5, 30, 9, 0),
      updatedAt: DateTime(2025, 5, 30, 9, 0),
      syncStatus: CalendarSyncStatus.synced,
    ),
    ScheduleEvent(
      id: 'test-id-2',
      title: 'Test Event 2',
      description: 'Test Description 2',
      startTime: DateTime(2025, 5, 30, 14, 0),
      endTime: DateTime(2025, 5, 30, 15, 0),
      isAllDay: false,
      createdAt: DateTime(2025, 5, 30, 13, 0),
      updatedAt: DateTime(2025, 5, 30, 13, 0),
      syncStatus: CalendarSyncStatus.notSynced,
    ),
  ];

  group('GetEventsUseCase', () {
    test('should get all events successfully when repository call succeeds', () async {
      // Arrange
      when(() => mockRepository.getEvents())
          .thenAnswer((_) async => Right(testEvents));

      // Act
      final result = await usecase(const NoParams());

      // Assert
      expect(result, equals(Right(testEvents)));
      verify(() => mockRepository.getEvents()).called(1);
    });

    test('should return failure when repository call fails', () async {
      // Arrange
      const failure = CacheFailure('Failed to retrieve events');
      when(() => mockRepository.getEvents())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(const NoParams());

      // Assert
      expect(result, equals(const Left(failure)));
      verify(() => mockRepository.getEvents()).called(1);
    });

    test('should return empty list when no events exist', () async {
      // Arrange
      when(() => mockRepository.getEvents())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await usecase(const NoParams());

      // Assert
      expect(result.isRight(), isTrue);
      expect(result.fold((l) => null, (r) => r), equals([]));
      verify(() => mockRepository.getEvents()).called(1);
    });

    test('should handle multiple events with different sync statuses', () async {
      // Arrange
      final mixedEvents = [
        testEvents[0], // synced
        testEvents[1], // not synced
        ScheduleEvent(
          id: 'test-id-3',
          title: 'Syncing Event',
          startTime: DateTime(2025, 5, 30, 16, 0),
          endTime: DateTime(2025, 5, 30, 17, 0),
          isAllDay: false,
          createdAt: DateTime(2025, 5, 30, 15, 0),
          updatedAt: DateTime(2025, 5, 30, 15, 0),
          syncStatus: CalendarSyncStatus.syncing,
        ),
      ];

      when(() => mockRepository.getEvents())
          .thenAnswer((_) async => Right(mixedEvents));

      // Act
      final result = await usecase(const NoParams());

      // Assert
      expect(result, equals(Right(mixedEvents)));
      expect(result.fold((l) => null, (r) => r.length), equals(3));
      verify(() => mockRepository.getEvents()).called(1);
    });

    test('should handle events with all-day flag', () async {
      // Arrange
      final allDayEvent = ScheduleEvent(
        id: 'all-day-1',
        title: 'All Day Event',
        startTime: DateTime(2025, 5, 30),
        endTime: DateTime(2025, 5, 30, 23, 59, 59),
        isAllDay: true,
        createdAt: DateTime(2025, 5, 29),
        updatedAt: DateTime(2025, 5, 29),
        syncStatus: CalendarSyncStatus.synced,
      );

      when(() => mockRepository.getEvents())
          .thenAnswer((_) async => Right([allDayEvent]));

      // Act
      final result = await usecase(const NoParams());

      // Assert
      expect(result.isRight(), isTrue);
      expect(result.fold((l) => null, (r) => r), equals([allDayEvent]));
      final events = result.fold((l) => <ScheduleEvent>[], (r) => r);
      expect(events.first.isAllDay, isTrue);
      verify(() => mockRepository.getEvents()).called(1);
    });
  });

  group('NoParams', () {
    test('should support equality comparison', () {
      // Arrange & Act & Assert
      expect(const NoParams(), equals(const NoParams()));
      expect(const NoParams().hashCode, equals(const NoParams().hashCode));
    });

    test('should have empty props list', () {
      // Arrange & Act & Assert
      expect(const NoParams().props, isEmpty);
    });
  });
}
