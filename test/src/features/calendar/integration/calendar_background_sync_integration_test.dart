import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:planning/src/features/calendar/services/sync/calendar_background_sync.dart';
import 'package:planning/src/features/calendar/services/sync/calendar_sync_service.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';

class MockCalendarSyncService extends Mock implements CalendarSyncService {}

/// Integration tests for CalendarBackgroundSync service
/// 
/// These tests verify end-to-end functionality of the background sync service
/// including error handling, authentication management, and WorkManager integration.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('CalendarBackgroundSync - Integration Tests', () {
    late MockCalendarSyncService mockSyncService;
    late CalendarBackgroundSync backgroundSync;

    setUp(() {
      mockSyncService = MockCalendarSyncService();
      backgroundSync = CalendarBackgroundSync(syncService: mockSyncService);
    });

    group('End-to-End Background Sync Workflow', () {
      test('should complete full background sync workflow when user is authenticated', () async {
        // Arrange - Set up a successful sync scenario
        final testEvents = [
          CalendarEvent(
            id: 'event-1',
            title: 'Meeting 1',
            description: 'Important meeting',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            isAllDay: false,
          ),
          CalendarEvent(
            id: 'event-2',
            title: 'Meeting 2',
            description: 'Another meeting',
            startTime: DateTime.now().add(const Duration(hours: 2)),
            endTime: DateTime.now().add(const Duration(hours: 3)),
            isAllDay: false,
          ),
        ];

        when(() => mockSyncService.isAuthenticated()).thenReturn(true);
        when(() => mockSyncService.syncEvents()).thenAnswer(
          (_) async => Right(testEvents),
        );

        // Act - Execute the sync operation
        final result = await backgroundSync.executeSyncOperation();

        // Assert - Verify successful execution
        expect(result, true);
        verify(() => mockSyncService.isAuthenticated()).called(1);
        verify(() => mockSyncService.syncEvents()).called(1);
      });

      test('should handle authentication flow in background sync', () async {
        // Arrange - User not authenticated initially, but can authenticate
        when(() => mockSyncService.isAuthenticated()).thenReturn(false);
        when(() => mockSyncService.authenticate()).thenAnswer(
          (_) async => const Right(true),
        );
        when(() => mockSyncService.syncEvents()).thenAnswer(
          (_) async => const Right([]),
        );

        // Act
        final result = await backgroundSync.executeSyncOperation();

        // Assert - Should attempt authentication and then sync
        expect(result, true);
        verify(() => mockSyncService.isAuthenticated()).called(1);
        verify(() => mockSyncService.authenticate()).called(1);
        verify(() => mockSyncService.syncEvents()).called(1);
      });

      test('should gracefully handle network failures during background sync', () async {
        // Arrange - Network failure scenario
        when(() => mockSyncService.isAuthenticated()).thenReturn(true);
        when(() => mockSyncService.syncEvents()).thenAnswer(
          (_) async => const Left(NetworkFailure()),
        );

        // Act
        final result = await backgroundSync.executeSyncOperation();

        // Assert - Should handle failure gracefully
        expect(result, false);
        verify(() => mockSyncService.isAuthenticated()).called(1);
        verify(() => mockSyncService.syncEvents()).called(1);
      });

      test('should handle authentication failures gracefully', () async {
        // Arrange - Authentication fails
        when(() => mockSyncService.isAuthenticated()).thenReturn(false);
        when(() => mockSyncService.authenticate()).thenAnswer(
          (_) async => const Left(AuthFailure()),
        );

        // Act
        final result = await backgroundSync.executeSyncOperation();

        // Assert - Should not proceed to sync when auth fails
        expect(result, false);
        verify(() => mockSyncService.isAuthenticated()).called(1);
        verify(() => mockSyncService.authenticate()).called(1);
        verifyNever(() => mockSyncService.syncEvents());
      });

      test('should handle server errors during background sync', () async {
        // Arrange - Server error scenario
        when(() => mockSyncService.isAuthenticated()).thenReturn(true);
        when(() => mockSyncService.syncEvents()).thenAnswer(
          (_) async => const Left(ServerFailure()),
        );

        // Act
        final result = await backgroundSync.executeSyncOperation();

        // Assert - Should handle server error gracefully
        expect(result, false);
        verify(() => mockSyncService.isAuthenticated()).called(1);
        verify(() => mockSyncService.syncEvents()).called(1);
      });
    });

    group('WorkManager Task Registration', () {
      test('should handle task registration errors gracefully', () async {
        // Act - These will fail in test environment but should not throw
        final periodicResult = await backgroundSync.registerPeriodicSync();
        final oneTimeResult = await backgroundSync.registerOneTimeSync();

        // Assert - Should return failure results but not throw exceptions
        expect(periodicResult, isA<Left<Failure, bool>>());
        expect(oneTimeResult, isA<Left<Failure, bool>>());
      });

      test('should handle task cancellation without throwing', () async {
        // Act & Assert - Should complete without throwing even if WorkManager fails
        expect(() async => await backgroundSync.cancelAllSyncTasks(), returnsNormally);
        expect(() async => await backgroundSync.cancelPeriodicSync(), returnsNormally);
        expect(() async => await backgroundSync.cancelOneTimeSync(), returnsNormally);
      });
    });

    group('Error Resilience', () {
      test('should recover from unexpected exceptions', () async {
        // Arrange - Unexpected exception
        when(() => mockSyncService.isAuthenticated()).thenThrow(
          Exception('Unexpected error'),
        );

        // Act
        final result = await backgroundSync.executeSyncOperation();

        // Assert - Should handle unexpected errors gracefully
        expect(result, false);
        verify(() => mockSyncService.isAuthenticated()).called(1);
      });

      test('should handle null or empty sync results', () async {
        // Arrange - Empty sync result
        when(() => mockSyncService.isAuthenticated()).thenReturn(true);
        when(() => mockSyncService.syncEvents()).thenAnswer(
          (_) async => const Right([]),
        );

        // Act
        final result = await backgroundSync.executeSyncOperation();

        // Assert - Should handle empty results as success
        expect(result, true);
        verify(() => mockSyncService.isAuthenticated()).called(1);
        verify(() => mockSyncService.syncEvents()).called(1);
      });
    });
  });
}
