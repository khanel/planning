import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/schedule_event.dart';

/// A card widget that displays schedule event information.
/// 
/// This widget shows event title, description, and time in a card format.
/// It supports both all-day and timed events with proper formatting.
class EventCard extends StatelessWidget {
  final ScheduleEvent event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(event.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description ?? ''),
            Text(_formatTime()),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatTime() {
    if (event.isAllDay) {
      return 'All Day';
    }
    
    final timeFormat = DateFormat('h:mm a');
    final startTime = timeFormat.format(event.startTime);
    final endTime = timeFormat.format(event.endTime);
    
    return '$startTime - $endTime';
  }
}
