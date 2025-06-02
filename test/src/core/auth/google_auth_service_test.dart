import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:planning/src/core/auth/google_auth_service.dart';
import 'package:planning/src/core/errors/failures.dart';

// Mock classes
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}

void main() {
  group('GoogleAuthService', () {
    late GoogleAuthService authService;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockGoogleSignInAccount mockAccount;
    late MockGoogleSignInAuthentication mockAuthentication;

    setUp(() {
      mockGoogleSignIn = MockGoogleSignIn();
      mockAccount = MockGoogleSignInAccount();
      mockAuthentication = MockGoogleSignInAuthentication();
      authService = GoogleAuthService(googleSignIn: mockGoogleSignIn);
    });

    group('signIn', () {
      test('should return true when sign in is successful', () async {
        // Arrange
        const scopes = ['https://www.googleapis.com/auth/calendar.readonly'];
        when(() => mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockAccount);
        when(() => mockGoogleSignIn.requestScopes(scopes))
            .thenAnswer((_) async => true);
        when(() => mockAccount.authentication)
            .thenAnswer((_) async => mockAuthentication);
        when(() => mockAuthentication.accessToken)
            .thenReturn('mock_access_token');

        // Act
        final result = await authService.signIn(scopes: scopes);

        // Assert
        expect(result, isA<Right<Failure, bool>>());
        expect(result.fold((l) => null, (r) => r), true);
        verify(() => mockGoogleSignIn.signIn()).called(1);
        verify(() => mockGoogleSignIn.requestScopes(scopes)).called(1);
      });

      test('should return AuthFailure when user cancels sign in', () async {
        // Arrange
        const scopes = ['https://www.googleapis.com/auth/calendar.readonly'];
        when(() => mockGoogleSignIn.signIn())
            .thenAnswer((_) async => null);

        // Act
        final result = await authService.signIn(scopes: scopes);

        // Assert
        expect(result, isA<Left<Failure, bool>>());
        expect(result.fold((l) => l, (r) => null), isA<AuthFailure>());
      });

      test('should return AuthFailure when scope request is denied', () async {
        // Arrange
        const scopes = ['https://www.googleapis.com/auth/calendar.readonly'];
        when(() => mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockAccount);
        when(() => mockGoogleSignIn.requestScopes(scopes))
            .thenAnswer((_) async => false);

        // Act
        final result = await authService.signIn(scopes: scopes);

        // Assert
        expect(result, isA<Left<Failure, bool>>());
        expect(result.fold((l) => l, (r) => null), isA<AuthFailure>());
      });

      test('should return AuthFailure when an exception occurs', () async {
        // Arrange
        const scopes = ['https://www.googleapis.com/auth/calendar.readonly'];
        when(() => mockGoogleSignIn.signIn())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await authService.signIn(scopes: scopes);

        // Assert
        expect(result, isA<Left<Failure, bool>>());
        expect(result.fold((l) => l, (r) => null), isA<AuthFailure>());
      });
    });

    group('signOut', () {
      test('should return true when sign out is successful', () async {
        // Arrange
        when(() => mockGoogleSignIn.signOut())
            .thenAnswer((_) async => mockAccount);

        // Act
        final result = await authService.signOut();

        // Assert
        expect(result, isA<Right<Failure, bool>>());
        expect(result.fold((l) => null, (r) => r), true);
        verify(() => mockGoogleSignIn.signOut()).called(1);
      });

      test('should return AuthFailure when sign out fails', () async {
        // Arrange
        when(() => mockGoogleSignIn.signOut())
            .thenThrow(Exception('Sign out error'));

        // Act
        final result = await authService.signOut();

        // Assert
        expect(result, isA<Left<Failure, bool>>());
        expect(result.fold((l) => l, (r) => null), isA<AuthFailure>());
      });
    });

    group('getCalendarApi', () {
      test('should return CalendarApi when user is authenticated', () async {
        // Arrange
        when(() => mockGoogleSignIn.currentUser)
            .thenReturn(mockAccount);
        when(() => mockAccount.authentication)
            .thenAnswer((_) async => mockAuthentication);
        when(() => mockAuthentication.accessToken)
            .thenReturn('mock_access_token');

        // Act
        final result = await authService.getCalendarApi();

        // Assert
        expect(result, isA<Right<Failure, calendar.CalendarApi>>());
      });

      test('should return AuthFailure when user is not authenticated', () async {
        // Arrange
        when(() => mockGoogleSignIn.currentUser)
            .thenReturn(null);

        // Act
        final result = await authService.getCalendarApi();

        // Assert
        expect(result, isA<Left<Failure, calendar.CalendarApi>>());
        expect(result.fold((l) => l, (r) => null), isA<AuthFailure>());
      });
    });

    group('isSignedIn', () {
      test('should return true when user is signed in', () {
        // Arrange
        when(() => mockGoogleSignIn.currentUser)
            .thenReturn(mockAccount);

        // Act
        final result = authService.isSignedIn();

        // Assert
        expect(result, true);
      });

      test('should return false when user is not signed in', () {
        // Arrange
        when(() => mockGoogleSignIn.currentUser)
            .thenReturn(null);

        // Act
        final result = authService.isSignedIn();

        // Assert
        expect(result, false);
      });
    });
  });
}
