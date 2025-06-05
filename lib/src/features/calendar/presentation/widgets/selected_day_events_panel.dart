import 'package:flutter/material.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';

class SelectedDayEventsPanel extends StatelessWidget {
  final DateTime? selectedDay;
  final List<ScheduleEvent> events;

  const SelectedDayEventsPanel({
    super.key,
    required this.selectedDay,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDay == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Events for selected day',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: events.isEmpty
                ? const Center(child: Text('No events for this day'))
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        title: Text(event.title),
                        subtitle: Text(_formatEventTime(event)),
                        dense: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatEventTime(ScheduleEvent event) {
    if (event.isAllDay) {
      return 'All Day';
    } else {
      final startTime = '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}';
      final endTime = '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}';
      return '$startTime - $endTime';
    }
  }
}
