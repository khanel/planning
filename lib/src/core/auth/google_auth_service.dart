import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:planning/src/core/errors/exceptions.dart';
import 'package:planning/src/core/errors/failures.dart';

/// Service for handling Google authentication
class GoogleAuthService {
  final GoogleSignIn googleSignIn;

  GoogleAuthService({required this.googleSignIn});

  /// Sign in to Google and request calendar access
  Future<Either<Failure, bool>> signIn({List<String>? scopes}) async {
    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        return const Left(AuthFailure());
      }
      
      if (scopes != null && scopes.isNotEmpty) {
        final scopesGranted = await googleSignIn.requestScopes(scopes);
        return Right(scopesGranted);
      }
      
      return const Right(true);
    } catch (e) {
      return const Left(AuthFailure());
    }
  }

  /// Sign out from Google
  Future<Either<Failure, bool>> signOut() async {
    try {
      await googleSignIn.signOut();
      return const Right(true);
    } catch (e) {
      return const Left(AuthFailure());
    }
  }

  /// Check if user is currently signed in
  bool isSignedIn() => googleSignIn.currentUser != null;

  /// Get current signed in user
  GoogleSignInAccount? get currentUser => googleSignIn.currentUser;

  /// Get Calendar API instance for authenticated user
  Future<Either<Failure, calendar.CalendarApi>> getCalendarApi() async {
    try {
      final user = googleSignIn.currentUser;
      if (user == null) {
        return const Left(AuthFailure());
      }

      final authentication = await user.authentication;
      final accessToken = authentication.accessToken;
      
      if (accessToken == null) {
        return const Left(AuthFailure());
      }

      final credentials = AccessCredentials(
        AccessToken('Bearer', accessToken, DateTime.now().add(const Duration(hours: 1))),
        null,
        ['https://www.googleapis.com/auth/calendar'],
      );

      final client = authenticatedClient(
        http.Client(),
        credentials,
      );

      final calendarApi = calendar.CalendarApi(client);
      return Right(calendarApi);
    } catch (e) {
      return const Left(AuthFailure());
    }
  }
}
