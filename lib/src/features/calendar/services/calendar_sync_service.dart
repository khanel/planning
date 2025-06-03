import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';

/// Service for handling calendar synchronization with Google Calendar
/// 
/// This service provides OAuth authentication, token management, and calendar
/// synchronization capabilities following Google Calendar API best practices.
/// 
/// Implements incremental and full sync strategies with proper error handling
/// and token management for efficient calendar data synchronization.
/// 
/// REFACTORED: Enhanced with constants, extracted error handling, and improved architecture
class CalendarSyncService {
  final GoogleSignIn googleSignIn;
  final calendar.CalendarApi calendarApi;
  
  /// Storage for sync token to enable incremental synchronization
  String? _syncToken;
  
  /// Storage for last sync timestamp
  DateTime? _lastSyncTime;

  // REFACTOR: Extracted constants for better maintainability
  static const String _calendarScope = 'https://www.googleapis.com/auth/calendar';
  static const String _primaryCalendarId = 'primary';
  static const int _defaultSyncRangeDays = 30;
  static const int _defaultFutureRangeDays = 365;

  CalendarSyncService({
    required this.googleSignIn,
    required this.calendarApi,
  });

  /// Authenticate with Google and request calendar access
  /// 
  /// Returns [Right] with [true] on successful authentication,
  /// or [Left] with [AuthFailure] on authentication failure.
  Future<Either<Failure, bool>> authenticate() async {
    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        return const Left(AuthFailure());
      }

      final auth = await account.authentication;
      if (auth.accessToken == null) {
        return const Left(AuthFailure());
      }

      final scopeGranted = await googleSignIn.requestScopes([_calendarScope]);
      
      if (!scopeGranted) {
        return const Left(AuthFailure());
      }

      return const Right(true);
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  /// Check if user is currently authenticated
  /// 
  /// Returns [true] if user is signed in and has valid token.
  Future<bool> isAuthenticated() async {
    try {
      final isSignedIn = await googleSignIn.isSignedIn();
      if (!isSignedIn) return false;

      final user = googleSignIn.currentUser;
      if (user == null) return false;

      final auth = await user.authentication;
      return auth.accessToken != null;
    } catch (e) {
      return false;
    }
  }

  /// Refresh authentication token when expired
  /// 
  /// Returns [Right] with [true] on successful refresh,
  /// or [Left] with [AuthFailure] on failure.
  Future<Either<Failure, bool>> refreshToken() async {
    try {
      final account = await googleSignIn.signInSilently();
      if (account == null) {
        return const Left(AuthFailure());
      }

      final auth = await account.authentication;
      if (auth.accessToken == null) {
        return const Left(AuthFailure());
      }

      return const Right(true);
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  /// Perform full calendar synchronization
  /// 
  /// Returns [Right] with list of [CalendarEvent] on success,
  /// or [Left] with [Failure] on error.
  Future<Either<Failure, List<CalendarEvent>>> performFullSync() async {
    try {
      final events = calendarApi.events;
      final eventsList = await events.list(
        _primaryCalendarId,
        timeMin: _getDefaultStartTime(),
        timeMax: _getDefaultEndTime(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      final calendarEvents = _convertEventsList(eventsList.items ?? []);

      // Store sync token for future incremental syncs
      if (eventsList.nextSyncToken != null) {
        _syncToken = eventsList.nextSyncToken;
      }

      return Right(calendarEvents);
    } catch (e) {
      return _handleSyncError(e);
    }
  }

  /// Perform incremental synchronization using sync token
  /// 
  /// [syncToken] The sync token from the last synchronization
  /// 
  /// Returns [Right] with list of updated [CalendarEvent] on success,
  /// or [Left] with [Failure] on error.
  Future<Either<Failure, List<CalendarEvent>>> performIncrementalSync(String syncToken) async {
    try {
      final events = calendarApi.events;
      final eventsList = await events.list(
        _primaryCalendarId,
        syncToken: syncToken,
        showDeleted: true,
      );

      final calendarEvents = _convertEventsList(eventsList.items ?? []);

      // Store new sync token
      if (eventsList.nextSyncToken != null) {
        _syncToken = eventsList.nextSyncToken;
      }

      return Right(calendarEvents);
    } catch (e) {
      return _handleIncrementalSyncError(e);
    }
  }

  /// Store sync token for future incremental synchronization
  /// 
  /// [syncToken] The sync token to store
  Future<void> storeSyncToken(String syncToken) async {
    _syncToken = syncToken;
  }

  /// Get stored sync token
  /// 
  /// Returns the stored sync token or null if not available.
  Future<String?> getSyncToken() async {
    return _syncToken;
  }

  /// Clear stored sync token to force full sync
  Future<void> clearSyncToken() async {
    _syncToken = null;
  }

  /// Update last sync timestamp
  /// 
  /// [timestamp] The timestamp to store
  Future<void> updateLastSyncTime(DateTime timestamp) async {
    _lastSyncTime = timestamp;
  }

  /// Get last sync timestamp
  /// 
  /// Returns the last sync timestamp or null if never synced.
  Future<DateTime?> getLastSyncTime() async {
    return _lastSyncTime;
  }

  // REFACTOR: Extracted helper methods for better code organization and maintainability

  /// Get default start time for sync operations
  DateTime _getDefaultStartTime() {
    return DateTime.now().subtract(Duration(days: _defaultSyncRangeDays));
  }

  /// Get default end time for sync operations  
  DateTime _getDefaultEndTime() {
    return DateTime.now().add(Duration(days: _defaultFutureRangeDays));
  }

  /// Convert list of Google Calendar events to domain CalendarEvents
  List<CalendarEvent> _convertEventsList(List<calendar.Event> events) {
    return events.map((event) => _convertToCalendarEvent(event)).toList();
  }

  /// Handle authentication errors with proper error mapping
  Either<Failure, bool> _handleAuthError(Object error) {
    // Log error details in production, this would use a proper logger
    return const Left(AuthFailure());
  }

  /// Handle sync operation errors with specific error mapping
  Either<Failure, List<CalendarEvent>> _handleSyncError(Object error) {
    final errorString = error.toString();
    if (errorString.contains('Authentication') || errorString.contains('401')) {
      return const Left(AuthFailure());
    }
    return const Left(NetworkFailure());
  }

  /// Handle incremental sync errors with sync token invalidation detection
  Either<Failure, List<CalendarEvent>> _handleIncrementalSyncError(Object error) {
    final errorString = error.toString();
    if (errorString.contains('invalid') || errorString.contains('410')) {
      return const Left(ServerFailure());
    }
    return const Left(NetworkFailure());
  }

  /// Convert Google Calendar Event to domain CalendarEvent
  CalendarEvent _convertToCalendarEvent(calendar.Event event) {
    return CalendarEvent(
      id: event.id ?? 'unknown',
      title: event.summary ?? 'Untitled Event',
      description: event.description ?? '',
      startTime: event.start?.dateTime ?? DateTime.now(),
      endTime: event.end?.dateTime ?? DateTime.now().add(const Duration(hours: 1)),
      isAllDay: event.start?.date != null,
    );
  }
}
