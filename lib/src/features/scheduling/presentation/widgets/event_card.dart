import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/schedule_event.dart';

/// A card widget that displays schedule event information.
/// 
/// This widget shows event title, description, and time in a card format.
/// It supports both all-day and timed events with proper formatting.
class EventCard extends StatelessWidget {
  // Constants
  static const String _allDayText = 'All Day';
  static const String _timeFormatPattern = 'h:mm a';
  static const String _timeSeparator = ' - ';
  
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
        subtitle: _buildSubtitle(),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasDescription()) Text(event.description!),
        Text(_formatTime()),
      ],
    );
  }

  bool _hasDescription() {
    return event.description != null;
  }

  String _formatTime() {
    if (event.isAllDay) {
      return _allDayText;
    }
    
    final timeFormat = DateFormat(_timeFormatPattern);
    final startTime = timeFormat.format(event.startTime);
    final endTime = timeFormat.format(event.endTime);
    
    return '$startTime$_timeSeparator$endTime';
  }
}
