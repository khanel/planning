/// CalendarEventDataModel represents a calendar event data object for local storage.
/// 
/// This model is specifically designed for Hive database storage and includes
/// all necessary properties for calendar event persistence and synchronization.

import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';

class CalendarEventDataModel {
  /// Creates a new CalendarEventDataModel instance.
  const CalendarEventDataModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.isAllDay,
    required this.syncStatus,
    this.calendarId,
    this.googleEventId,
    this.lastModified,
    this.location,
    this.recurrenceRule,
    this.attendees = const [],
  });

  /// Creates a CalendarEventDataModel from a JSON map.
  factory CalendarEventDataModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventDataModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isAllDay: json['isAllDay'] as bool,
      syncStatus: CalendarSyncStatus.values.byName(json['syncStatus'] as String),
      calendarId: json['calendarId'] as String?,
      googleEventId: json['googleEventId'] as String?,
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified'] as String) : null,
      location: json['location'] as String?,
      recurrenceRule: json['recurrenceRule'] as String?,
      attendees: (json['attendees'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  /// Unique identifier for the calendar event.
  final String id;

  /// Title/summary of the calendar event.
  final String title;

  /// Detailed description of the calendar event.
  final String description;

  /// Start date and time of the event.
  final DateTime startTime;

  /// End date and time of the event.
  final DateTime endTime;

  /// Whether this is an all-day event.
  final bool isAllDay;

  /// Current synchronization status (e.g., 'synced', 'pending', 'failed').
  final CalendarSyncStatus syncStatus;

  /// Optional calendar ID where this event belongs.
  final String? calendarId;

  /// Optional Google Calendar event ID for synced events.
  final String? googleEventId;

  /// Last modification timestamp.
  final DateTime? lastModified;

  /// Optional location where the event takes place.
  final String? location;

  /// Optional recurrence rule for repeating events.
  final String? recurrenceRule;

  /// List of attendee email addresses.
  final List<String> attendees;

  /// Converts this CalendarEventDataModel to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllDay': isAllDay,
      'syncStatus': syncStatus.name,
      'calendarId': calendarId,
      'googleEventId': googleEventId,
      'lastModified': lastModified?.toIso8601String(),
      'location': location,
      'recurrenceRule': recurrenceRule,
      'attendees': attendees,
    };
  }

  /// Creates a copy of this CalendarEventDataModel with the given fields replaced.
  CalendarEventDataModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    CalendarSyncStatus? syncStatus,
    String? calendarId,
    String? googleEventId,
    DateTime? lastModified,
    String? location,
    String? recurrenceRule,
    List<String>? attendees,
  }) {
    return CalendarEventDataModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      syncStatus: syncStatus ?? this.syncStatus,
      calendarId: calendarId ?? this.calendarId,
      googleEventId: googleEventId ?? this.googleEventId,
      lastModified: lastModified ?? this.lastModified,
      location: location ?? this.location,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      attendees: attendees ?? this.attendees,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CalendarEventDataModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.isAllDay == isAllDay &&
        other.syncStatus == syncStatus &&
        other.calendarId == calendarId &&
        other.googleEventId == googleEventId &&
        other.lastModified == lastModified &&
        other.location == location &&
        other.recurrenceRule == recurrenceRule &&
        _listEquals(other.attendees, attendees);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      startTime,
      endTime,
      isAllDay,
      syncStatus,
      calendarId,
      googleEventId,
      lastModified,
      location,
      recurrenceRule,
      attendees,
    );
  }

  @override
  String toString() {
    return 'CalendarEventDataModel(id: $id, title: $title, description: $description, '
        'startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay, '
        'syncStatus: $syncStatus, calendarId: $calendarId, googleEventId: $googleEventId, '
        'lastModified: $lastModified, location: $location, recurrenceRule: $recurrenceRule, '
        'attendees: $attendees)';
  }

  /// Helper method to compare lists for equality.
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
