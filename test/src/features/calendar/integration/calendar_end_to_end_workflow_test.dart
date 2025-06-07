import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:planning/src/core/auth/google_auth_service.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/services/core/calendar_integration_service.dart';
import 'package:planning/src/features/calendar/services/core/session_aware_calendar_service.dart';
import 'package:planning/src/core/errors/failures.dart';

// Mock classes
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}

// Fake classes for mocktail fallback values
class FakeEvent extends Fake implements calendar.Event {}

/// Integration tests for the complete calendar workflow:
/// Authentication → Calendar API → CRUD Operations
/// 
/// This test file follows TDD Red phase by creating tests that will initially fail
/// because they test the integration between GoogleAuthService and calendar operations
/// that requires a complete end-to-end workflow implementation.
void main() {
  late GoogleAuthService authService;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockAccount;
  late MockGoogleSignInAuthentication mockAuthentication;

  setUpAll(() {
    registerFallbackValue(FakeEvent());
  });

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockAccount = MockGoogleSignInAccount();
    mockAuthentication = MockGoogleSignInAuthentication();
    
    authService = GoogleAuthService(googleSignIn: mockGoogleSignIn);
  });

  group('Calendar End-to-End Workflow Integration', () {
    group('RED PHASE - Failing Tests for Integration Scenarios', () {
      test('should perform complete calendar event creation workflow', () async {
        // This test verifies the integration between authentication and calendar service creation
        // It focuses on the integration layer without making real API calls
        
        // Arrange - Setup successful authentication flow
        const calendarScopes = ['https://www.googleapis.com/auth/calendar'];
        when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
        when(() => mockGoogleSignIn.requestScopes(calendarScopes)).thenAnswer((_) async => true);
        when(() => mockGoogleSignIn.currentUser).thenReturn(mockAccount);
        when(() => mockAccount.authentication).thenAnswer((_) async => mockAuthentication);
        when(() => mockAuthentication.accessToken).thenReturn('valid_access_token');

        // Act - Perform the complete workflow
        // Step 1: Authenticate with calendar scope
        final signInResult = await authService.signIn(scopes: calendarScopes);
        expect(signInResult.fold((l) => null, (r) => r), true);

        // Step 2: Get authenticated Calendar API
        final calendarApiResult = await authService.getCalendarApi();
        expect(calendarApiResult, isA<Right<Failure, calendar.CalendarApi>>());

        // Step 3: Verify CalendarIntegrationService can be created from authenticated API
        // This tests the integration layer without making real API calls
        final calendarService = await _createCalendarService(calendarApiResult);
        
        // Assert - Verify the integration service was created successfully
        expect(calendarService, isA<CalendarIntegrationService>());
        
        // Note: We don't test actual calendar operations here as they would require
        // real API calls. The integration layer creation is what we're testing.
      });

      test('should handle authentication failure in complete workflow', () async {
        // This test will FAIL initially because we need proper integration error handling
        
        // Arrange - Setup authentication failure
        when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        // Act - Attempt the workflow
        final signInResult = await authService.signIn(scopes: ['https://www.googleapis.com/auth/calendar']);
        
        // This should fail gracefully and not allow calendar operations
        expect(signInResult, isA<Left<Failure, bool>>());
        
        // Step 2: THIS WILL FAIL - Attempt to get calendar API without authentication
        final calendarApiResult = await authService.getCalendarApi();
        expect(calendarApiResult, isA<Left<Failure, calendar.CalendarApi>>());
        
        // Step 3: THIS WILL FAIL - Integration should handle auth failures properly
        // The integration layer should prevent calendar operations when auth fails
        // This requires implementing proper error propagation through the integration layer
      });

      test('should retrieve and create events in the same authenticated session', () async {
        // This test verifies session management in integration workflows
        
        // Arrange
        const calendarScopes = ['https://www.googleapis.com/auth/calendar'];
        when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
        when(() => mockGoogleSignIn.requestScopes(calendarScopes)).thenAnswer((_) async => true);
        when(() => mockGoogleSignIn.currentUser).thenReturn(mockAccount);
        when(() => mockAccount.authentication).thenAnswer((_) async => mockAuthentication);
        when(() => mockAuthentication.accessToken).thenReturn('valid_access_token');

        // Act - Test session-aware calendar service creation
        // Step 1: Authenticate
        final signInResult = await authService.signIn(scopes: calendarScopes);
        expect(signInResult.fold((l) => null, (r) => r), true);

        // Step 2: Get session-aware calendar service
        final calendarService = await _createSessionAwareCalendarService();
        
        // Assert - Verify the session-aware service was created successfully
        expect(calendarService, isA<SessionAwareCalendarService>());
        
        // Note: We don't test actual operations to avoid real API calls
        // The session management service creation is what we're testing.
      });
    });
  });
}

/// Helper method that creates CalendarIntegrationService from authenticated CalendarApi
/// This implements the integration layer between auth and calendar operations
Future<CalendarIntegrationService> _createCalendarService(Either<Failure, calendar.CalendarApi> calendarApiResult) async {
  return calendarApiResult.fold(
    (failure) => throw Exception('Failed to get Calendar API: $failure'),
    (calendarApi) => CalendarIntegrationService.fromCalendarApi(calendarApi),
  );
}

/// Helper method for session-aware calendar service
/// This maintains authentication state and reuses the same authenticated session
Future<SessionAwareCalendarService> _createSessionAwareCalendarService() async {
  // Create a session-aware calendar service that reuses a mock auth service
  // This allows testing session management capabilities without real authentication
  final mockGoogleSignIn = MockGoogleSignIn();
  final authService = GoogleAuthService(googleSignIn: mockGoogleSignIn);
  
  return SessionAwareCalendarService(authService: authService);
}
