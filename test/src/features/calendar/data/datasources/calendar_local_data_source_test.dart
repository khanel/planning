import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';
import 'package:planning/src/core/errors/exceptions.dart';
import 'package:planning/src/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:planning/src/features/calendar/data/datasources/calendar_local_data_source_impl.dart';
import 'package:planning/src/features/calendar/data/models/calendar_event_data_model.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';

class MockBox extends Mock implements Box<CalendarEventDataModel> {}

void main() {
  late CalendarLocalDataSource dataSource;
  late MockBox mockBox;

  final tCalendarEventDataModel = CalendarEventDataModel(
    id: 'test-event-id',
    title: 'Test Calendar Event',
    description: 'Test Description',
    startTime: DateTime(2025, 6, 4, 10, 0),
    endTime: DateTime(2025, 6, 4, 11, 0),
    isAllDay: false,
    calendarId: 'primary',
    googleEventId: 'google-event-123',
    syncStatus: CalendarSyncStatus.synced,
    lastModified: DateTime(2025, 6, 4, 9, 0),
  );

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(tCalendarEventDataModel);
  });

  setUp(() {
    mockBox = MockBox();
    dataSource = CalendarLocalDataSourceImpl(box: mockBox);
  });

  group('CalendarLocalDataSourceImpl', () {
    group('getEvents', () {
      test('should return all calendar events from Hive box', () async {
        // arrange
        when(() => mockBox.values).thenReturn([tCalendarEventDataModel]);

        // act
        final result = await dataSource.getEvents();

        // assert
        expect(result, [tCalendarEventDataModel]);
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
      test('should return calendar event when it exists in Hive box', () async {
        // arrange
        when(() => mockBox.get('test-event-id')).thenReturn(tCalendarEventDataModel);

        // act
        final result = await dataSource.getEventById('test-event-id');

        // assert
        expect(result, tCalendarEventDataModel);
        verify(() => mockBox.get('test-event-id'));
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
        when(() => mockBox.get('test-event-id')).thenThrow(Exception('Hive error'));

        // act & assert
        expect(
          () async => await dataSource.getEventById('test-event-id'),
          throwsA(isA<CacheException>()),
        );
        verify(() => mockBox.get('test-event-id'));
        verifyNoMoreInteractions(mockBox);
      });
    });

    group('saveEvent', () {
      test('should save calendar event to Hive box successfully', () async {
        // arrange
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        // act
        await dataSource.saveEvent(tCalendarEventDataModel);

        // assert
        verify(() => mockBox.put('test-event-id', tCalendarEventDataModel));
        verifyNoMoreInteractions(mockBox);
      });

      test('should throw CacheException when Hive save operation fails', () async {
        // arrange
        when(() => mockBox.put(any(), any())).thenThrow(Exception('Hive error'));

        // act & assert
        expect(
          () async => await dataSource.saveEvent(tCalendarEventDataModel),
          throwsA(isA<CacheException>()),
        );
        verify(() => mockBox.put('test-event-id', tCalendarEventDataModel));
        verifyNoMoreInteractions(mockBox);
      });
    });

    group('deleteEvent', () {
      test('should delete calendar event from Hive box successfully when event exists', () async {
        // arrange
        when(() => mockBox.get('test-event-id')).thenReturn(tCalendarEventDataModel);
        when(() => mockBox.delete('test-event-id')).thenAnswer((_) async {});

        // act
        await dataSource.deleteEvent('test-event-id');

        // assert
        verify(() => mockBox.get('test-event-id'));
        verify(() => mockBox.delete('test-event-id'));
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
        when(() => mockBox.get('test-event-id')).thenReturn(tCalendarEventDataModel);
        when(() => mockBox.delete('test-event-id')).thenThrow(Exception('Hive error'));

        // act & assert
        expect(
          () async => await dataSource.deleteEvent('test-event-id'),
          throwsA(isA<CacheException>()),
        );
        verify(() => mockBox.get('test-event-id'));
        verify(() => mockBox.delete('test-event-id'));
        verifyNoMoreInteractions(mockBox);
      });
    });

    group('getEventsByDateRange', () {
      test('should return calendar events within date range', () async {
        // arrange
        final startDate = DateTime(2025, 6, 4);
        final endDate = DateTime(2025, 6, 5);
        final eventInRange = CalendarEventDataModel(
          id: 'event-in-range',
          title: 'Event In Range',
          description: 'Within date range',
          startTime: DateTime(2025, 6, 4, 10, 0),
          endTime: DateTime(2025, 6, 4, 11, 0),
          isAllDay: false,
          calendarId: 'primary',
          syncStatus: CalendarSyncStatus.synced,
          lastModified: DateTime(2025, 6, 4, 9, 0),
        );
        final eventOutOfRange = CalendarEventDataModel(
          id: 'event-out-of-range',
          title: 'Event Out of Range',
          description: 'Outside date range',
          startTime: DateTime(2025, 6, 6, 10, 0),
          endTime: DateTime(2025, 6, 6, 11, 0),
          isAllDay: false,
          calendarId: 'primary',
          syncStatus: CalendarSyncStatus.synced,
          lastModified: DateTime(2025, 6, 6, 9, 0),
        );

        when(() => mockBox.values).thenReturn([eventInRange, eventOutOfRange]);

        // act
        final result = await dataSource.getEventsByDateRange(startDate, endDate);

        // assert
        expect(result, [eventInRange]);
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });

      test('should return empty list when no events in date range', () async {
        // arrange
        final startDate = DateTime(2025, 6, 4);
        final endDate = DateTime(2025, 6, 5);
        
        when(() => mockBox.values).thenReturn([]);

        // act
        final result = await dataSource.getEventsByDateRange(startDate, endDate);

        // assert
        expect(result, isEmpty);
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });

      test('should handle all-day events correctly', () async {
        // arrange
        final startDate = DateTime(2025, 6, 4);
        final endDate = DateTime(2025, 6, 5);
        final allDayEvent = CalendarEventDataModel(
          id: 'all-day-event',
          title: 'All Day Event',
          description: 'All day event',
          startTime: DateTime(2025, 6, 4),
          endTime: DateTime(2025, 6, 4, 23, 59, 59),
          isAllDay: true,
          calendarId: 'primary',
          syncStatus: CalendarSyncStatus.synced,
          lastModified: DateTime(2025, 6, 4, 9, 0),
        );

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
        final startDate = DateTime(2025, 6, 4);
        final endDate = DateTime(2025, 6, 5);
        
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

    group('getEventsBySyncStatus', () {
      test('should return events with specific sync status', () async {
        // arrange
        final syncedEvent = CalendarEventDataModel(
          id: 'synced-event',
          title: 'Synced Event',
          description: 'Already synced',
          startTime: DateTime(2025, 6, 4, 10, 0),
          endTime: DateTime(2025, 6, 4, 11, 0),
          isAllDay: false,
          calendarId: 'primary',
          syncStatus: CalendarSyncStatus.synced,
          lastModified: DateTime(2025, 6, 4, 9, 0),
        );
        final pendingEvent = CalendarEventDataModel(
          id: 'pending-event',
          title: 'Pending Event',
          description: 'Pending sync',
          startTime: DateTime(2025, 6, 4, 12, 0),
          endTime: DateTime(2025, 6, 4, 13, 0),
          isAllDay: false,
          calendarId: 'primary',
          syncStatus: CalendarSyncStatus.notSynced,
          lastModified: DateTime(2025, 6, 4, 11, 0),
        );

        when(() => mockBox.values).thenReturn([syncedEvent, pendingEvent]);

        // act
        final result = await dataSource.getEventsBySyncStatus(CalendarSyncStatus.synced);

        // assert
        expect(result, [syncedEvent]);
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });

      test('should return empty list when no events with requested sync status', () async {
        // arrange
        when(() => mockBox.values).thenReturn([tCalendarEventDataModel]);

        // act
        final result = await dataSource.getEventsBySyncStatus(CalendarSyncStatus.notSynced);

        // assert
        expect(result, isEmpty);
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });

      test('should throw CacheException when Hive operation fails', () async {
        // arrange
        when(() => mockBox.values).thenThrow(Exception('Hive error'));

        // act & assert
        expect(
          () async => await dataSource.getEventsBySyncStatus(CalendarSyncStatus.synced),
          throwsA(isA<CacheException>()),
        );
        verify(() => mockBox.values);
        verifyNoMoreInteractions(mockBox);
      });
    });

    group('clearCache', () {
      test('should clear all events from Hive box', () async {
        // arrange
        when(() => mockBox.clear()).thenAnswer((_) async => 0);

        // act
        await dataSource.clearCache();

        // assert
        verify(() => mockBox.clear());
        verifyNoMoreInteractions(mockBox);
      });

      test('should throw CacheException when Hive clear operation fails', () async {
        // arrange
        when(() => mockBox.clear()).thenThrow(Exception('Hive error'));

        // act & assert
        expect(
          () async => await dataSource.clearCache(),
          throwsA(isA<CacheException>()),
        );
        verify(() => mockBox.clear());
        verifyNoMoreInteractions(mockBox);
      });
    });
  });
}
