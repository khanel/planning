import 'package:hive/hive.dart';
import 'package:planning/src/core/errors/exceptions.dart';
import 'package:planning/src/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:planning/src/features/calendar/data/models/calendar_event_data_model.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';

/// Hive-based implementation of CalendarLocalDataSource.
/// 
/// This implementation provides persistent local storage for calendar events
/// using the Hive database, with support for efficient querying, caching,
/// and offline capabilities.
class CalendarLocalDataSourceImpl implements CalendarLocalDataSource {
  /// Creates a new CalendarLocalDataSourceImpl with the provided Hive box.
  const CalendarLocalDataSourceImpl({required this.box});

  /// The Hive box used for storing calendar events.
  final Box<CalendarEventDataModel> box;

  // Error message constants for better maintainability
  static const String _getEventsError = 'Failed to retrieve events';
  static const String _getEventByIdError = 'Failed to retrieve event by id';
  static const String _saveEventError = 'Failed to save event';
  static const String _deleteEventError = 'Failed to delete event';
  static const String _clearCacheError = 'Failed to clear all events';
  static const String _getEventsByDateRangeError = 'Failed to retrieve events by date range';
  static const String _getEventsBySyncStatusError = 'Failed to retrieve events by sync status';
  static const String _eventNotFoundError = 'Event with id';

  @override
  Future<List<CalendarEventDataModel>> getEvents() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw CacheException('$_getEventsError: $e');
    }
  }

  @override
  Future<CalendarEventDataModel> getEventById(String id) async {
    // Input validation
    if (id.isEmpty) {
      throw CacheException('$_getEventByIdError: Event ID cannot be empty');
    }

    try {
      final event = box.get(id);
      if (event == null) {
        throw CacheException('$_eventNotFoundError $id not found');
      }
      return event;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('$_getEventByIdError: $e');
    }
  }

  @override
  Future<void> saveEvent(CalendarEventDataModel event) async {
    // Validate event data before saving
    _validateEvent(event);
    
    try {
      await box.put(event.id, event);
    } catch (e) {
      throw CacheException('$_saveEventError: $e');
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    // Input validation
    if (id.isEmpty) {
      throw CacheException('$_deleteEventError: Event ID cannot be empty');
    }

    try {
      final event = box.get(id);
      if (event == null) {
        throw CacheException('$_eventNotFoundError $id not found');
      }
      await box.delete(id);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('$_deleteEventError: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await box.clear();
    } catch (e) {
      throw CacheException('$_clearCacheError: $e');
    }
  }

  @override
  Future<List<CalendarEventDataModel>> getEventsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Input validation
    if (startDate.isAfter(endDate)) {
      throw CacheException('$_getEventsByDateRangeError: Start date cannot be after end date');
    }

    try {
      final events = box.values.where((event) {
        // Improved date range logic - handles overlapping events properly
        // An event overlaps with the range if:
        // 1. Event starts before range ends AND
        // 2. Event ends after range starts
        return _eventOverlapsDateRange(event, startDate, endDate);
      }).toList();
      return events;
    } catch (e) {
      throw CacheException('$_getEventsByDateRangeError: $e');
    }
  }

  @override
  Future<List<CalendarEventDataModel>> getEventsBySyncStatus(CalendarSyncStatus syncStatus) async {
    try {
      final events = box.values.where((event) => event.syncStatus == syncStatus).toList();
      return events;
    } catch (e) {
      throw CacheException('$_getEventsBySyncStatusError: $e');
    }
  }

  /// Helper method to determine if an event overlaps with a date range.
  /// 
  /// An event overlaps with a date range if the event's time span intersects
  /// with the query range. This handles all cases including:
  /// - Events that start before and end within the range
  /// - Events that start within and end after the range  
  /// - Events that are completely within the range
  /// - Events that completely encompass the range
  bool _eventOverlapsDateRange(CalendarEventDataModel event, DateTime startDate, DateTime endDate) {
    return event.startTime.isBefore(endDate) && event.endTime.isAfter(startDate);
  }

  /// Validates that the provided event has all required fields.
  /// 
  /// Throws [CacheException] if any required field is missing or invalid.
  void _validateEvent(CalendarEventDataModel event) {
    if (event.id.isEmpty) {
      throw CacheException('$_saveEventError: Event ID cannot be empty');
    }
    if (event.title.isEmpty) {
      throw CacheException('$_saveEventError: Event title cannot be empty');  
    }
    if (event.startTime.isAfter(event.endTime)) {
      throw CacheException('$_saveEventError: Event start time cannot be after end time');
    }
  }
}
