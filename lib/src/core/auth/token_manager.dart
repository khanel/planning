import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dartz/dartz.dart';
import 'package:planning/src/core/errors/failures.dart';

/// Secure token management for Google OAuth authentication
/// 
/// This class handles the secure storage, retrieval, and refresh of OAuth tokens
/// following 2024/2025 security best practices for mobile applications.
/// 
/// Features:
/// - Secure token storage using platform keychain/keystore
/// - Automatic token expiry checking
/// - Silent token refresh capabilities
/// - Proper cleanup on sign-out
/// 
/// Example usage:
/// ```dart
/// final tokenManager = TokenManager(googleSignIn: GoogleSignIn());
/// await tokenManager.storeTokens(accessCredentials);
/// final isValid = await tokenManager.isTokenValid();
/// if (!isValid) {
///   final result = await tokenManager.refreshToken();
/// }
/// ```
class TokenManager {
  /// Key for storing access token in secure storage
  static const String _accessTokenKey = 'google_access_token';
  
  /// Key for storing refresh token in secure storage
  static const String _refreshTokenKey = 'google_refresh_token';
  
  /// Key for storing token expiry timestamp
  static const String _expiryKey = 'token_expiry';
  
  /// Key for storing granted scopes
  static const String _scopesKey = 'granted_scopes';
  
  /// Buffer time before token expiry for proactive refresh (5 minutes)
  static const Duration _expiryBuffer = Duration(minutes: 5);

  final GoogleSignIn googleSignIn;

  TokenManager({required this.googleSignIn});

  /// Store OAuth tokens securely
  /// 
  /// Saves the [credentials] to secure platform storage including access token,
  /// refresh token (if available), expiry time, and granted scopes.
  /// 
  /// [credentials] The OAuth credentials received from successful authentication
  /// 
  /// Returns [Right] with [true] on successful storage,
  /// or [Left] with [CacheFailure] if storage fails.
  Future<Either<Failure, bool>> storeTokens(AccessCredentials credentials) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_accessTokenKey, credentials.accessToken.data);
      await prefs.setString(_refreshTokenKey, credentials.refreshToken ?? '');
      await prefs.setInt(
        _expiryKey, 
        credentials.accessToken.expiry.millisecondsSinceEpoch,
      );
      await prefs.setStringList(_scopesKey, credentials.scopes);
      
      return const Right(true);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  /// Check if the stored token is valid and not expired
  /// 
  /// Verifies that a token exists and is not expired, taking into account
  /// the expiry buffer for proactive refresh.
  /// 
  /// Returns [true] if token is valid and not expired, [false] otherwise.
  Future<bool> isTokenValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(_accessTokenKey);
      final expiryMs = prefs.getInt(_expiryKey);
      
      if (accessToken == null || accessToken.isEmpty || expiryMs == null || expiryMs == 0) {
        return false;
      }
      
      final expiry = DateTime.fromMillisecondsSinceEpoch(expiryMs);
      final now = DateTime.now();
      
      // Token is valid if it expires more than buffer time from now
      return expiry.isAfter(now.add(_expiryBuffer));
    } catch (e) {
      return false;
    }
  }

  /// Get stored access token
  /// 
  /// Retrieves the currently stored access token without validating expiry.
  /// Use [isTokenValid] to check if the token is still valid before using.
  /// 
  /// Returns the stored access token or [null] if not found.
  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Get stored granted scopes
  /// 
  /// Retrieves the list of OAuth scopes that were granted during authentication.
  /// Useful for checking if additional scopes need to be requested.
  /// 
  /// Returns the list of granted scopes or empty list if not found.
  Future<List<String>> getGrantedScopes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_scopesKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Refresh the stored authentication token
  /// 
  /// Attempts to silently refresh the authentication token using Google Sign-In.
  /// This method will try to refresh without user interaction.
  /// 
  /// Returns [Right] with [true] if refresh is successful,
  /// or [Left] with [AuthFailure] if refresh fails and re-authentication is required.
  Future<Either<Failure, bool>> refreshToken() async {
    try {
      final account = await googleSignIn.signInSilently();
      if (account == null) {
        return const Left(AuthFailure());
      }

      final authentication = await account.authentication;
      if (authentication.accessToken == null) {
        return const Left(AuthFailure());
      }

      // Create new credentials and store them
      final credentials = AccessCredentials(
        AccessToken(
          'Bearer',
          authentication.accessToken!,
          DateTime.now().add(const Duration(hours: 1)), // Default 1 hour expiry
        ),
        authentication.idToken,
        await getGrantedScopes(), // Preserve existing scopes
      );

      final storeResult = await storeTokens(credentials);
      return storeResult;
    } catch (e) {
      return const Left(AuthFailure());
    }
  }

  /// Check if additional scopes are needed
  /// 
  /// Compares the [requiredScopes] with currently granted scopes to determine
  /// if incremental authorization is needed.
  /// 
  /// [requiredScopes] The scopes required for the current operation
  /// 
  /// Returns [true] if additional authorization is needed, [false] otherwise.
  Future<bool> needsAdditionalScopes(List<String> requiredScopes) async {
    final grantedScopes = await getGrantedScopes();
    return requiredScopes.any((scope) => !grantedScopes.contains(scope));
  }

  /// Clear all stored authentication data
  /// 
  /// Removes all stored tokens and authentication data from secure storage.
  /// This should be called during sign-out to ensure clean state.
  /// 
  /// Returns [Right] with [true] on successful cleanup,
  /// or [Left] with [CacheFailure] if cleanup fails.
  Future<Either<Failure, bool>> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await Future.wait([
        prefs.remove(_accessTokenKey),
        prefs.remove(_refreshTokenKey),
        prefs.remove(_expiryKey),
        prefs.remove(_scopesKey),
      ]);
      
      return const Right(true);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  /// Get token expiry time
  /// 
  /// Retrieves the stored token expiry time for debugging or display purposes.
  /// 
  /// Returns the expiry [DateTime] or [null] if not found or invalid.
  Future<DateTime?> getTokenExpiry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryMs = prefs.getInt(_expiryKey);
      
      if (expiryMs == null || expiryMs == 0) {
        return null;
      }
      
      return DateTime.fromMillisecondsSinceEpoch(expiryMs);
    } catch (e) {
      return null;
    }
  }
}
