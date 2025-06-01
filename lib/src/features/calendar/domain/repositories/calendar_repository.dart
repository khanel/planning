import 'package:dartz/dartz.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';

/// Repository interface for calendar operations
abstract class CalendarRepository {
  /// Get all calendar events within a date range
  Future<Either<Failure, List<CalendarEvent>>> getEvents({
    required DateTime timeMin,
    required DateTime timeMax,
    String? calendarId,
    int? maxResults,
  });

  /// Create a new calendar event
  Future<Either<Failure, CalendarEvent>> createEvent({
    required CalendarEvent event,
    required String calendarId,
  });

  /// Update an existing calendar event
  Future<Either<Failure, CalendarEvent>> updateEvent({
    required CalendarEvent event,
    required String calendarId,
  });

  /// Delete a calendar event by ID
  Future<Either<Failure, bool>> deleteEvent({
    required String eventId,
    required String calendarId,
  });
}
