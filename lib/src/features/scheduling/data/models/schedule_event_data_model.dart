import 'package:hive/hive.dart';
import 'package:planning/src/features/task/data/models/unified_record_model.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';

part 'schedule_event_data_model.g.dart';

@HiveType(typeId: 3)
class ScheduleEventDataModel extends UnifiedRecordModel {
  @HiveField(5)
  final String title;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final DateTime startTime;

  @HiveField(8)
  final DateTime endTime;

  @HiveField(9)
  final bool isAllDay;

  @HiveField(10)
  final String? googleCalendarId;

  @HiveField(11)
  final CalendarSyncStatus syncStatus;

  @HiveField(12)
  final DateTime? lastSyncAt;

  @HiveField(13)
  final String? linkedTaskId;

  ScheduleEventDataModel({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.googleCalendarId,
    this.syncStatus = CalendarSyncStatus.notSynced,
    this.lastSyncAt,
    this.linkedTaskId,
  }) : super(
          id: id,
          type: 'schedule_event',
          createdAt: createdAt,
          updatedAt: updatedAt,
          data: {}, // Data field is not used in this model as fields are directly in the class
        );

  // Factory constructor for creating a ScheduleEventDataModel from a map
  factory ScheduleEventDataModel.fromMap(Map<String, dynamic> map) {
    return ScheduleEventDataModel(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      title: map['title'] as String,
      description: map['description'] as String?,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      isAllDay: map['isAllDay'] as bool? ?? false,
      googleCalendarId: map['googleCalendarId'] as String?,
      syncStatus: map['syncStatus'] != null 
          ? CalendarSyncStatus.values[map['syncStatus'] as int]
          : CalendarSyncStatus.notSynced,
      lastSyncAt: map['lastSyncAt'] != null 
          ? DateTime.parse(map['lastSyncAt'] as String) 
          : null,
      linkedTaskId: map['linkedTaskId'] as String?,
    );
  }

  // Method for converting a ScheduleEventDataModel to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllDay': isAllDay,
      'googleCalendarId': googleCalendarId,
      'syncStatus': syncStatus.index,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'linkedTaskId': linkedTaskId,
    };
  }

  // Convert to domain entity
  ScheduleEvent toDomainEntity() {
    return ScheduleEvent(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      createdAt: createdAt,
      updatedAt: updatedAt,
      googleCalendarId: googleCalendarId,
      syncStatus: syncStatus,
      lastSyncAt: lastSyncAt,
      linkedTaskId: linkedTaskId,
    );
  }

  // Create from domain entity
  factory ScheduleEventDataModel.fromDomainEntity(ScheduleEvent scheduleEvent) {
    return ScheduleEventDataModel(
      id: scheduleEvent.id,
      createdAt: scheduleEvent.createdAt,
      updatedAt: scheduleEvent.updatedAt,
      title: scheduleEvent.title,
      description: scheduleEvent.description,
      startTime: scheduleEvent.startTime,
      endTime: scheduleEvent.endTime,
      isAllDay: scheduleEvent.isAllDay,
      googleCalendarId: scheduleEvent.googleCalendarId,
      syncStatus: scheduleEvent.syncStatus,
      lastSyncAt: scheduleEvent.lastSyncAt,
      linkedTaskId: scheduleEvent.linkedTaskId,
    );
  }

  // Copy with method for creating modified copies
  ScheduleEventDataModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? googleCalendarId,
    CalendarSyncStatus? syncStatus,
    DateTime? lastSyncAt,
    String? linkedTaskId,
  }) {
    return ScheduleEventDataModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      googleCalendarId: googleCalendarId ?? this.googleCalendarId,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      linkedTaskId: linkedTaskId ?? this.linkedTaskId,
    );
  }
}
