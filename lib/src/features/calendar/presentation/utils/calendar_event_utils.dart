import 'package:table_calendar/table_calendar.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';

class CalendarEventUtils {
  static List<ScheduleEvent> getEventsForDay(
    DateTime day, 
    List<ScheduleEvent> allEvents
  ) {
    return allEvents.where((event) {
      if (event.isAllDay) {
        return isSameDay(event.startTime, day);
      } else {
        return event.startTime.year == day.year &&
               event.startTime.month == day.month &&
               event.startTime.day == day.day;
      }
    }).toList();
  }
  
  static bool isSameDayAsEvent(DateTime day, ScheduleEvent event) {
    if (event.isAllDay) {
      return isSameDay(event.startTime, day);
    } else {
      return event.startTime.year == day.year &&
             event.startTime.month == day.month &&
             event.startTime.day == day.day;
    }
  }
}
