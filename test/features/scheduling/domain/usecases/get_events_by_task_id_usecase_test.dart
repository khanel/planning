import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/repositories/scheduling_repository.dart';
import 'package:planning/src/features/scheduling/domain/usecases/get_events_by_task_id_usecase.dart';

class MockSchedulingRepository extends Mock implements SchedulingRepository {}

void main() {
  late GetEventsByTaskIdUseCase usecase;
  late MockSchedulingRepository mockRepository;

  setUp(() {
    mockRepository = MockSchedulingRepository();
    usecase = GetEventsByTaskIdUseCase(mockRepository);
  });

  const tTaskId = 'task-123';
  const tParams = GetEventsByTaskIdParams(taskId: tTaskId);

  final tLinkedEvents = [
    ScheduleEvent(
      id: 'event-1',
      title: 'Meeting for Task',
      description: 'Scheduled meeting for the task',
      startTime: DateTime(2025, 6, 1, 10, 0),
      endTime: DateTime(2025, 6, 1, 11, 0),
      isAllDay: false,
      createdAt: DateTime(2025, 5, 30),
      updatedAt: DateTime(2025, 5, 30),
      syncStatus: CalendarSyncStatus.synced,
      linkedTaskId: tTaskId,
    ),
    ScheduleEvent(
      id: 'event-2',
      title: 'Follow-up for Task',
      description: 'Follow-up meeting for the task',
      startTime: DateTime(2025, 6, 3, 14, 0),
      endTime: DateTime(2025, 6, 3, 15, 0),
      isAllDay: false,
      createdAt: DateTime(2025, 5, 30),
      updatedAt: DateTime(2025, 5, 30),
      syncStatus: CalendarSyncStatus.notSynced,
      linkedTaskId: tTaskId,
    ),
  ];

  group('GetEventsByTaskIdUseCase', () {
    test('should get events linked to task via the repository when valid task ID is provided', () async {
      // arrange
      when(() => mockRepository.getEventsByTaskId(any()))
          .thenAnswer((_) async => Right(tLinkedEvents));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tLinkedEvents));
      verify(() => mockRepository.getEventsByTaskId(tTaskId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when repository returns failure', () async {
      // arrange
      const tFailure = CacheFailure('Failed to get events by task ID');
      when(() => mockRepository.getEventsByTaskId(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.getEventsByTaskId(tTaskId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no events are linked to task', () async {
      // arrange
      when(() => mockRepository.getEventsByTaskId(any()))
          .thenAnswer((_) async => const Right(<ScheduleEvent>[]));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right(<ScheduleEvent>[]));
      verify(() => mockRepository.getEventsByTaskId(tTaskId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure for empty task ID', () async {
      // arrange
      const invalidParams = GetEventsByTaskIdParams(taskId: '');

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (events) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.getEventsByTaskId(any()));
    });

    test('should return ValidationFailure for whitespace-only task ID', () async {
      // arrange
      const invalidParams = GetEventsByTaskIdParams(taskId: '   ');

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (events) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.getEventsByTaskId(any()));
    });

    test('should handle network failure gracefully', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockRepository.getEventsByTaskId(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.getEventsByTaskId(tTaskId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should trim taskId before validation', () async {
      // arrange
      const paramsWithSpaces = GetEventsByTaskIdParams(taskId: '  task-123  ');
      when(() => mockRepository.getEventsByTaskId(any()))
          .thenAnswer((_) async => Right(tLinkedEvents));

      // act
      final result = await usecase(paramsWithSpaces);

      // assert
      expect(result, Right(tLinkedEvents));
      verify(() => mockRepository.getEventsByTaskId('task-123')); // Should be trimmed
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle single linked event correctly', () async {
      // arrange
      final singleEvent = [tLinkedEvents.first];
      when(() => mockRepository.getEventsByTaskId(any()))
          .thenAnswer((_) async => Right(singleEvent));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(singleEvent));
      verify(() => mockRepository.getEventsByTaskId(tTaskId));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
