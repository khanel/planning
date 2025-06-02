import 'package:googleapis/calendar/v3.dart';
import 'package:planning/src/features/calendar/data/datasources/google_calendar_datasource.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';

/// Implementation of GoogleCalendarDatasource that interacts with Google Calendar API
class GoogleCalendarDatasourceImpl implements GoogleCalendarDatasource {
  final CalendarApi calendarApi;

  GoogleCalendarDatasourceImpl({required this.calendarApi});

  @override
  Future<List<CalendarEvent>> getEvents({
    required DateTime timeMin,
    required DateTime timeMax,
    String? calendarId,
    int? maxResults,
  }) async {
    try {
      final events = await calendarApi.events.list(
        calendarId ?? 'primary',
        timeMin: timeMin,
        timeMax: timeMax,
        maxResults: maxResults,
      );

      if (events.items == null || events.items!.isEmpty) {
        return [];
      }

      return events.items!.map((googleEvent) => _convertToCalendarEvent(googleEvent)).toList();
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  @override
  Future<CalendarEvent> createEvent({
    required CalendarEvent event,
    required String calendarId,
  }) async {
    try {
      final googleEvent = _convertToGoogleEvent(event);
      final createdEvent = await calendarApi.events.insert(googleEvent, calendarId);
      return _convertToCalendarEvent(createdEvent);
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  @override
  Future<CalendarEvent> updateEvent({
    required CalendarEvent event,
    required String calendarId,
  }) async {
    try {
      final googleEvent = _convertToGoogleEvent(event);
      final updatedEvent = await calendarApi.events.update(
        googleEvent,
        calendarId,
        event.googleEventId!,
      );
      return _convertToCalendarEvent(updatedEvent);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  @override
  Future<bool> deleteEvent({
    required String eventId,
    required String calendarId,
  }) async {
    try {
      await calendarApi.events.delete(calendarId, eventId);
      return true;
    } catch (e) {
      if (e.toString().contains('notFound') || e.toString().contains('404')) {
        return false;
      }
      throw Exception('Failed to delete event: $e');
    }
  }

  /// Converts a Google Calendar Event to our domain CalendarEvent
  CalendarEvent _convertToCalendarEvent(Event googleEvent) {
    return CalendarEvent(
      id: googleEvent.id ?? '',
      title: googleEvent.summary ?? '',
      description: googleEvent.description ?? '',
      startTime: googleEvent.start?.dateTime ?? DateTime.now(),
      endTime: googleEvent.end?.dateTime ?? DateTime.now(),
      isAllDay: googleEvent.start?.date != null,
      googleEventId: googleEvent.id,
    );
  }

  /// Converts our domain CalendarEvent to a Google Calendar Event
  Event _convertToGoogleEvent(CalendarEvent event) {
    final googleEvent = Event();
    googleEvent.id = event.googleEventId;
    googleEvent.summary = event.title;
    googleEvent.description = event.description;

    final startDateTime = EventDateTime();
    startDateTime.dateTime = event.startTime;
    googleEvent.start = startDateTime;

    final endDateTime = EventDateTime();
    endDateTime.dateTime = event.endTime;
    googleEvent.end = endDateTime;

    return googleEvent;
  }
}
