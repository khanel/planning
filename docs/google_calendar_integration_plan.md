# Google Calendar Integration Plan for Flutter Mobile App
## 2024/2025 Best Practices & Implementation Guide

### Executive Summary

This document provides a comprehensive implementation plan for integrating Google Calendar API into a Flutter mobile application, incorporating the latest security best practices, OAuth 2.0 requirements, and modern authentication patterns for 2024/2025.

## 1. Authentication Strategy

### 1.1 OAuth 2.0 with PKCE (Proof Key for Code Exchange)

**Implementation Requirements:**
- **PKCE is mandatory** for all mobile applications as of 2024
- Use S256 code challenge method (SHA256 hash)
- Implement proper code verifier generation (43-128 character URL-safe string)
- Support both Android and iOS platform-specific requirements

**Security Enhancements:**
- **iOS**: Implement App Check for enhanced security validation
- **Android**: Configure app ownership verification through Play Console
- **Cross-Account Protection (RISC)**: Implement security event notifications for compromised accounts

### 1.2 Redirect URI Configuration

**Recommended Approaches:**
1. **Custom URI Schemes**: `com.yourapp.planning://oauth/callback`
2. **Loopback IP Addresses**: `http://127.0.0.1:PORT/auth` (Android only)
3. **App Links/Universal Links**: For production applications

**Deprecated Methods (Do Not Use):**
- Out-of-band (OOB) flow
- Manual copy/paste of authorization codes
- Embedded WebViews for OAuth flows

## 2. Google Calendar API Integration

### 2.1 API Scope Selection

Choose the minimal required scopes for your use case:

```
https://www.googleapis.com/auth/calendar                    # Full calendar access
https://www.googleapis.com/auth/calendar.events           # Read/write events
https://www.googleapis.com/auth/calendar.events.readonly  # Read-only events
https://www.googleapis.com/auth/calendar.readonly         # Read-only calendar
https://www.googleapis.com/auth/calendar.settings.readonly # Read calendar settings
```

**Recommendation**: Start with `calendar.events.readonly` and use incremental authorization to request additional scopes as needed.

### 2.2 API Resources Overview

**Primary Resources:**
- **Events**: Create, read, update, delete calendar events
- **Calendars**: Manage calendar metadata and settings
- **CalendarList**: User's calendar list with access control
- **Settings**: User preferences and configuration
- **ACL**: Access control for calendar sharing

## 3. Flutter Package Recommendations

### 3.1 Core Packages

```yaml
dependencies:
  googleapis: ^14.0.0           # Google APIs client library
  google_sign_in: ^6.3.0       # Authentication & sign-in
  http: ^1.0.0                  # HTTP client for API calls
  crypto: ^3.0.3                # PKCE code generation
  url_launcher: ^6.2.0          # Handle OAuth redirects
```

### 3.2 Package Analysis

**googleapis (v14.0.0)**
- ✅ Auto-generated client for 200+ Google APIs
- ✅ Full Calendar API v3 support
- ✅ Type-safe API calls with proper error handling
- ✅ Supports all Calendar API resources and methods

**google_sign_in (v6.3.0)**
- ✅ Secure OAuth 2.0 implementation
- ✅ Incremental authorization support
- ✅ Cross-platform (Android/iOS) compatibility
- ✅ Built-in token refresh handling
- ✅ Proper scope management

## 4. Implementation Architecture

### 4.1 Service Layer Structure

```
lib/
├── src/
│   ├── core/
│   │   ├── auth/
│   │   │   ├── google_auth_service.dart
│   │   │   ├── oauth_config.dart
│   │   │   └── token_manager.dart
│   │   └── network/
│   │       ├── api_client.dart
│   │       └── error_handler.dart
│   └── features/
│       └── calendar/
│           ├── data/
│           │   ├── repositories/
│           │   │   └── calendar_repository_impl.dart
│           │   └── datasources/
│           │       └── google_calendar_datasource.dart
│           ├── domain/
│           │   ├── entities/
│           │   │   └── calendar_event.dart
│           │   ├── repositories/
│           │   │   └── calendar_repository.dart
│           │   └── usecases/
│           │       ├── get_events.dart
│           │       ├── create_event.dart
│           │       └── sync_calendar.dart
│           └── presentation/
│               ├── bloc/
│               │   └── calendar_bloc.dart
│               └── widgets/
│                   └── calendar_view.dart
```

### 4.2 Authentication Flow Implementation

```dart
// Core authentication service
class GoogleAuthService {
  final GoogleSignIn _googleSignIn;
  final CalendarApi _calendarApi;

  Future<bool> signIn({required List<String> scopes}) async {
    try {
      // Configure OAuth with PKCE
      final account = await _googleSignIn.signIn();
      if (account == null) return false;

      // Request Calendar API scopes
      await _requestCalendarScopes(scopes);
      
      // Initialize Calendar API client
      await _initializeCalendarApi(account);
      
      return true;
    } catch (e) {
      _handleAuthError(e);
      return false;
    }
  }

  Future<void> _requestCalendarScopes(List<String> scopes) async {
    final currentScopes = await _googleSignIn.requestScopes(scopes);
    if (!currentScopes) {
      throw AuthException('Required scopes not granted');
    }
  }
}
```

## 5. Security Implementation

### 5.1 PKCE Implementation

```dart
class PKCEHelper {
  static String generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static String generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
}
```

### 5.2 Token Management

```dart
class TokenManager {
  static const String _accessTokenKey = 'google_access_token';
  static const String _refreshTokenKey = 'google_refresh_token';
  static const String _expiryKey = 'token_expiry';

  Future<void> storeTokens(AccessToken token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token.data);
    await prefs.setString(_refreshTokenKey, token.refreshToken ?? '');
    await prefs.setInt(_expiryKey, token.expiry?.millisecondsSinceEpoch ?? 0);
  }

  Future<bool> isTokenValid() async {
    final expiry = await _getTokenExpiry();
    return expiry != null && expiry.isAfter(DateTime.now());
  }

  Future<void> refreshToken() async {
    // Implement token refresh logic
    try {
      final newToken = await _googleSignIn.signInSilently();
      if (newToken?.authentication != null) {
        await storeTokens(newToken!.authentication);
      }
    } catch (e) {
      // Handle refresh failure - require re-authentication
      await signOut();
    }
  }
}
```

## 6. Platform-Specific Configuration

### 6.1 Android Configuration

**android/app/build.gradle.kts:**
```kotlin
android {
    defaultConfig {
        // Minimum API level for AppAuth
        minSdk = 16
    }
}

dependencies {
    implementation 'net.openid:appauth:0.11.1'
}
```

**android/app/src/main/AndroidManifest.xml:**
```xml
<application>
    <!-- OAuth redirect handling -->
    <activity
        android:name="com.google.android.gms.auth.api.signin.RevocationBoundService"
        android:exported="true"
        android:permission="com.google.android.gms.auth.api.signin.permission.REVOCATION_NOTIFICATION" />
    
    <!-- Custom scheme handling -->
    <activity
        android:name=".OAuthCallbackActivity"
        android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="com.yourapp.planning" />
        </intent-filter>
    </activity>
</application>
```

### 6.2 iOS Configuration

**ios/Runner/Info.plist:**
```xml
<dict>
    <!-- OAuth URL schemes -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>google-oauth</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.yourapp.planning</string>
            </array>
        </dict>
    </array>
    
    <!-- App Transport Security -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
    </dict>
</dict>
```

## 7. API Usage Patterns

### 7.1 Event Management

```dart
class CalendarRepository {
  final CalendarApi _api;

  Future<List<Event>> getEvents({
    String? calendarId,
    DateTime? timeMin,
    DateTime? timeMax,
    int maxResults = 100,
  }) async {
    try {
      final events = await _api.events.list(
        calendarId ?? 'primary',
        timeMin: timeMin,
        timeMax: timeMax,
        maxResults: maxResults,
        singleEvents: true,
        orderBy: 'startTime',
      );
      
      return events.items ?? [];
    } catch (e) {
      throw CalendarException('Failed to fetch events: $e');
    }
  }

  Future<Event> createEvent(Event event, {String? calendarId}) async {
    try {
      return await _api.events.insert(event, calendarId ?? 'primary');
    } catch (e) {
      throw CalendarException('Failed to create event: $e');
    }
  }

  Future<Event> updateEvent(Event event, {String? calendarId}) async {
    try {
      return await _api.events.update(
        event, 
        calendarId ?? 'primary', 
        event.id!
      );
    } catch (e) {
      throw CalendarException('Failed to update event: $e');
    }
  }
}
```

### 7.2 Sync Strategy

```dart
class CalendarSyncService {
  static const String _syncTokenKey = 'calendar_sync_token';

  Future<SyncResult> syncEvents() async {
    try {
      final syncToken = await _getSyncToken();
      
      final request = await _api.events.list(
        'primary',
        syncToken: syncToken,
        showDeleted: true,
      );

      await _processSyncEvents(request.items ?? []);
      await _storeSyncToken(request.nextSyncToken);
      
      return SyncResult.success(request.items?.length ?? 0);
    } catch (e) {
      if (e is DetailedApiRequestError && e.status == 410) {
        // Sync token invalid - perform full sync
        return await _performFullSync();
      }
      throw CalendarException('Sync failed: $e');
    }
  }
}
```

## 8. Error Handling & Resilience

### 8.1 Common Error Scenarios

```dart
class CalendarErrorHandler {
  static void handleApiError(dynamic error) {
    if (error is DetailedApiRequestError) {
      switch (error.status) {
        case 401:
          // Token expired - trigger re-authentication
          _handleAuthenticationError();
          break;
        case 403:
          // Insufficient permissions - request additional scopes
          _handlePermissionError();
          break;
        case 429:
          // Rate limit exceeded - implement exponential backoff
          _handleRateLimitError();
          break;
        case 404:
          // Resource not found
          _handleNotFoundError();
          break;
        default:
          _handleGenericError(error);
      }
    }
  }
}
```

### 8.2 Offline Support

```dart
class OfflineCalendarService {
  final DatabaseHelper _db;
  final CalendarRepository _repository;

  Future<List<Event>> getCachedEvents() async {
    return await _db.getEvents();
  }

  Future<void> queueOfflineAction(OfflineAction action) async {
    await _db.insertAction(action);
  }

  Future<void> syncOfflineActions() async {
    final actions = await _db.getPendingActions();
    
    for (final action in actions) {
      try {
        await _executeAction(action);
        await _db.markActionCompleted(action.id);
      } catch (e) {
        // Handle sync conflicts
        await _handleSyncConflict(action, e);
      }
    }
  }
}
```

## 9. Privacy & Compliance

### 9.1 Data Handling

- **Minimal Data Collection**: Only request necessary Calendar scopes
- **Local Storage**: Use secure storage for tokens and cached data
- **Data Retention**: Implement automatic cleanup of cached calendar data
- **User Consent**: Clear privacy disclosure for Calendar access

### 9.2 GDPR Compliance

```dart
class PrivacyManager {
  Future<void> handleDataDeletion() async {
    // Clear all cached calendar data
    await _db.clearAllCalendarData();
    
    // Revoke OAuth tokens
    await _authService.revokeTokens();
    
    // Clear local preferences
    await _clearUserPreferences();
  }

  Future<Map<String, dynamic>> exportUserData() async {
    return {
      'calendar_events': await _db.getEvents(),
      'sync_preferences': await _getPreferences(),
      'last_sync': await _getLastSyncTime(),
    };
  }
}
```

## 10. Testing Strategy

### 10.1 Unit Tests

```dart
// Test authentication flow
testWidgets('Google Auth flow completes successfully', (tester) async {
  final mockAuthService = MockGoogleAuthService();
  when(mockAuthService.signIn(scopes: anyNamed('scopes')))
      .thenAnswer((_) async => true);

  final app = TestApp(authService: mockAuthService);
  await tester.pumpWidget(app);
  
  await tester.tap(find.byKey(const Key('sign_in_button')));
  await tester.pumpAndSettle();
  
  verify(mockAuthService.signIn(scopes: CalendarScopes.readonly)).called(1);
});
```

### 10.2 Integration Tests

```dart
// Test Calendar API integration
group('Calendar API Integration', () {
  late CalendarRepository repository;
  
  setUp(() {
    repository = CalendarRepository(
      api: CalendarApi(authenticatedClient),
    );
  });

  test('fetches events successfully', () async {
    final events = await repository.getEvents(
      timeMin: DateTime.now(),
      timeMax: DateTime.now().add(const Duration(days: 7)),
    );
    
    expect(events, isA<List<Event>>());
    expect(events.length, lessThanOrEqualTo(100));
  });
});
```

## 11. Performance Optimization

### 11.1 Caching Strategy

- **Memory Cache**: Store frequently accessed events
- **Disk Cache**: Persist calendar data locally
- **Incremental Sync**: Use sync tokens for efficient updates
- **Background Sync**: Update cache during app idle time

### 11.2 Network Optimization

```dart
class ApiOptimizer {
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(seconds: 1);

  Future<T> executeWithRetry<T>(Future<T> Function() operation) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxRetries - 1) rethrow;
        
        final delay = baseDelay * pow(2, attempt);
        await Future.delayed(delay);
      }
    }
    throw Exception('Max retries exceeded');
  }
}
```

## 12. Deployment Checklist

### 12.1 Pre-Production

- [ ] OAuth consent screen configured and verified
- [ ] App signing certificates registered with Google
- [ ] Custom URI schemes configured for both platforms
- [ ] Rate limiting and quota monitoring implemented
- [ ] Error logging and crash reporting configured
- [ ] Privacy policy updated with Calendar access disclosure

### 12.2 Production Monitoring

- [ ] Authentication success/failure rates
- [ ] API request latency and error rates
- [ ] Token refresh frequency and failures
- [ ] Sync performance metrics
- [ ] User permission grant/denial rates

## 13. Future Considerations

### 13.1 Emerging Standards

- **OAuth 2.1**: Prepare for upcoming specification updates
- **Device Authorization Grant**: For IoT or limited input devices
- **Pushed Authorization Requests (PAR)**: Enhanced security for sensitive applications

### 13.2 Google Calendar API Evolution

- Monitor Google Workspace API updates
- Prepare for potential API versioning changes
- Consider Google Workspace Events API for real-time notifications

## Conclusion

This implementation plan provides a comprehensive foundation for secure, scalable Google Calendar integration in Flutter mobile applications. The architecture emphasizes security best practices, proper error handling, and user privacy while maintaining performance and reliability.

Regular updates to this plan should be made as Google's APIs and security requirements evolve. Monitor the [Google Developers Blog](https://developers.googleblog.com/) and [Workspace API updates](https://developers.google.com/workspace/releases) for the latest changes.
