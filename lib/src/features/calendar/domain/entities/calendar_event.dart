import 'package:equatable/equatable.dart';

/// Entity representing a calendar event in the domain layer
class CalendarEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String? calendarId;
  final String? googleEventId;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.isAllDay,
    this.calendarId,
    this.googleEventId,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startTime,
        endTime,
        isAllDay,
        calendarId,
        googleEventId,
      ];
}
