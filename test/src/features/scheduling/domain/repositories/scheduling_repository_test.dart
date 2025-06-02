import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';
import 'package:planning/src/features/scheduling/domain/repositories/scheduling_repository.dart';

class MockSchedulingRepository extends Mock implements SchedulingRepository {}

void main() {
  group('SchedulingRepository Interface', () {
    late MockSchedulingRepository mockRepository;
    late ScheduleEvent testEvent;
    final DateTime now = DateTime.now();
    final DateTime startTime = now.add(const Duration(hours: 1));
    final DateTime endTime = now.add(const Duration(hours: 2));

    setUp(() {
      mockRepository = MockSchedulingRepository();
      testEvent = ScheduleEvent(
        id: 'event-1',
        title: 'Team Meeting',
        description: 'Weekly team standup',
        startTime: startTime,
        endTime: endTime,
        isAllDay: false,
        createdAt: now,
        updatedAt: now,
        syncStatus: CalendarSyncStatus.notSynced,
      );
    });

    group('createEvent', () {
      test('should return Right(ScheduleEvent) when event is created successfully', () async {
        // arrange
        when(() => mockRepository.createEvent(testEvent))
            .thenAnswer((_) async => Right(testEvent));

        // act
        final result = await mockRepository.createEvent(testEvent);

        // assert
        expect(result, Right(testEvent));
        verify(() => mockRepository.createEvent(testEvent)).called(1);
      });

      test('should return Left(CacheFailure) when creation fails', () async {
        // arrange
        when(() => mockRepository.createEvent(testEvent))
            .thenAnswer((_) async => Left(CacheFailure()));

        // act
        final result = await mockRepository.createEvent(testEvent);

        // assert
        expect(result, Left(CacheFailure()));
        verify(() => mockRepository.createEvent(testEvent)).called(1);
      });
    });

    group('getEvents', () {
      test('should return Right(List<ScheduleEvent>) when events are retrieved successfully', () async {
        // arrange
        final events = [testEvent];
        when(() => mockRepository.getEvents())
            .thenAnswer((_) async => Right(events));

        // act
        final result = await mockRepository.getEvents();

        // assert
        expect(result, Right(events));
        verify(() => mockRepository.getEvents()).called(1);
      });

      test('should return Left(CacheFailure) when retrieval fails', () async {
        // arrange
        when(() => mockRepository.getEvents())
            .thenAnswer((_) async => Left(CacheFailure()));

        // act
        final result = await mockRepository.getEvents();

        // assert
        expect(result, Left(CacheFailure()));
        verify(() => mockRepository.getEvents()).called(1);
      });

      test('should return Right(empty list) when no events exist', () async {
        // arrange
        when(() => mockRepository.getEvents())
            .thenAnswer((_) async => const Right<Failure, List<ScheduleEvent>>([]));

        // act
        final result = await mockRepository.getEvents();

        // assert
        expect(result, const Right<Failure, List<ScheduleEvent>>([]));
        verify(() => mockRepository.getEvents()).called(1);
      });
    });

    group('getEventById', () {
      test('should return Right(ScheduleEvent) when event is found', () async {
        // arrange
        when(() => mockRepository.getEventById('event-1'))
            .thenAnswer((_) async => Right(testEvent));

        // act
        final result = await mockRepository.getEventById('event-1');

        // assert
        expect(result, Right(testEvent));
        verify(() => mockRepository.getEventById('event-1')).called(1);
      });

      test('should return Left(CacheFailure) when event is not found', () async {
        // arrange
        when(() => mockRepository.getEventById('non-existent'))
            .thenAnswer((_) async => Left(CacheFailure()));

        // act
        final result = await mockRepository.getEventById('non-existent');

        // assert
        expect(result, Left(CacheFailure()));
        verify(() => mockRepository.getEventById('non-existent')).called(1);
      });
    });

    group('updateEvent', () {
      test('should return Right(ScheduleEvent) when event is updated successfully', () async {
        // arrange
        final updatedEvent = testEvent.copyWith(title: 'Updated Meeting');
        when(() => mockRepository.updateEvent(updatedEvent))
            .thenAnswer((_) async => Right(updatedEvent));

        // act
        final result = await mockRepository.updateEvent(updatedEvent);

        // assert
        expect(result, Right(updatedEvent));
        verify(() => mockRepository.updateEvent(updatedEvent)).called(1);
      });

      test('should return Left(CacheFailure) when update fails', () async {
        // arrange
        when(() => mockRepository.updateEvent(testEvent))
            .thenAnswer((_) async => Left(CacheFailure()));

        // act
        final result = await mockRepository.updateEvent(testEvent);

        // assert
        expect(result, Left(CacheFailure()));
        verify(() => mockRepository.updateEvent(testEvent)).called(1);
      });
    });

    group('deleteEvent', () {
      test('should return Right(void) when event is deleted successfully', () async {
        // arrange
        when(() => mockRepository.deleteEvent('event-1'))
            .thenAnswer((_) async => const Right(null));

        // act
        final result = await mockRepository.deleteEvent('event-1');

        // assert
        expect(result, const Right(null));
        verify(() => mockRepository.deleteEvent('event-1')).called(1);
      });

      test('should return Left(CacheFailure) when deletion fails', () async {
        // arrange
        when(() => mockRepository.deleteEvent('event-1'))
            .thenAnswer((_) async => Left(CacheFailure()));

        // act
        final result = await mockRepository.deleteEvent('event-1');

        // assert
        expect(result, Left(CacheFailure()));
        verify(() => mockRepository.deleteEvent('event-1')).called(1);
      });
    });

    group('getEventsByDateRange', () {
      test('should return Right(List<ScheduleEvent>) when events in date range are found', () async {
        // arrange
        final startDate = DateTime(2025, 5, 29);
        final endDate = DateTime(2025, 5, 30);
        final events = [testEvent];
        when(() => mockRepository.getEventsByDateRange(startDate, endDate))
            .thenAnswer((_) async => Right(events));

        // act
        final result = await mockRepository.getEventsByDateRange(startDate, endDate);

        // assert
        expect(result, Right(events));
        verify(() => mockRepository.getEventsByDateRange(startDate, endDate)).called(1);
      });

      test('should return Right(empty list) when no events in date range', () async {
        // arrange
        final startDate = DateTime(2025, 6, 1);
        final endDate = DateTime(2025, 6, 2);
        when(() => mockRepository.getEventsByDateRange(startDate, endDate))
            .thenAnswer((_) async => const Right<Failure, List<ScheduleEvent>>([]));

        // act
        final result = await mockRepository.getEventsByDateRange(startDate, endDate);

        // assert
        expect(result, const Right<Failure, List<ScheduleEvent>>([]));
        verify(() => mockRepository.getEventsByDateRange(startDate, endDate)).called(1);
      });
    });

    group('getEventsByTaskId', () {
      test('should return Right(List<ScheduleEvent>) when events linked to task are found', () async {
        // arrange
        final taskLinkedEvent = testEvent.copyWith(linkedTaskId: 'task-123');
        final events = [taskLinkedEvent];
        when(() => mockRepository.getEventsByTaskId('task-123'))
            .thenAnswer((_) async => Right(events));

        // act
        final result = await mockRepository.getEventsByTaskId('task-123');

        // assert
        expect(result, Right(events));
        verify(() => mockRepository.getEventsByTaskId('task-123')).called(1);
      });

      test('should return Right(empty list) when no events linked to task', () async {
        // arrange
        when(() => mockRepository.getEventsByTaskId('task-456'))
            .thenAnswer((_) async => const Right<Failure, List<ScheduleEvent>>([]));

        // act
        final result = await mockRepository.getEventsByTaskId('task-456');

        // assert
        expect(result, const Right<Failure, List<ScheduleEvent>>([]));
        verify(() => mockRepository.getEventsByTaskId('task-456')).called(1);
      });
    });
  });
}
