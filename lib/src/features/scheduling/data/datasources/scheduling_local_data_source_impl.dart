import 'package:hive/hive.dart';

import 'package:planning/src/core/errors/exceptions.dart';
import 'package:planning/src/features/scheduling/data/datasources/scheduling_local_data_source.dart';
import 'package:planning/src/features/scheduling/data/models/schedule_event_data_model.dart';

/// Concrete implementation of [SchedulingLocalDataSource] using Hive for local storage
/// 
/// This class handles all local storage operations for schedule events using
/// Hive as the underlying storage mechanism. It provides efficient querying
/// capabilities for events by date ranges and task associations.
class SchedulingLocalDataSourceImpl implements SchedulingLocalDataSource {
  final Box<ScheduleEventDataModel> box;

  const SchedulingLocalDataSourceImpl({required this.box});

  @override
  Future<List<ScheduleEventDataModel>> getEvents() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<ScheduleEventDataModel> getEventById(String id) async {
    try {
      final event = box.get(id);
      if (event == null) {
        throw CacheException();
      }
      return event;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException();
    }
  }

  @override
  Future<void> saveEvent(ScheduleEventDataModel event) async {
    try {
      await box.put(event.id, event);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      final event = box.get(id);
      if (event == null) {
        throw CacheException();
      }
      await box.delete(id);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException();
    }
  }

  @override
  Future<List<ScheduleEventDataModel>> getEventsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allEvents = box.values.toList();
      return allEvents.where((event) => _isEventInDateRange(event, startDate, endDate)).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<ScheduleEventDataModel>> getEventsByTaskId(String taskId) async {
    try {
      final allEvents = box.values.toList();
      
      // Handle special case for querying null linkedTaskId
      if (taskId == 'null') {
        return allEvents.where((event) => event.linkedTaskId == null).toList();
      }
      
      return allEvents.where((event) => event.linkedTaskId == taskId).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  /// Checks if an event falls within the specified date range
  /// 
  /// For all-day events, uses date-only comparison.
  /// For timed events, checks for overlap between event time and date range.
  bool _isEventInDateRange(ScheduleEventDataModel event, DateTime startDate, DateTime endDate) {
    if (event.isAllDay) {
      return _isAllDayEventInRange(event, startDate, endDate);
    }
    return _isTimedEventInRange(event, startDate, endDate);
  }

  /// Checks if an all-day event falls within the date range (date-only comparison)
  bool _isAllDayEventInRange(ScheduleEventDataModel event, DateTime startDate, DateTime endDate) {
    final eventDate = _normalizeToDate(event.startTime);
    final normalizedStartDate = _normalizeToDate(startDate);
    final normalizedEndDate = _normalizeToDate(endDate);
    
    return (eventDate.isAtSameMomentAs(normalizedStartDate) || eventDate.isAfter(normalizedStartDate)) &&
           (eventDate.isAtSameMomentAs(normalizedEndDate) || eventDate.isBefore(normalizedEndDate));
  }

  /// Checks if a timed event overlaps with the date range
  bool _isTimedEventInRange(ScheduleEventDataModel event, DateTime startDate, DateTime endDate) {
    // Normalize endDate to end of day for inclusive range checking
    final normalizedEndDate = _normalizeToEndOfDay(endDate);
    return (event.startTime.isBefore(normalizedEndDate) || event.startTime.isAtSameMomentAs(normalizedEndDate)) &&
           (event.endTime.isAfter(startDate) || event.endTime.isAtSameMomentAs(startDate));
  }

  /// Normalizes a DateTime to the start of the day (00:00:00)
  DateTime _normalizeToDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Normalizes a DateTime to the end of the day (23:59:59.999)
  DateTime _normalizeToEndOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }
}
