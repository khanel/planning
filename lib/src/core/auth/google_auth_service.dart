import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:planning/src/core/errors/failures.dart';

/// Service for handling Google authentication and API access
/// 
/// This service provides methods for Google Sign-In authentication,
/// scope management, and Google Calendar API access following
/// OAuth 2.0 best practices and incremental authorization patterns.
/// 
/// Example usage:
/// ```dart
/// final authService = GoogleAuthService(googleSignIn: GoogleSignIn());
/// final signInResult = await authService.signIn();
/// if (signInResult.isRight()) {
///   final calendarResult = await authService.getCalendarApi();
/// }
/// ```
class GoogleAuthService {
  /// Default token expiry duration (1 hour as per Google recommendations)
  static const Duration _defaultTokenExpiry = Duration(hours: 1);
  
  /// Google Calendar API scope
  static const String _calendarScope = 'https://www.googleapis.com/auth/calendar';
  
  /// Bearer token type for OAuth 2.0
  static const String _bearerTokenType = 'Bearer';

  final GoogleSignIn googleSignIn;

  GoogleAuthService({required this.googleSignIn});

  /// Sign in to Google and optionally request additional scopes
  /// 
  /// [scopes] Optional list of OAuth 2.0 scopes to request during sign-in.
  /// If provided, uses incremental authorization to request these scopes.
  /// 
  /// Returns [Right] with [bool] indicating success (true) or scope denial (false),
  /// or [Left] with [AuthFailure] if sign-in fails or is cancelled.
  /// 
  /// Example:
  /// ```dart
  /// // Basic sign-in
  /// final result = await authService.signIn();
  /// 
  /// // Sign-in with Calendar scope
  /// final result = await authService.signIn(
  ///   scopes: ['https://www.googleapis.com/auth/calendar']
  /// );
  /// ```
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
  /// 
  /// Returns [Right] with [true] if sign-out is successful,
  /// or [Left] with [AuthFailure] if sign-out fails.
  Future<Either<Failure, bool>> signOut() async {
    try {
      await googleSignIn.signOut();
      return const Right(true);
    } catch (e) {
      return const Left(AuthFailure());
    }
  }

  /// Check if user is currently signed in
  /// 
  /// Returns [true] if a user is currently authenticated, [false] otherwise.
  /// This method provides a synchronous way to check authentication status.
  bool isSignedIn() => googleSignIn.currentUser != null;

  /// Get current signed in user
  /// 
  /// Returns the currently authenticated [GoogleSignInAccount] or [null]
  /// if no user is signed in. Use [isSignedIn] to check authentication status first.
  GoogleSignInAccount? get currentUser => googleSignIn.currentUser;

  /// Get Calendar API instance for authenticated user
  /// 
  /// Returns [Right] with [CalendarApi] instance if authentication is successful,
  /// or [Left] with [AuthFailure] if authentication fails.
  /// 
  /// This method follows Google's OAuth 2.0 best practices for API client creation.
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

      final credentials = _createAccessCredentials(accessToken);
      final client = authenticatedClient(http.Client(), credentials);
      final calendarApi = calendar.CalendarApi(client);
      
      return Right(calendarApi);
    } catch (e) {
      return const Left(AuthFailure());
    }
  }

  /// Creates [AccessCredentials] for Google API authentication
  /// 
  /// [accessToken] The OAuth 2.0 access token received from Google Sign-In
  /// 
  /// Returns properly configured [AccessCredentials] with UTC expiry time
  /// and Calendar API scope for authenticated API requests.
  AccessCredentials _createAccessCredentials(String accessToken) {
    final expiryTime = DateTime.now().toUtc().add(_defaultTokenExpiry);
    
    return AccessCredentials(
      AccessToken(_bearerTokenType, accessToken, expiryTime),
      null, // No refresh token needed for this use case
      [_calendarScope],
    );
  }
}
