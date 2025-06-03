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
class CalendarSyncService {
  final GoogleSignIn googleSignIn;
  final calendar.CalendarApi calendarApi;
  
  /// Storage for sync token to enable incremental synchronization
  String? _syncToken;
  
  /// Storage for last sync timestamp
  DateTime? _lastSyncTime;

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

      final scopeGranted = await googleSignIn.requestScopes([
        'https://www.googleapis.com/auth/calendar'
      ]);
      
      if (!scopeGranted) {
        return const Left(AuthFailure());
      }

      return const Right(true);
    } catch (e) {
      return const Left(AuthFailure());
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
      return const Left(AuthFailure());
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
        'primary',
        timeMin: DateTime.now().subtract(const Duration(days: 30)),
        timeMax: DateTime.now().add(const Duration(days: 365)),
        singleEvents: true,
        orderBy: 'startTime',
      );

      final calendarEvents = <CalendarEvent>[];
      for (final event in eventsList.items ?? []) {
        calendarEvents.add(_convertToCalendarEvent(event));
      }

      // Store sync token for future incremental syncs
      if (eventsList.nextSyncToken != null) {
        _syncToken = eventsList.nextSyncToken;
      }

      return Right(calendarEvents);
    } catch (e) {
      if (e.toString().contains('Authentication') || e.toString().contains('401')) {
        return const Left(AuthFailure());
      }
      return const Left(NetworkFailure());
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
        'primary',
        syncToken: syncToken,
        showDeleted: true,
      );

      final calendarEvents = <CalendarEvent>[];
      for (final event in eventsList.items ?? []) {
        calendarEvents.add(_convertToCalendarEvent(event));
      }

      // Store new sync token
      if (eventsList.nextSyncToken != null) {
        _syncToken = eventsList.nextSyncToken;
      }

      return Right(calendarEvents);
    } catch (e) {
      if (e.toString().contains('invalid') || e.toString().contains('410')) {
        return const Left(ServerFailure());
      }
      return const Left(NetworkFailure());
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
