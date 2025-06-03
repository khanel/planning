import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:planning/src/core/auth/google_auth_service.dart';
import 'package:planning/src/features/calendar/services/calendar_sync_service.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';

// Mock classes
class MockGoogleAuthService extends Mock implements GoogleAuthService {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockCalendarApi extends Mock implements calendar.CalendarApi {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}
class MockEvents extends Mock implements calendar.EventsResource {}
class MockCalendarList extends Mock implements calendar.CalendarListResource {}

// Fake classes for fallback values
class FakeDateTime extends Fake implements DateTime {}

void main() {
  group('AuthCalendarSyncIntegration', () {
    late MockGoogleAuthService mockAuthService;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockCalendarApi mockCalendarApi;
    late MockGoogleSignInAccount mockAccount;
    late MockGoogleSignInAuthentication mockAuthentication;
    late MockEvents mockEvents;
    late MockCalendarList mockCalendarList;
    late CalendarSyncService syncService;

    setUpAll(() {
      registerFallbackValue(FakeDateTime());
    });

    setUp(() {
      mockAuthService = MockGoogleAuthService();
      mockGoogleSignIn = MockGoogleSignIn();
      mockCalendarApi = MockCalendarApi();
      mockAccount = MockGoogleSignInAccount();
      mockAuthentication = MockGoogleSignInAuthentication();
      mockEvents = MockEvents();
      mockCalendarList = MockCalendarList();

      // Setup calendar API mocks
      when(() => mockCalendarApi.events).thenReturn(mockEvents);
      when(() => mockCalendarApi.calendarList).thenReturn(mockCalendarList);
    });

    group('Integrated Authentication and Sync', () {
      test('should use GoogleAuthService for authentication instead of direct GoogleSignIn', () async {
        // Arrange
        when(() => mockAuthService.signIn(scopes: any(named: 'scopes')))
            .thenAnswer((_) async => const Right(true));
        when(() => mockAuthService.getCalendarApi())
            .thenAnswer((_) async => Right(mockCalendarApi));
        when(() => mockAuthService.isSignedIn()).thenReturn(true);

        // Setup calendar list response
        final calendarListResponse = calendar.CalendarList(
          items: [
            calendar.CalendarListEntry(
              id: 'primary',
              summary: 'Primary Calendar',
            ),
          ],
        );
        when(() => mockCalendarList.list()).thenAnswer((_) async => calendarListResponse);

        // Create sync service with auth service integration
        syncService = CalendarSyncService.withAuthService(
          authService: mockAuthService,
        );

        // Act
        final result = await syncService.authenticate();

        // Assert
        expect(result, isA<Right<Failure, bool>>());
        expect(result.fold((l) => null, (r) => r), true);
        verify(() => mockAuthService.signIn(scopes: ['https://www.googleapis.com/auth/calendar'])).called(1);
        verify(() => mockAuthService.getCalendarApi()).called(1);
        verifyNever(() => mockGoogleSignIn.signIn());
      });

      test('should return AuthFailure when GoogleAuthService authentication fails', () async {
        // Arrange
        when(() => mockAuthService.signIn(scopes: any(named: 'scopes')))
            .thenAnswer((_) async => const Left(AuthFailure()));

        syncService = CalendarSyncService.withAuthService(
          authService: mockAuthService,
        );

        // Act
        final result = await syncService.authenticate();

        // Assert
        expect(result, isA<Left<Failure, bool>>());
        expect(result.fold((l) => l, (r) => null), isA<AuthFailure>());
        verify(() => mockAuthService.signIn(scopes: ['https://www.googleapis.com/auth/calendar'])).called(1);
        verifyNever(() => mockAuthService.getCalendarApi());
      });

      test('should return AuthFailure when GoogleAuthService fails to get Calendar API', () async {
        // Arrange
        when(() => mockAuthService.signIn(scopes: any(named: 'scopes')))
            .thenAnswer((_) async => const Right(true));
        when(() => mockAuthService.getCalendarApi())
            .thenAnswer((_) async => const Left(AuthFailure()));

        syncService = CalendarSyncService.withAuthService(
          authService: mockAuthService,
        );

        // Act
        final result = await syncService.authenticate();

        // Assert
        expect(result, isA<Left<Failure, bool>>());
        expect(result.fold((l) => l, (r) => null), isA<AuthFailure>());
        verify(() => mockAuthService.signIn(scopes: ['https://www.googleapis.com/auth/calendar'])).called(1);
        verify(() => mockAuthService.getCalendarApi()).called(1);
      });

      test('should sync events successfully using GoogleAuthService for API access', () async {
        // Arrange
        when(() => mockAuthService.isSignedIn()).thenReturn(true);
        when(() => mockAuthService.getCalendarApi())
            .thenAnswer((_) async => Right(mockCalendarApi));

        // Setup calendar events response
        final eventsResponse = calendar.Events(
          items: [
            calendar.Event(
              id: 'event_1',
              summary: 'Test Event',
              start: calendar.EventDateTime(dateTime: DateTime.now()),
              end: calendar.EventDateTime(dateTime: DateTime.now().add(const Duration(hours: 1))),
            ),
          ],
        );
        when(() => mockEvents.list(
          'primary',
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
          singleEvents: true,
          orderBy: 'startTime',
        )).thenAnswer((_) async => eventsResponse);

        syncService = CalendarSyncService.withAuthService(
          authService: mockAuthService,
        );

        // Act
        final result = await syncService.syncEvents();

        // Assert
        expect(result, isA<Right<Failure, List<CalendarEvent>>>());
        final events = result.fold((l) => null, (r) => r);
        expect(events, isNotNull);
        expect(events!.length, 1);
        expect(events.first.id, 'event_1');
        expect(events.first.title, 'Test Event');
        verify(() => mockAuthService.isSignedIn()).called(1);
        verify(() => mockAuthService.getCalendarApi()).called(1);
      });

      test('should return AuthFailure when user is not signed in during sync', () async {
        // Arrange
        when(() => mockAuthService.isSignedIn()).thenReturn(false);

        syncService = CalendarSyncService.withAuthService(
          authService: mockAuthService,
        );

        // Act
        final result = await syncService.syncEvents();

        // Assert
        expect(result, isA<Left<Failure, List<CalendarEvent>>>());
        expect(result.fold((l) => l, (r) => null), isA<AuthFailure>());
        verify(() => mockAuthService.isSignedIn()).called(1);
        verifyNever(() => mockAuthService.getCalendarApi());
      });

      test('should handle token refresh through GoogleAuthService during sync', () async {
        // Arrange
        when(() => mockAuthService.isSignedIn()).thenReturn(true);
        when(() => mockAuthService.getCalendarApi())
            .thenAnswer((_) async => Right(mockCalendarApi));

        // Mock events API to throw an exception
        when(() => mockEvents.list(
          'primary',
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
          singleEvents: true,
          orderBy: 'startTime',
        )).thenThrow(Exception('Token expired'));

        syncService = CalendarSyncService.withAuthService(
          authService: mockAuthService,
        );

        // Act
        final result = await syncService.syncEvents();

        // Assert - Should fail but indicate token refresh is needed
        expect(result, isA<Left<Failure, List<CalendarEvent>>>());
        verify(() => mockAuthService.getCalendarApi()).called(2); // Called twice due to retry
      });
    });

    group('Authentication State Management', () {
      test('should check authentication status through GoogleAuthService', () {
        // Arrange
        when(() => mockAuthService.isSignedIn()).thenReturn(true);

        syncService = CalendarSyncService.withAuthService(
          authService: mockAuthService,
        );

        // Act
        final isAuthenticated = syncService.isAuthenticated();

        // Assert
        expect(isAuthenticated, true);
        verify(() => mockAuthService.isSignedIn()).called(1);
      });

      test('should sign out through GoogleAuthService', () async {
        // Arrange
        when(() => mockAuthService.signOut())
            .thenAnswer((_) async => const Right(true));

        syncService = CalendarSyncService.withAuthService(
          authService: mockAuthService,
        );

        // Act
        final result = await syncService.signOut();

        // Assert
        expect(result, isA<Right<Failure, bool>>());
        expect(result.fold((l) => null, (r) => r), true);
        verify(() => mockAuthService.signOut()).called(1);
      });

      test('should return failure when GoogleAuthService sign out fails', () async {
        // Arrange
        when(() => mockAuthService.signOut())
            .thenAnswer((_) async => const Left(AuthFailure()));

        syncService = CalendarSyncService.withAuthService(
          authService: mockAuthService,
        );

        // Act
        final result = await syncService.signOut();

        // Assert
        expect(result, isA<Left<Failure, bool>>());
        expect(result.fold((l) => l, (r) => null), isA<AuthFailure>());
        verify(() => mockAuthService.signOut()).called(1);
      });
    });
  });
}
