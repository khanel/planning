import 'package:planning/src/features/calendar/data/models/calendar_event_data_model.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';

/// Abstract data source for local calendar event operations
/// 
/// This interface defines the contract for local storage operations
/// for calendar events using Hive storage.
abstract class CalendarLocalDataSource {
  /// Retrieves all calendar events from local storage
  Future<List<CalendarEventDataModel>> getEvents();

  /// Retrieves a specific calendar event by its ID
  /// 
  /// Throws [CacheException] if the event is not found
  Future<CalendarEventDataModel> getEventById(String id);

  /// Saves a calendar event to local storage
  /// 
  /// Creates a new event if it doesn't exist, updates if it does
  Future<void> saveEvent(CalendarEventDataModel event);

  /// Deletes a calendar event from local storage
  /// 
  /// Throws [CacheException] if the event is not found
  Future<void> deleteEvent(String id);

  /// Retrieves calendar events within a specific date range
  Future<List<CalendarEventDataModel>> getEventsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Retrieves calendar events filtered by sync status
  Future<List<CalendarEventDataModel>> getEventsBySyncStatus(
    CalendarSyncStatus syncStatus,
  );

  /// Clears all cached calendar events
  Future<void> clearCache();
}
