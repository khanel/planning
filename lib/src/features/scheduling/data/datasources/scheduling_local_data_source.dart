import 'package:planning/src/features/scheduling/data/models/schedule_event_data_model.dart';

/// Abstract data source for local schedule event operations
/// 
/// This interface defines the contract for local storage operations
/// for schedule events using the data model.
abstract class SchedulingLocalDataSource {
  /// Retrieves all schedule events from local storage
  Future<List<ScheduleEventDataModel>> getEvents();

  /// Retrieves a specific schedule event by its ID
  /// 
  /// Throws [CacheException] if the event is not found
  Future<ScheduleEventDataModel> getEventById(String id);

  /// Saves a schedule event to local storage
  /// 
  /// Creates a new event if it doesn't exist, updates if it does
  Future<void> saveEvent(ScheduleEventDataModel event);

  /// Deletes a schedule event from local storage
  /// 
  /// Throws [CacheException] if the event is not found
  Future<void> deleteEvent(String id);

  /// Retrieves schedule events within a specific date range
  Future<List<ScheduleEventDataModel>> getEventsByDateRange(
    DateTime startDate, 
    DateTime endDate,
  );

  /// Retrieves schedule events linked to a specific task
  Future<List<ScheduleEventDataModel>> getEventsByTaskId(String taskId);
}
