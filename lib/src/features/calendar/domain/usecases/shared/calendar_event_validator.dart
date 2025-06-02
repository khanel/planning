import 'package:planning/src/core/errors/failures.dart';
import '../../entities/calendar_event.dart';

/// Shared validation logic for calendar events
/// 
/// This class centralizes common validation rules used across
/// different calendar use cases to promote code reuse and consistency.
class CalendarEventValidator {
  /// Validates common calendar event properties
  /// 
  /// Returns null if validation passes, otherwise returns a ValidationFailure
  static ValidationFailure? validateEvent(CalendarEvent event, {bool requireId = false}) {
    // Check if ID is required and not empty
    if (requireId && event.id.trim().isEmpty) {
      return const ValidationFailure('Event ID cannot be empty');
    }

    // Check if title is not empty after trimming
    if (event.title.trim().isEmpty) {
      return const ValidationFailure('Event title cannot be empty');
    }

    // Check if end time is after start time for non-all-day events
    if (!event.isAllDay && event.endTime.isBefore(event.startTime)) {
      return const ValidationFailure('End time must be after start time');
    }

    return null; // No validation errors
  }

  /// Validates calendar ID parameter
  /// 
  /// Returns null if validation passes, otherwise returns a ValidationFailure
  static ValidationFailure? validateCalendarId(String calendarId) {
    if (calendarId.trim().isEmpty) {
      return const ValidationFailure('Calendar ID cannot be empty');
    }
    return null;
  }

  /// Validates event ID parameter
  /// 
  /// Returns null if validation passes, otherwise returns a ValidationFailure
  static ValidationFailure? validateEventId(String eventId) {
    if (eventId.trim().isEmpty) {
      return const ValidationFailure('Event ID cannot be empty');
    }
    return null;
  }

  /// Creates a normalized calendar event with trimmed title
  /// 
  /// This ensures consistent data normalization across use cases
  static CalendarEvent normalizeEvent(CalendarEvent event) {
    return CalendarEvent(
      id: event.id,
      title: event.title.trim(),
      description: event.description,
      startTime: event.startTime,
      endTime: event.endTime,
      isAllDay: event.isAllDay,
      calendarId: event.calendarId,
      googleEventId: event.googleEventId,
    );
  }
}
