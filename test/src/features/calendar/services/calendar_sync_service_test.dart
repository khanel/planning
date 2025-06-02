import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/errors/exceptions.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/services/calendar_sync_service.dart';

// Mock classes
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}
class MockCalendarApi extends Mock implements calendar.CalendarApi {}
class MockEventsResource extends Mock implements calendar.EventsResource {}

void main() {
  group('CalendarSyncService - RED PHASE - Failing Tests for Calendar Sync', () {
    late CalendarSyncService syncService;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockGoogleSignInAccount mockAccount;
    late MockGoogleSignInAuthentication mockAuth;
    late MockCalendarApi mockCalendarApi;
    late MockEventsResource mockEventsResource;

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
      registerFallbackValue(calendar.Event());
    });

    setUp(() {
      mockGoogleSignIn = MockGoogleSignIn();
      mockAccount = MockGoogleSignInAccount();
      mockAuth = MockGoogleSignInAuthentication();
      mockCalendarApi = MockCalendarApi();
      mockEventsResource = MockEventsResource();
      
      // Create sync service with mocked dependencies
      syncService = CalendarSyncService(
        googleSignIn: mockGoogleSignIn,
        calendarApi: mockCalendarApi,
      );
    });

    group('Authentication Integration', () {
      test('should authenticate with Google and initialize calendar API', () async {
        // Arrange
        when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
        when(() => mockAccount.authentication).thenAnswer((_) async => mockAuth);
        when(() => mockAuth.accessToken).thenReturn('test-access-token');
        when(() => mockGoogleSignIn.requestScopes(any())).thenAnswer((_) async => true);

        // Act
        final result = await syncService.authenticate();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Right<Failure, bool>>());
        expect(result.fold((l) => false, (r) => r), true);
        verify(() => mockGoogleSignIn.signIn()).called(1);
        verify(() => mockGoogleSignIn.requestScopes(any())).called(1);
      });

      test('should return AuthFailure when Google sign-in fails', () async {
        // Arrange
        when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        // Act
        final result = await syncService.authenticate();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Left<Failure, bool>>());
        expect(result.fold((l) => l, (r) => null), isA<AuthFailure>());
      });

      test('should handle scope request failure gracefully', () async {
        // Arrange
        when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
        when(() => mockAccount.authentication).thenAnswer((_) async => mockAuth);
        when(() => mockAuth.accessToken).thenReturn('test-access-token');
        when(() => mockGoogleSignIn.requestScopes(any())).thenAnswer((_) async => false);

        // Act
        final result = await syncService.authenticate();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Left<Failure, bool>>());
        expect(result.fold((l) => l, (r) => null), isA<AuthFailure>());
      });
    });

    group('Token Management', () {
      test('should check if authentication token is valid', () async {
        // Arrange
        when(() => mockGoogleSignIn.isSignedIn()).thenAnswer((_) async => true);
        when(() => mockGoogleSignIn.currentUser).thenReturn(mockAccount);
        when(() => mockAccount.authentication).thenAnswer((_) async => mockAuth);
        when(() => mockAuth.accessToken).thenReturn('valid-token');

        // Act
        final result = await syncService.isAuthenticated();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, true);
      });

      test('should return false when not authenticated', () async {
        // Arrange
        when(() => mockGoogleSignIn.isSignedIn()).thenAnswer((_) async => false);

        // Act
        final result = await syncService.isAuthenticated();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, false);
      });

      test('should refresh authentication token when expired', () async {
        // Arrange
        when(() => mockGoogleSignIn.signInSilently()).thenAnswer((_) async => mockAccount);
        when(() => mockAccount.authentication).thenAnswer((_) async => mockAuth);
        when(() => mockAuth.accessToken).thenReturn('refreshed-token');

        // Act
        final result = await syncService.refreshToken();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Right<Failure, bool>>());
        expect(result.fold((l) => false, (r) => r), true);
      });
    });

    group('Calendar Synchronization', () {
      test('should perform full sync when no sync token exists', () async {
        // Arrange
        final mockEventsList = calendar.Events();
        mockEventsList.items = [
          calendar.Event()
            ..id = 'event-1'
            ..summary = 'Test Event 1'
            ..description = 'Test Description 1',
          calendar.Event()
            ..id = 'event-2'
            ..summary = 'Test Event 2'
            ..description = 'Test Description 2',
        ];
        mockEventsList.nextSyncToken = 'new-sync-token';

        when(() => mockCalendarApi.events).thenReturn(mockEventsResource);
        when(() => mockEventsResource.list(
          any(),
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
          singleEvents: any(named: 'singleEvents'),
          orderBy: any(named: 'orderBy'),
        )).thenAnswer((_) async => mockEventsList);

        // Act
        final result = await syncService.performFullSync();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Right<Failure, List<CalendarEvent>>>());
        final events = result.fold((l) => <CalendarEvent>[], (r) => r);
        expect(events.length, 2);
        expect(events.first.title, 'Test Event 1');
      });

      test('should perform incremental sync with existing sync token', () async {
        // Arrange
        const syncToken = 'existing-sync-token';
        final mockEventsList = calendar.Events();
        mockEventsList.items = [
          calendar.Event()
            ..id = 'updated-event'
            ..summary = 'Updated Event'
            ..description = 'Updated Description',
        ];
        mockEventsList.nextSyncToken = 'newer-sync-token';

        when(() => mockCalendarApi.events).thenReturn(mockEventsResource);
        when(() => mockEventsResource.list(
          any(),
          syncToken: syncToken,
          showDeleted: true,
        )).thenAnswer((_) async => mockEventsList);

        // Act
        final result = await syncService.performIncrementalSync(syncToken);

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Right<Failure, List<CalendarEvent>>>());
        final events = result.fold((l) => <CalendarEvent>[], (r) => r);
        expect(events.length, 1);
        expect(events.first.title, 'Updated Event');
      });

      test('should handle sync token invalidation gracefully', () async {
        // Arrange
        const invalidSyncToken = 'invalid-sync-token';
        when(() => mockCalendarApi.events).thenReturn(mockEventsResource);
        when(() => mockEventsResource.list(
          any(),
          syncToken: invalidSyncToken,
          showDeleted: true,
        )).thenThrow(Exception('Sync token invalid - 410 error'));

        // Act
        final result = await syncService.performIncrementalSync(invalidSyncToken);

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Left<Failure, List<CalendarEvent>>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
      });
    });

    group('Error Handling', () {
      test('should handle network errors during sync', () async {
        // Arrange
        when(() => mockCalendarApi.events).thenReturn(mockEventsResource);
        when(() => mockEventsResource.list(
          any(),
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
          singleEvents: any(named: 'singleEvents'),
          orderBy: any(named: 'orderBy'),
        )).thenThrow(Exception('Network error'));

        // Act
        final result = await syncService.performFullSync();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Left<Failure, List<CalendarEvent>>>());
        expect(result.fold((l) => l, (r) => null), isA<NetworkFailure>());
      });

      test('should handle authentication errors during sync', () async {
        // Arrange
        when(() => mockCalendarApi.events).thenReturn(mockEventsResource);
        when(() => mockEventsResource.list(
          any(),
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
          singleEvents: any(named: 'singleEvents'),
          orderBy: any(named: 'orderBy'),
        )).thenThrow(Exception('Authentication required - 401 error'));

        // Act
        final result = await syncService.performFullSync();

        // Assert - This should FAIL initially as service doesn't exist
        expect(result, isA<Left<Failure, List<CalendarEvent>>>());
        expect(result.fold((l) => l, (r) => null), isA<AuthFailure>());
      });
    });

    group('Sync State Management', () {
      test('should store and retrieve sync token', () async {
        // Arrange
        const syncToken = 'test-sync-token';

        // Act
        await syncService.storeSyncToken(syncToken);
        final retrievedToken = await syncService.getSyncToken();

        // Assert - This should FAIL initially as service doesn't exist
        expect(retrievedToken, syncToken);
      });

      test('should clear sync token when full sync is required', () async {
        // Arrange
        const syncToken = 'test-sync-token';
        await syncService.storeSyncToken(syncToken);

        // Act
        await syncService.clearSyncToken();
        final retrievedToken = await syncService.getSyncToken();

        // Assert - This should FAIL initially as service doesn't exist
        expect(retrievedToken, isNull);
      });

      test('should track last sync timestamp', () async {
        // Arrange
        final now = DateTime.now();

        // Act
        await syncService.updateLastSyncTime(now);
        final lastSyncTime = await syncService.getLastSyncTime();

        // Assert - This should FAIL initially as service doesn't exist
        expect(lastSyncTime, isNotNull);
        expect(lastSyncTime!.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      });
    });
  });
}
