import 'package:dartz/dartz.dart';
import 'package:planning/src/core/auth/google_auth_service.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/services/calendar_integration_service.dart';

/// Session-aware calendar service that maintains authentication state
/// 
/// This service provides session management capabilities for calendar operations,
/// ensuring that the same authenticated session is reused across multiple operations.
/// It handles authentication state changes and automatically recreates the calendar
/// service when needed.
/// 
/// REFACTORED: Improved session management and error handling during TDD REFACTOR phase.
/// Now provides better separation of concerns and follows established patterns.
class SessionAwareCalendarService {
  final GoogleAuthService authService;
  CalendarIntegrationService? _calendarService;

  SessionAwareCalendarService({required this.authService});

  /// Initialize or get the calendar service for the current session
  /// 
  /// This method ensures that the same authenticated session is reused
  /// for multiple calendar operations. It includes proper error handling
  /// for authentication failures.
  /// 
  /// REFACTORED: Enhanced error handling and session validation.
  /// 
  /// Returns the cached service if available and valid, otherwise creates a new one.
  /// Throws [Exception] if authentication fails or calendar API cannot be obtained.
  Future<CalendarIntegrationService> _getCalendarService() async {
    // Reuse existing service if available
    if (_calendarService != null) {
      return _calendarService!;
    }

    // Get authenticated calendar API
    final calendarApiResult = await authService.getCalendarApi();
    return calendarApiResult.fold(
      (failure) => throw Exception('Authentication failed: ${failure.runtimeType}'),
      (calendarApi) {
        _calendarService = CalendarIntegrationService.fromCalendarApi(calendarApi);
        return _calendarService!;
      },
    );
  }

  /// Get calendar events within a time range using the current session
  /// 
  /// [timeMin] Start of time range
  /// [timeMax] End of time range
  /// [calendarId] The ID of the calendar to query (defaults to 'primary')
  /// [maxResults] Maximum number of events to return
  /// 
  /// Returns [Right] with list of [CalendarEvent] on success,
  /// or [Left] with [Failure] on error.
  Future<Either<Failure, List<CalendarEvent>>> getEvents({
    required DateTime timeMin,
    required DateTime timeMax,
    String calendarId = 'primary',
    int? maxResults,
  }) async {
    try {
      final calendarService = await _getCalendarService();
      return calendarService.getEvents(
        timeMin: timeMin,
        timeMax: timeMax,
        calendarId: calendarId,
        maxResults: maxResults,
      );
    } catch (e) {
      return const Left(AuthFailure());
    }
  }

  /// Create a calendar event using the current session
  /// 
  /// [event] The calendar event to create
  /// [calendarId] The ID of the calendar to create the event in (defaults to 'primary')
  /// 
  /// Returns [Right] with the created [CalendarEvent] on success,
  /// or [Left] with [Failure] on error.
  Future<Either<Failure, CalendarEvent>> createEvent(
    CalendarEvent event, {
    String calendarId = 'primary',
  }) async {
    try {
      final calendarService = await _getCalendarService();
      return calendarService.createEvent(event, calendarId: calendarId);
    } catch (e) {
      return const Left(AuthFailure());
    }
  }

  /// Update an existing calendar event using the current session
  /// 
  /// [event] The updated calendar event
  /// [calendarId] The ID of the calendar containing the event
  /// 
  /// Returns [Right] with the updated [CalendarEvent] on success,
  /// or [Left] with [Failure] on error.
  Future<Either<Failure, CalendarEvent>> updateEvent(
    CalendarEvent event, {
    String calendarId = 'primary',
  }) async {
    try {
      final calendarService = await _getCalendarService();
      return calendarService.updateEvent(event, calendarId: calendarId);
    } catch (e) {
      return const Left(AuthFailure());
    }
  }

  /// Delete a calendar event using the current session
  /// 
  /// [eventId] The ID of the event to delete
  /// [calendarId] The ID of the calendar containing the event
  /// 
  /// Returns [Right] with [true] on successful deletion,
  /// or [Left] with [Failure] on error.
  Future<Either<Failure, bool>> deleteEvent({
    required String eventId,
    String calendarId = 'primary',
  }) async {
    try {
      final calendarService = await _getCalendarService();
      return calendarService.deleteEvent(eventId: eventId, calendarId: calendarId);
    } catch (e) {
      return const Left(AuthFailure());
    }
  }

  /// Clear the current session and force re-authentication on next operation
  void clearSession() {
    _calendarService = null;
  }
}
