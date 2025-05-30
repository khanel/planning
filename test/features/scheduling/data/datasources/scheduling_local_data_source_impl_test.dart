import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:planning/src/core/errors/exceptions.dart';
import 'package:planning/src/features/scheduling/data/datasources/scheduling_local_data_source_impl.dart';
import 'package:planning/src/features/scheduling/data/models/schedule_event_data_model.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';

class MockHiveBox extends Mock implements Box<ScheduleEventDataModel> {}

class FakeScheduleEventDataModel extends Fake implements ScheduleEventDataModel {}

void main() {
  late SchedulingLocalDataSourceImpl dataSource;
  late MockHiveBox mockBox;

  setUpAll(() {
    registerFallbackValue(FakeScheduleEventDataModel());
  });

  setUp(() {
    mockBox = MockHiveBox();
    dataSource = SchedulingLocalDataSourceImpl(box: mockBox);
  });

  group('SchedulingLocalDataSourceImpl', () {
    final tScheduleEventDataModel = ScheduleEventDataModel(
      id: 'test-id',
      title: 'Test Event',
      description: 'Test Description',
      startTime: DateTime(2025, 6, 1, 10, 0),
      endTime: DateTime(2025, 6, 1, 11, 0),
      isAllDay: false,
      createdAt: DateTime(2025, 5, 30),
      updatedAt: DateTime(2025, 5, 30),
      syncStatus: CalendarSyncStatus.notSynced,
      linkedTaskId: null,
    );

    final tScheduleEventDataModel2 = ScheduleEventDataModel(
      id: 'test-id-2',
      title: 'Test Event 2',
      description: 'Test Description 2',
      startTime: DateTime(2025, 6, 2, 14, 0),
      endTime: DateTime(2025, 6, 2, 15, 0),
      isAllDay: false,
      createdAt: DateTime(2025, 5, 30),
      updatedAt: DateTime(2025, 5, 30),
      syncStatus: CalendarSyncStatus.synced,
      linkedTaskId: 'task-123',
    );

    group('getEvents', () {
      test('should return all events from Hive box', () async {
        // arrange
        when(() => mockBox.values).thenReturn([tScheduleEventDataModel, tScheduleEventDataModel2]);

        // act
        final result = await dataSource.getEvents();

        // assert
        expect(result, [tScheduleEventDataModel, tScheduleEventDataModel2]);
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });

      test('should return empty list when no events exist', () async {
        // arrange
        when(() => mockBox.values).thenReturn([]);

        // act
        final result = await dataSource.getEvents();

        // assert
        expect(result, isEmpty);
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });

      test('should throw CacheException when Hive operation fails', () async {
        // arrange
        when(() => mockBox.values).thenThrow(Exception('Hive error'));

        // act & assert
        expect(() async => await dataSource.getEvents(), throwsA(isA<CacheException>()));
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });
    });

    group('getEventById', () {
      test('should return event when it exists in Hive box', () async {
        // arrange
        when(() => mockBox.get('test-id')).thenReturn(tScheduleEventDataModel);

        // act
        final result = await dataSource.getEventById('test-id');

        // assert
        expect(result, tScheduleEventDataModel);
        verify(() => mockBox.get('test-id'));
        verifyNoMoreInteractions(mockBox);
      });

      test('should throw CacheException when event does not exist', () async {
        // arrange
        when(() => mockBox.get('nonexistent-id')).thenReturn(null);

        // act & assert
        expect(
          () async => await dataSource.getEventById('nonexistent-id'),
          throwsA(isA<CacheException>()),
        );
        verify(() => mockBox.get('nonexistent-id'));
        verifyNoMoreInteractions(mockBox);
      });

      test('should throw CacheException when Hive operation fails', () async {
        // arrange
        when(() => mockBox.get('test-id')).thenThrow(Exception('Hive error'));

        // act & assert
        expect(
          () async => await dataSource.getEventById('test-id'),
          throwsA(isA<CacheException>()),
        );
        verify(() => mockBox.get('test-id'));
        verifyNoMoreInteractions(mockBox);
      });
    });

    group('saveEvent', () {
      test('should save event to Hive box successfully', () async {
        // arrange
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        // act
        await dataSource.saveEvent(tScheduleEventDataModel);

        // assert
        verify(() => mockBox.put('test-id', tScheduleEventDataModel));
        verifyNoMoreInteractions(mockBox);
      });

      test('should throw CacheException when Hive save operation fails', () async {
        // arrange
        when(() => mockBox.put(any(), any())).thenThrow(Exception('Hive error'));

        // act & assert
        expect(
          () async => await dataSource.saveEvent(tScheduleEventDataModel),
          throwsA(isA<CacheException>()),
        );
        verify(() => mockBox.put('test-id', tScheduleEventDataModel));
        verifyNoMoreInteractions(mockBox);
      });
    });

    group('deleteEvent', () {
      test('should delete event from Hive box successfully when event exists', () async {
        // arrange
        when(() => mockBox.get('test-id')).thenReturn(tScheduleEventDataModel);
        when(() => mockBox.delete('test-id')).thenAnswer((_) async {});

        // act
        await dataSource.deleteEvent('test-id');

        // assert
        verify(() => mockBox.get('test-id'));
        verify(() => mockBox.delete('test-id'));
        verifyNoMoreInteractions(mockBox);
      });

      test('should throw CacheException when event does not exist', () async {
        // arrange
        when(() => mockBox.get('nonexistent-id')).thenReturn(null);

        // act & assert
        expect(
          () async => await dataSource.deleteEvent('nonexistent-id'),
          throwsA(isA<CacheException>()),
        );
        verify(() => mockBox.get('nonexistent-id'));
        verifyNoMoreInteractions(mockBox);
      });

      test('should throw CacheException when Hive delete operation fails', () async {
        // arrange
        when(() => mockBox.get('test-id')).thenReturn(tScheduleEventDataModel);
        when(() => mockBox.delete('test-id')).thenThrow(Exception('Hive error'));

        // act & assert
        expect(
          () async => await dataSource.deleteEvent('test-id'),
          throwsA(isA<CacheException>()),
        );
        verify(() => mockBox.get('test-id'));
        verify(() => mockBox.delete('test-id'));
        verifyNoMoreInteractions(mockBox);
      });
    });

    group('getEventsByDateRange', () {
      test('should return events within date range', () async {
        // arrange
        final startDate = DateTime(2025, 6, 1);
        final endDate = DateTime(2025, 6, 2);
        
        when(() => mockBox.values).thenReturn([tScheduleEventDataModel, tScheduleEventDataModel2]);

        // act
        final result = await dataSource.getEventsByDateRange(startDate, endDate);

        // assert
        expect(result, [tScheduleEventDataModel, tScheduleEventDataModel2]);
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });

      test('should return empty list when no events in date range', () async {
        // arrange
        final startDate = DateTime(2025, 7, 1);
        final endDate = DateTime(2025, 7, 2);
        
        when(() => mockBox.values).thenReturn([tScheduleEventDataModel, tScheduleEventDataModel2]);

        // act
        final result = await dataSource.getEventsByDateRange(startDate, endDate);

        // assert
        expect(result, isEmpty);
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });

      test('should handle all-day events correctly in date range', () async {
        // arrange
        final allDayEvent = ScheduleEventDataModel(
          id: 'all-day-id',
          title: 'All Day Event',
          description: 'All day description',
          startTime: DateTime(2025, 6, 1),
          endTime: DateTime(2025, 6, 1),
          isAllDay: true,
          createdAt: DateTime(2025, 5, 30),
          updatedAt: DateTime(2025, 5, 30),
          syncStatus: CalendarSyncStatus.notSynced,
          linkedTaskId: null,
        );
        
        final startDate = DateTime(2025, 6, 1);
        final endDate = DateTime(2025, 6, 1);
        
        when(() => mockBox.values).thenReturn([allDayEvent]);

        // act
        final result = await dataSource.getEventsByDateRange(startDate, endDate);

        // assert
        expect(result, [allDayEvent]);
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });

      test('should throw CacheException when Hive operation fails', () async {
        // arrange
        final startDate = DateTime(2025, 6, 1);
        final endDate = DateTime(2025, 6, 2);
        
        when(() => mockBox.values).thenThrow(Exception('Hive error'));

        // act & assert
        expect(
          () async => await dataSource.getEventsByDateRange(startDate, endDate),
          throwsA(isA<CacheException>()),
        );
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });
    });

    group('getEventsByTaskId', () {
      test('should return events linked to specific task', () async {
        // arrange
        when(() => mockBox.values).thenReturn([tScheduleEventDataModel, tScheduleEventDataModel2]);

        // act
        final result = await dataSource.getEventsByTaskId('task-123');

        // assert
        expect(result, [tScheduleEventDataModel2]);
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });

      test('should return empty list when no events linked to task', () async {
        // arrange
        when(() => mockBox.values).thenReturn([tScheduleEventDataModel, tScheduleEventDataModel2]);

        // act
        final result = await dataSource.getEventsByTaskId('nonexistent-task');

        // assert
        expect(result, isEmpty);
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });

      test('should return all events with null linkedTaskId when querying for null', () async {
        // arrange
        when(() => mockBox.values).thenReturn([tScheduleEventDataModel, tScheduleEventDataModel2]);

        // act
        final result = await dataSource.getEventsByTaskId('null');

        // assert
        expect(result, [tScheduleEventDataModel]);
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });

      test('should throw CacheException when Hive operation fails', () async {
        // arrange
        when(() => mockBox.values).thenThrow(Exception('Hive error'));

        // act & assert
        expect(
          () async => await dataSource.getEventsByTaskId('task-123'),
          throwsA(isA<CacheException>()),
        );
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });
    });
  });
}
