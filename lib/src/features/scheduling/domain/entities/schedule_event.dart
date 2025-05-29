import 'package:equatable/equatable.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';

/// A scheduled event that can be synced with Google Calendar
class ScheduleEvent extends Equatable {
  /// Unique identifier for the event
  final String id;
  
  /// Event title
  final String title;
  
  /// Event description (optional)
  final String? description;
  
  /// Event start time
  final DateTime startTime;
  
  /// Event end time
  final DateTime endTime;
  
  /// Whether this is an all-day event
  final bool isAllDay;
  
  /// When the event was created
  final DateTime createdAt;
  
  /// When the event was last updated
  final DateTime updatedAt;
  
  /// Google Calendar ID if synced
  final String? googleCalendarId;
  
  /// Current sync status with Google Calendar
  final CalendarSyncStatus syncStatus;
  
  /// Last synchronization timestamp
  final DateTime? lastSyncAt;
  
  /// ID of linked task if this event is created from a task
  final String? linkedTaskId;

  const ScheduleEvent({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    required this.createdAt,
    required this.updatedAt,
    this.googleCalendarId,
    this.syncStatus = CalendarSyncStatus.notSynced,
    this.lastSyncAt,
    this.linkedTaskId,
  });

  /// Factory constructor to create a ScheduleEvent from task information
  factory ScheduleEvent.fromTask({
    required String taskId,
    required String taskTitle,
    required DateTime taskDueDate,
    required Duration estimatedDuration,
    required DateTime createdAt,
    String? taskDescription,
  }) {
    return ScheduleEvent(
      id: 'event-$taskId',
      title: taskTitle,
      description: taskDescription,
      startTime: taskDueDate,
      endTime: taskDueDate.add(estimatedDuration),
      isAllDay: false,
      createdAt: createdAt,
      updatedAt: createdAt,
      linkedTaskId: taskId,
    );
  }

  /// Validates if the event is properly configured
  bool get isValid {
    if (title.trim().isEmpty) return false;
    if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
      return false;
    }
    return true;
  }

  /// Calculate the duration of the event
  Duration get duration => endTime.difference(startTime);

  /// Check if this event overlaps with another event
  bool overlapsWith(ScheduleEvent other) {
    // Events don't overlap if one ends before the other starts
    return !(endTime.isBefore(other.startTime) || 
             other.endTime.isBefore(startTime) ||
             endTime.isAtSameMomentAs(other.startTime) ||
             other.endTime.isAtSameMomentAs(startTime));
  }

  /// Creates a copy of this event with updated fields
  ScheduleEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? googleCalendarId,
    CalendarSyncStatus? syncStatus,
    DateTime? lastSyncAt,
    String? linkedTaskId,
  }) {
    return ScheduleEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      googleCalendarId: googleCalendarId ?? this.googleCalendarId,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      linkedTaskId: linkedTaskId ?? this.linkedTaskId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startTime,
    endTime,
    isAllDay,
    createdAt,
    updatedAt,
    googleCalendarId,
    syncStatus,
    lastSyncAt,
    linkedTaskId,
  ];

  @override
  bool get stringify => true;
}
