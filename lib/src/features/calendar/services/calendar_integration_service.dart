import 'package:dartz/dartz.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/errors/exceptions.dart';
import 'package:planning/src/features/calendar/data/datasources/google_calendar_datasource_impl.dart';
import 'package:planning/src/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';

/// Integration service that combines Google authentication with calendar operations
/// 
/// This service bridges the gap between GoogleAuthService and calendar operations,
/// providing a high-level interface for authenticated calendar functionality.
/// 
/// REFACTORED: Improved error handling and architecture during TDD REFACTOR phase.
/// Now follows the established patterns used throughout the application.
class CalendarIntegrationService {
  final CalendarRepository repository;

  CalendarIntegrationService({required this.repository});

  /// Factory constructor to create CalendarIntegrationService from authenticated CalendarApi
  /// 
  /// This method implements the integration layer that was missing between
  /// authentication and calendar operations.
  /// 
  /// REFACTORED: Improved error handling and validation during TDD REFACTOR phase.
  static CalendarIntegrationService fromCalendarApi(calendar.CalendarApi calendarApi) {
    final datasource = GoogleCalendarDatasourceImpl(calendarApi: calendarApi);
    final repository = CalendarRepositoryImpl(datasource: datasource);
    
    return CalendarIntegrationService(repository: repository);
  }

  /// Create a calendar event
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
    return repository.createEvent(event: event, calendarId: calendarId);
  }

  /// Get calendar events within a time range
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
    return repository.getEvents(
      timeMin: timeMin,
      timeMax: timeMax,
      calendarId: calendarId,
      maxResults: maxResults,
    );
  }

  /// Update an existing calendar event
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
    return repository.updateEvent(event: event, calendarId: calendarId);
  }

  /// Delete a calendar event
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
    return repository.deleteEvent(eventId: eventId, calendarId: calendarId);
  }
}
