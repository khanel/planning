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

  @override
  Future<List<CalendarEventDataModel>> getEvents() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw CacheException('Failed to retrieve events: $e');
    }
  }

  @override
  Future<CalendarEventDataModel> getEventById(String id) async {
    try {
      final event = box.get(id);
      if (event == null) {
        throw CacheException('Event with id $id not found');
      }
      return event;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to retrieve event by id: $e');
    }
  }

  @override
  Future<void> saveEvent(CalendarEventDataModel event) async {
    try {
      await box.put(event.id, event);
    } catch (e) {
      throw CacheException('Failed to save event: $e');
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      final event = box.get(id);
      if (event == null) {
        throw CacheException('Event with id $id not found');
      }
      await box.delete(id);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to delete event: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear all events: $e');
    }
  }

  @override
  Future<List<CalendarEventDataModel>> getEventsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final events = box.values.where((event) {
        return (event.startTime.isBefore(endDate) || event.startTime.isAtSameMomentAs(endDate)) &&
               (event.endTime.isAfter(startDate) || event.endTime.isAtSameMomentAs(startDate));
      }).toList();
      return events;
    } catch (e) {
      throw CacheException('Failed to retrieve events by date range: $e');
    }
  }

  @override
  Future<List<CalendarEventDataModel>> getEventsBySyncStatus(CalendarSyncStatus syncStatus) async {
    try {
      final events = box.values.where((event) => event.syncStatus == syncStatus).toList();
      return events;
    } catch (e) {
      throw CacheException('Failed to retrieve events by sync status: $e');
    }
  }
}
