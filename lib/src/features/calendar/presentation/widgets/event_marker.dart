import 'package:flutter/material.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';

class EventMarker extends StatelessWidget {
  final DateTime day;
  final List<ScheduleEvent> events;

  const EventMarker({
    super.key,
    required this.day,
    required this.events,
  });

  // Helper method to filter events for the specific day
  List<ScheduleEvent> _getEventsForDay() {
    return events.where((event) {
      final startDate = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      final endDate = DateTime(event.endTime.year, event.endTime.month, event.endTime.day);
      final targetDate = DateTime(day.year, day.month, day.day);
      
      // Check if the event spans the target day
      return targetDate.isAtSameMomentAs(startDate) ||
             targetDate.isAtSameMomentAs(endDate) ||
             (targetDate.isAfter(startDate) && targetDate.isBefore(endDate));
    }).toList();
  }

  // Helper method to get count text
  String _getCountText(int count) {
    if (count >= 10) {
      return '9+';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final dayEvents = _getEventsForDay();
    
    if (dayEvents.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          if (dayEvents.length > 1)
            Text(
              _getCountText(dayEvents.length),
              style: const TextStyle(fontSize: 10),
            ),
        ],
      ),
    );
  }
}
