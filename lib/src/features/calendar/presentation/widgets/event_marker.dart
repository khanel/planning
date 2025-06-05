import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';

/// Widget that displays a visual marker for events on a specific day in a calendar.
/// 
/// Shows a circular marker and optional count badge when events are present.
/// Supports multi-day events and day-specific filtering.
/// Provides tap interaction when onTap callback is provided.
class EventMarker extends StatelessWidget {
  // Visual design constants
  static const double _markerSize = 6.0;
  static const double _countFontSize = 10.0;
  static const EdgeInsets _topPadding = EdgeInsets.only(top: 5.0);
  static const int _maxDisplayCount = 9;
  static const String _countOverflowSuffix = '+';
  
  final DateTime day;
  final List<ScheduleEvent> events;
  final void Function(DateTime day, List<ScheduleEvent> dayEvents)? onTap;

  const EventMarker({
    super.key,
    required this.day,
    required this.events,
    this.onTap,
  });

  /// Filters events to only include those that occur on or span the specified [day].
  /// 
  /// Handles both single-day and multi-day events by checking if the target day
  /// falls within the event's start and end date range.
  List<ScheduleEvent> _getEventsForDay() {
    if (events.isEmpty) return events;
    
    final targetDate = _normalizeToDate(day);
    
    return events.where((event) {
      final startDate = _normalizeToDate(event.startTime);
      final endDate = _normalizeToDate(event.endTime);
      
      return _isDateWithinRange(targetDate, startDate, endDate);
    }).toList();
  }

  /// Normalizes a DateTime to date-only comparison (removes time component).
  DateTime _normalizeToDate(DateTime dateTime) => DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
      );

  /// Checks if a target date falls within a date range (inclusive).
  bool _isDateWithinRange(DateTime target, DateTime start, DateTime end) =>
      target.isAtSameMomentAs(start) ||
      target.isAtSameMomentAs(end) ||
      (target.isAfter(start) && target.isBefore(end));

  /// Generates the count text for the badge.
  /// 
  /// Returns the actual count for 2-9 events, or "9+" for 10 or more events.
  String _getCountText(int count) {
    return count > _maxDisplayCount 
        ? '$_maxDisplayCount$_countOverflowSuffix' 
        : count.toString();
  }

  /// Builds the circular marker with theme-aware styling.
  Widget _buildMarker(BuildContext context) => Container(
        width: _markerSize,
        height: _markerSize,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
      );

  /// Builds the count badge text widget.
  Widget _buildCountBadge(BuildContext context, int count) => Text(
        _getCountText(count),
        style: TextStyle(
          fontSize: _countFontSize,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      );

  /// Builds the main marker content (marker circle and optional count badge).
  Widget _buildMarkerContent(BuildContext context, List<ScheduleEvent> dayEvents) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMarker(context),
        if (dayEvents.length > 1) _buildCountBadge(context, dayEvents.length),
      ],
    );
  }

  /// Builds the interactive wrapper when onTap is provided.
  Widget _buildInteractiveWrapper({
    required Widget child,
    required List<ScheduleEvent> dayEvents,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap!(day, dayEvents);
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayEvents = _getEventsForDay();
    
    if (dayEvents.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final markerContent = _buildMarkerContent(context, dayEvents);
    final paddedContent = Padding(
      padding: _topPadding,
      child: markerContent,
    );

    return onTap == null
        ? paddedContent
        : Padding(
            padding: _topPadding,
            child: _buildInteractiveWrapper(
              child: markerContent,
              dayEvents: dayEvents,
            ),
          );
  }
}
