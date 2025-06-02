import 'package:googleapis/calendar/v3.dart';
import 'package:planning/src/features/calendar/data/datasources/google_calendar_datasource.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';

/// Custom exceptions for Google Calendar datasource operations
class GoogleCalendarException implements Exception {
  final String message;
  final String operation;
  final dynamic originalError;

  const GoogleCalendarException({
    required this.message,
    required this.operation,
    this.originalError,
  });

  @override
  String toString() => 'GoogleCalendarException [$operation]: $message';
}

/// Implementation of GoogleCalendarDatasource that interacts with Google Calendar API
/// 
/// This class provides a clean interface to Google Calendar API operations,
/// handling data conversion between domain entities and Google API models.
class GoogleCalendarDatasourceImpl implements GoogleCalendarDatasource {
  final CalendarApi calendarApi;

  // Constants for better maintainability
  static const String _primaryCalendar = 'primary';
  static const String _notFoundError = 'notFound';
  static const String _notFoundHttpError = '404';
  
  // Default values for missing data
  static const String _defaultEventTitle = 'Untitled Event';
  static const String _defaultEventDescription = '';
  static const String _defaultEventId = '';

  GoogleCalendarDatasourceImpl({required this.calendarApi});

  @override
  Future<List<CalendarEvent>> getEvents({
    required DateTime timeMin,
    required DateTime timeMax,
    String? calendarId,
    int? maxResults,
  }) async {
    return _executeWithErrorHandling(
      operation: 'getEvents',
      action: () async {
        final events = await calendarApi.events.list(
          calendarId ?? _primaryCalendar,
          timeMin: timeMin,
          timeMax: timeMax,
          maxResults: maxResults,
        );

        return _convertEventsList(events);
      },
    );
  }

  @override
  Future<CalendarEvent> createEvent({
    required CalendarEvent event,
    required String calendarId,
  }) async {
    return _executeWithErrorHandling(
      operation: 'createEvent',
      action: () async {
        final googleEvent = _convertToGoogleEvent(event);
        final createdEvent = await calendarApi.events.insert(googleEvent, calendarId);
        return _convertToCalendarEvent(createdEvent);
      },
    );
  }

  @override
  Future<CalendarEvent> updateEvent({
    required CalendarEvent event,
    required String calendarId,
  }) async {
    _validateEventForUpdate(event);
    
    return _executeWithErrorHandling(
      operation: 'updateEvent',
      action: () async {
        final googleEvent = _convertToGoogleEvent(event);
        final updatedEvent = await calendarApi.events.update(
          googleEvent,
          calendarId,
          event.googleEventId!,
        );
        return _convertToCalendarEvent(updatedEvent);
      },
    );
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
      if (_isNotFoundError(e)) {
        return false;
      }
      throw GoogleCalendarException(
        message: 'Failed to delete event: $e',
        operation: 'deleteEvent',
        originalError: e,
      );
    }
  }

  /// Converts a Google Calendar Event to our domain CalendarEvent
  CalendarEvent _convertToCalendarEvent(Event googleEvent) {
    return CalendarEvent(
      id: googleEvent.id ?? _defaultEventId,
      title: googleEvent.summary ?? _defaultEventTitle,
      description: googleEvent.description ?? _defaultEventDescription,
      startTime: _extractDateTime(googleEvent.start) ?? _getDefaultStartTime(),
      endTime: _extractDateTime(googleEvent.end) ?? _getDefaultEndTime(),
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

  /// Executes an operation with consistent error handling
  Future<T> _executeWithErrorHandling<T>({
    required String operation,
    required Future<T> Function() action,
  }) async {
    try {
      return await action();
    } catch (e) {
      throw GoogleCalendarException(
        message: 'Failed to $operation: $e',
        operation: operation,
        originalError: e,
      );
    }
  }

  /// Converts Google Calendar Events list to domain CalendarEvent list
  List<CalendarEvent> _convertEventsList(Events events) {
    if (events.items == null || events.items!.isEmpty) {
      return [];
    }
    return events.items!
        .map((googleEvent) => _convertToCalendarEvent(googleEvent))
        .toList();
  }

  /// Validates that an event has required fields for update operation
  void _validateEventForUpdate(CalendarEvent event) {
    if (event.googleEventId == null || event.googleEventId!.isEmpty) {
      throw GoogleCalendarException(
        message: 'Event must have a valid googleEventId for update operation',
        operation: 'updateEvent',
      );
    }
  }

  /// Checks if an error is a "not found" error
  bool _isNotFoundError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains(_notFoundError) || 
           errorString.contains(_notFoundHttpError);
  }
  
  /// Extracts DateTime from EventDateTime, handling both dateTime and date fields
  DateTime? _extractDateTime(EventDateTime? eventDateTime) {
    if (eventDateTime?.dateTime != null) {
      return eventDateTime!.dateTime;
    }
    if (eventDateTime?.date != null) {
      return eventDateTime!.date;
    }
    return null;
  }
  
  /// Gets a sensible default start time (current time)
  DateTime _getDefaultStartTime() => DateTime.now();
  
  /// Gets a sensible default end time (current time + 1 hour)
  DateTime _getDefaultEndTime() => DateTime.now().add(const Duration(hours: 1));
}
