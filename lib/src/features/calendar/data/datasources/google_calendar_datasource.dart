import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';

/// Data source interface for Google Calendar API operations
abstract class GoogleCalendarDatasource {
  /// Get calendar events from Google Calendar API
  Future<List<CalendarEvent>> getEvents({
    required DateTime timeMin,
    required DateTime timeMax,
    String? calendarId,
    int? maxResults,
  });

  /// Create a new event in Google Calendar
  Future<CalendarEvent> createEvent({
    required CalendarEvent event,
    required String calendarId,
  });

  /// Update an existing event in Google Calendar
  Future<CalendarEvent> updateEvent({
    required CalendarEvent event,
    required String calendarId,
  });

  /// Delete an event from Google Calendar
  Future<bool> deleteEvent({
    required String eventId,
    required String calendarId,
  });
}
