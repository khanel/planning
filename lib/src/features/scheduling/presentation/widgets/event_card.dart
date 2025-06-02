import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/schedule_event.dart';

/// A card widget that displays schedule event information.
/// 
/// This widget shows event title, description, and time in a card format.
/// It supports both all-day and timed events with proper formatting.
/// 
/// The widget ensures accessibility by providing consistent structure
/// and semantic information for screen readers.
/// 
/// Example usage:
/// ```dart
/// EventCard(
///   event: scheduleEvent,
///   onTap: () => Navigator.push(...),
/// )
/// ```
class EventCard extends StatelessWidget {
  // Display constants
  static const String _allDayText = 'All Day';
  static const String _timeFormatPattern = 'h:mm a';
  static const String _timeSeparator = ' - ';
  
  // Accessibility constants
  static const String _semanticLabelPrefix = 'Event: ';
  static const String _semanticTimePrefix = 'Time: ';
  static const String _semanticDescriptionPrefix = 'Description: ';
  
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
        leading: const Icon(
          Icons.event,
          semanticLabel: 'Event icon',
        ),
        title: Semantics(
          label: '$_semanticLabelPrefix${event.title}',
          child: Text(event.title),
        ),
        subtitle: _buildSubtitle(),
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16.0),
      ),
    );
  }

  /// Builds the subtitle section containing event description and time.
  /// 
  /// Returns a Column with:
  /// - Description text (if present) wrapped in Semantics for accessibility
  /// - Time information wrapped in Semantics for accessibility
  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasDescription()) 
          Semantics(
            label: '$_semanticDescriptionPrefix${event.description}',
            child: Text(event.description!),
          ),
        Semantics(
          label: '$_semanticTimePrefix${_formatTime()}',
          child: Text(_formatTime()),
        ),
      ],
    );
  }

  /// Checks if the event has a non-null description.
  /// 
  /// Returns true if the event description is not null, regardless of content.
  /// This allows empty descriptions to be displayed for consistent widget structure.
  bool _hasDescription() {
    return event.description != null;
  }

  /// Formats the event time for display.
  /// 
  /// Returns:
  /// - 'All Day' for all-day events
  /// - 'h:mm a - h:mm a' format for timed events (e.g., '9:00 AM - 5:00 PM')
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
