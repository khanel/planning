import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planning/src/core/errors/exceptions.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/scheduling/data/datasources/scheduling_local_data_source.dart';
import 'package:planning/src/features/scheduling/data/models/schedule_event_data_model.dart';
import 'package:planning/src/features/scheduling/data/repositories/scheduling_repository_impl.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';

class MockSchedulingLocalDataSource extends Mock implements SchedulingLocalDataSource {}

class FakeScheduleEventDataModel extends Fake implements ScheduleEventDataModel {}

void main() {
  group('SchedulingRepositoryImpl', () {
    late SchedulingRepositoryImpl repository;
    late MockSchedulingLocalDataSource mockLocalDataSource;
    late ScheduleEvent testEvent;
    late ScheduleEventDataModel testEventDataModel;
    
    final DateTime now = DateTime.now();
    final DateTime startTime = now.add(const Duration(hours: 1));
    final DateTime endTime = now.add(const Duration(hours: 2));

    setUpAll(() {
      registerFallbackValue(FakeScheduleEventDataModel());
    });

    setUp(() {
      mockLocalDataSource = MockSchedulingLocalDataSource();
      repository = SchedulingRepositoryImpl(localDataSource: mockLocalDataSource);
      
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

      testEventDataModel = ScheduleEventDataModel(
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
        when(() => mockLocalDataSource.saveEvent(any()))
            .thenAnswer((_) async {});

        // act
        final result = await repository.createEvent(testEvent);

        // assert
        expect(result, Right(testEvent));
        verify(() => mockLocalDataSource.saveEvent(any())).called(1);
      });

      test('should return Left(CacheFailure) when data source throws CacheException', () async {
        // arrange
        when(() => mockLocalDataSource.saveEvent(any()))
            .thenThrow(CacheException());

        // act
        final result = await repository.createEvent(testEvent);

        // assert
        expect(result, Left(CacheFailure('Failed to create schedule event')));
        verify(() => mockLocalDataSource.saveEvent(any())).called(1);
      });
    });

    group('getEvents', () {
      test('should return Right(List<ScheduleEvent>) when events are retrieved successfully', () async {
        // arrange
        final eventDataModels = [testEventDataModel];
        when(() => mockLocalDataSource.getEvents())
            .thenAnswer((_) async => eventDataModels);

        // act
        final result = await repository.getEvents();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (events) {
            expect(events.length, 1);
            expect(events.first.id, testEvent.id);
            expect(events.first.title, testEvent.title);
          },
        );
        verify(() => mockLocalDataSource.getEvents()).called(1);
      });

      test('should return Left(CacheFailure) when data source throws CacheException', () async {
        // arrange
        when(() => mockLocalDataSource.getEvents())
            .thenThrow(CacheException());

        // act
        final result = await repository.getEvents();

        // assert
        expect(result, Left(CacheFailure('Failed to retrieve schedule events')));
        verify(() => mockLocalDataSource.getEvents()).called(1);
      });

      test('should return Right(empty list) when no events exist', () async {
        // arrange
        when(() => mockLocalDataSource.getEvents())
            .thenAnswer((_) async => []);

        // act
        final result = await repository.getEvents();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (events) => expect(events, isEmpty),
        );
        verify(() => mockLocalDataSource.getEvents()).called(1);
      });
    });

    group('getEventById', () {
      test('should return Right(ScheduleEvent) when event is found', () async {
        // arrange
        when(() => mockLocalDataSource.getEventById('event-1'))
            .thenAnswer((_) async => testEventDataModel);

        // act
        final result = await repository.getEventById('event-1');

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (event) {
            expect(event.id, testEvent.id);
            expect(event.title, testEvent.title);
          },
        );
        verify(() => mockLocalDataSource.getEventById('event-1')).called(1);
      });

      test('should return Left(CacheFailure) when event is not found', () async {
        // arrange
        when(() => mockLocalDataSource.getEventById('non-existent'))
            .thenThrow(CacheException());

        // act
        final result = await repository.getEventById('non-existent');

        // assert
        expect(result, Left(CacheFailure('Failed to retrieve schedule event by id')));
        verify(() => mockLocalDataSource.getEventById('non-existent')).called(1);
      });
    });

    group('updateEvent', () {
      test('should return Right(ScheduleEvent) when event is updated successfully', () async {
        // arrange
        final updatedEvent = testEvent.copyWith(title: 'Updated Meeting');
        when(() => mockLocalDataSource.saveEvent(any()))
            .thenAnswer((_) async {});

        // act
        final result = await repository.updateEvent(updatedEvent);

        // assert
        expect(result, Right(updatedEvent));
        verify(() => mockLocalDataSource.saveEvent(any())).called(1);
      });

      test('should return Left(CacheFailure) when data source throws CacheException', () async {
        // arrange
        when(() => mockLocalDataSource.saveEvent(any()))
            .thenThrow(CacheException());

        // act
        final result = await repository.updateEvent(testEvent);

        // assert
        expect(result, Left(CacheFailure('Failed to update schedule event')));
        verify(() => mockLocalDataSource.saveEvent(any())).called(1);
      });
    });

    group('deleteEvent', () {
      test('should return Right(void) when event is deleted successfully', () async {
        // arrange
        when(() => mockLocalDataSource.deleteEvent('event-1'))
            .thenAnswer((_) async {});

        // act
        final result = await repository.deleteEvent('event-1');

        // assert
        expect(result, const Right(null));
        verify(() => mockLocalDataSource.deleteEvent('event-1')).called(1);
      });

      test('should return Left(CacheFailure) when data source throws CacheException', () async {
        // arrange
        when(() => mockLocalDataSource.deleteEvent('event-1'))
            .thenThrow(CacheException());

        // act
        final result = await repository.deleteEvent('event-1');

        // assert
        expect(result, Left(CacheFailure('Failed to delete schedule event')));
        verify(() => mockLocalDataSource.deleteEvent('event-1')).called(1);
      });
    });

    group('getEventsByDateRange', () {
      test('should return Right(List<ScheduleEvent>) when events in date range are found', () async {
        // arrange
        final startDate = DateTime(2025, 5, 29);
        final endDate = DateTime(2025, 5, 30);
        final eventDataModels = [testEventDataModel];
        when(() => mockLocalDataSource.getEventsByDateRange(startDate, endDate))
            .thenAnswer((_) async => eventDataModels);

        // act
        final result = await repository.getEventsByDateRange(startDate, endDate);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (events) {
            expect(events.length, 1);
            expect(events.first.id, testEvent.id);
          },
        );
        verify(() => mockLocalDataSource.getEventsByDateRange(startDate, endDate)).called(1);
      });

      test('should return Left(CacheFailure) when data source throws CacheException', () async {
        // arrange
        final startDate = DateTime(2025, 5, 29);
        final endDate = DateTime(2025, 5, 30);
        when(() => mockLocalDataSource.getEventsByDateRange(startDate, endDate))
            .thenThrow(CacheException());

        // act
        final result = await repository.getEventsByDateRange(startDate, endDate);

        // assert
        expect(result, Left(CacheFailure('Failed to retrieve events by date range')));
        verify(() => mockLocalDataSource.getEventsByDateRange(startDate, endDate)).called(1);
      });
    });

    group('getEventsByTaskId', () {
      test('should return Right(List<ScheduleEvent>) when events linked to task are found', () async {
        // arrange
        final taskLinkedEvent = testEventDataModel.copyWith(linkedTaskId: 'task-123');
        final List<ScheduleEventDataModel> eventDataModels = [taskLinkedEvent];
        when(() => mockLocalDataSource.getEventsByTaskId('task-123'))
            .thenAnswer((_) async => eventDataModels);

        // act
        final result = await repository.getEventsByTaskId('task-123');

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (events) {
            expect(events.length, 1);
            expect(events.first.linkedTaskId, 'task-123');
          },
        );
        verify(() => mockLocalDataSource.getEventsByTaskId('task-123')).called(1);
      });

      test('should return Left(CacheFailure) when data source throws CacheException', () async {
        // arrange
        when(() => mockLocalDataSource.getEventsByTaskId('task-123'))
            .thenThrow(CacheException());

        // act
        final result = await repository.getEventsByTaskId('task-123');

        // assert
        expect(result, Left(CacheFailure('Failed to retrieve events by task id')));
        verify(() => mockLocalDataSource.getEventsByTaskId('task-123')).called(1);
      });
    });
  });
}
