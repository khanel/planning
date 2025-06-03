import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:planning/src/features/calendar/services/calendar_offline_sync_service.dart';
import 'package:planning/src/features/calendar/services/calendar_sync_service.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/domain/enums/conflict_resolution_strategy.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/network/network_info.dart';

// Mock classes
class MockCalendarSyncService extends Mock implements CalendarSyncService {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  group('CalendarOfflineSyncService - RED PHASE - Failing Tests for Offline Support', () {
    late CalendarOfflineSyncService offlineService;
    late MockCalendarSyncService mockSyncService;
    late MockNetworkInfo mockNetworkInfo;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(CalendarEvent(
        id: 'test-id',
        title: 'Test Event',
        description: 'Test Description',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        isAllDay: false,
      ));
    });

    setUp(() {
      mockSyncService = MockCalendarSyncService();
      mockNetworkInfo = MockNetworkInfo();
      
      // This will FAIL initially as the service doesn't exist yet
      offlineService = CalendarOfflineSyncService(
        syncService: mockSyncService,
        networkInfo: mockNetworkInfo,
      );
    });

    group('Network State Management', () {
      test('should detect network connectivity status', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

        // Act
        final isOnline = await offlineService.isNetworkAvailable();

        // Assert - This should FAIL initially as service doesn't exist
        expect(isOnline, true);
        verify(() => mockNetworkInfo.isConnected).called(1);
      });

      test('should handle offline state gracefully', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final isOnline = await offlineService.isNetworkAvailable();

        // Assert - This should FAIL initially as service doesn't exist
        expect(isOnline, false);
      });
    });

    group('Local Event Caching', () {
      test('should cache events locally when syncing online', () async {
        // Arrange
        final testEvents = [
          CalendarEvent(
            id: 'event-1',
            title: 'Cached Event',
            description: 'Event for caching',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            isAllDay: false,
          ),
        ];

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockSyncService.syncEvents())
            .thenAnswer((_) async => Right(testEvents));

        // Act
        final result = await offlineService.syncWithCaching();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Right<Failure, List<CalendarEvent>>>());
        final events = result.fold((l) => null, (r) => r);
        expect(events, isNotNull);
        expect(events!.length, 1);
        expect(events.first.title, 'Cached Event');
      });

      test('should retrieve cached events when offline', () async {
        // Arrange
        final cachedEvent = CalendarEvent(
          id: 'cached-1',
          title: 'Offline Event',
          description: 'Cached event for offline access',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        
        // First cache the event (this would happen when online)
        await offlineService.cacheEvent(cachedEvent);

        // Act
        final result = await offlineService.getCachedEvents();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Right<Failure, List<CalendarEvent>>>());
        final events = result.fold((l) => null, (r) => r);
        expect(events, isNotNull);
        expect(events!.length, 1);
        expect(events.first.title, 'Offline Event');
      });

      test('should clear cached events when requested', () async {
        // Arrange
        final cachedEvent = CalendarEvent(
          id: 'to-clear',
          title: 'Event to Clear',
          description: 'Will be cleared',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        await offlineService.cacheEvent(cachedEvent);

        // Act
        await offlineService.clearCache();
        final result = await offlineService.getCachedEvents();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Right<Failure, List<CalendarEvent>>>());
        final events = result.fold((l) => null, (r) => r);
        expect(events, isNotNull);
        expect(events!.length, 0);
      });
    });

    group('Offline Actions Queue', () {
      test('should queue create action when offline', () async {
        // Arrange
        final newEvent = CalendarEvent(
          id: 'new-event',
          title: 'New Offline Event',
          description: 'Created while offline',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await offlineService.createEventOffline(newEvent);

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Right<Failure, bool>>());
        expect(result.fold((l) => false, (r) => r), true);
      });

      test('should queue update action when offline', () async {
        // Arrange
        final updatedEvent = CalendarEvent(
          id: 'update-event',
          title: 'Updated Offline Event',
          description: 'Updated while offline',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await offlineService.updateEventOffline(updatedEvent);

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Right<Failure, bool>>());
        expect(result.fold((l) => false, (r) => r), true);
      });

      test('should queue delete action when offline', () async {
        // Arrange
        const eventId = 'delete-event-id';
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await offlineService.deleteEventOffline(eventId);

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Right<Failure, bool>>());
        expect(result.fold((l) => false, (r) => r), true);
      });

      test('should get pending offline actions count', () async {
        // Arrange
        final newEvent = CalendarEvent(
          id: 'pending-1',
          title: 'Pending Event',
          description: 'Waiting for sync',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        await offlineService.createEventOffline(newEvent);

        // Act
        final pendingCount = await offlineService.getPendingActionsCount();

        // Assert - This should FAIL initially as service doesn't exist
        expect(pendingCount, 1);
      });
    });

    group('Conflict Resolution', () {
      test('should detect sync conflicts when both local and remote changes exist', () async {
        // Arrange
        final localEvent = CalendarEvent(
          id: 'conflict-event',
          title: 'Local Version',
          description: 'Changed locally',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        final remoteEvent = CalendarEvent(
          id: 'conflict-event',
          title: 'Remote Version',
          description: 'Changed remotely',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        // Act
        final hasConflict = await offlineService.detectConflict(localEvent, remoteEvent);

        // Assert - This should FAIL initially as service doesn't exist
        expect(hasConflict, true);
      });

      test('should resolve conflicts using last-write-wins strategy', () async {
        // Arrange
        final localEvent = CalendarEvent(
          id: 'resolve-event',
          title: 'Local Version',
          description: 'Changed locally at 10:00',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        final remoteEvent = CalendarEvent(
          id: 'resolve-event',
          title: 'Remote Version',
          description: 'Changed remotely at 11:00',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        // Act
        final resolvedEvent = await offlineService.resolveConflict(
          localEvent, 
          remoteEvent,
          ConflictResolutionStrategy.lastWriteWins,
        );

        // Assert - This should FAIL initially as service doesn't exist
        expect(resolvedEvent.title, 'Remote Version'); // Assuming remote is newer
      });

      test('should allow manual conflict resolution', () async {
        // Arrange
        final localEvent = CalendarEvent(
          id: 'manual-resolve',
          title: 'Local Version',
          description: 'Choose manually',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        final remoteEvent = CalendarEvent(
          id: 'manual-resolve',
          title: 'Remote Version',
          description: 'Choose manually',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        // Act
        final resolvedEvent = await offlineService.resolveConflict(
          localEvent, 
          remoteEvent,
          ConflictResolutionStrategy.manual,
          userChoice: remoteEvent,
        );

        // Assert - This should FAIL initially as service doesn't exist
        expect(resolvedEvent.title, 'Remote Version');
      });
    });

    group('Background Sync', () {
      test('should process offline actions when network becomes available', () async {
        // Arrange
        final queuedEvent = CalendarEvent(
          id: 'queued-event',
          title: 'Queued for Sync',
          description: 'Will sync when online',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        await offlineService.createEventOffline(queuedEvent);

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockSyncService.authenticate()).thenAnswer((_) async => const Right(true));

        // Act
        final result = await offlineService.processOfflineActions();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Right<Failure, bool>>());
        expect(result.fold((l) => false, (r) => r), true);
      });

      test('should handle partial sync failures gracefully', () async {
        // Arrange
        final event1 = CalendarEvent(
          id: 'sync-success',
          title: 'Will Sync',
          description: 'Success',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        final event2 = CalendarEvent(
          id: 'sync-fail',
          title: 'Will Fail',
          description: 'Failure',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        await offlineService.createEventOffline(event1);
        await offlineService.createEventOffline(event2);

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockSyncService.authenticate()).thenAnswer((_) async => const Right(true));

        // Act
        final result = await offlineService.processOfflineActions();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Right<Failure, bool>>());
        final remainingActions = await offlineService.getPendingActionsCount();
        expect(remainingActions, greaterThan(0)); // Some actions may have failed
      });
    });

    group('Sync Status Management', () {
      test('should track sync status for each event', () async {
        // Arrange
        final event = CalendarEvent(
          id: 'status-track',
          title: 'Track Status',
          description: 'Monitor sync status',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        // Act
        await offlineService.setSyncStatus(event.id, CalendarSyncStatus.syncing);
        final status = await offlineService.getSyncStatus(event.id);

        // Assert - This should FAIL initially as service doesn't exist
        expect(status, CalendarSyncStatus.syncing);
      });

      test('should update sync status after successful sync', () async {
        // Arrange
        final event = CalendarEvent(
          id: 'status-success',
          title: 'Sync Success',
          description: 'Will be marked as synced',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        await offlineService.setSyncStatus(event.id, CalendarSyncStatus.syncing);

        // Act
        await offlineService.setSyncStatus(event.id, CalendarSyncStatus.synced);
        final status = await offlineService.getSyncStatus(event.id);

        // Assert - This should FAIL initially as service doesn't exist
        expect(status, CalendarSyncStatus.synced);
      });

      test('should mark events with conflicts appropriately', () async {
        // Arrange
        final event = CalendarEvent(
          id: 'status-conflict',
          title: 'Has Conflict',
          description: 'Will be marked as conflict',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        // Act
        await offlineService.setSyncStatus(event.id, CalendarSyncStatus.conflict);
        final status = await offlineService.getSyncStatus(event.id);

        // Assert - This should FAIL initially as service doesn't exist
        expect(status, CalendarSyncStatus.conflict);
      });
    });

    group('Data Consistency', () {
      test('should maintain referential integrity during offline operations', () async {
        // Arrange
        final originalEvent = CalendarEvent(
          id: 'integrity-test',
          title: 'Original Event',
          description: 'For integrity testing',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        await offlineService.cacheEvent(originalEvent);

        final updatedEvent = CalendarEvent(
          id: 'integrity-test',
          title: 'Updated Event',
          description: 'Updated for integrity testing',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          isAllDay: false,
        );

        // Act
        await offlineService.updateEventOffline(updatedEvent);
        final cachedEvents = await offlineService.getCachedEvents();

        // Assert - This should FAIL initially as service doesn't exist
        final events = cachedEvents.fold((l) => <CalendarEvent>[], (r) => r);
        final cachedEvent = events.firstWhere((e) => e.id == 'integrity-test');
        expect(cachedEvent.title, 'Updated Event');
        expect(cachedEvent.description, 'Updated for integrity testing');
      });

      test('should validate event data before caching', () async {
        // Arrange
        final invalidEvent = CalendarEvent(
          id: '', // Invalid empty ID
          title: 'Invalid Event',
          description: 'Should not be cached',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          isAllDay: false,
        );

        // Act & Assert - This should FAIL initially as service doesn't exist
        expect(
          () => offlineService.cacheEvent(invalidEvent),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
