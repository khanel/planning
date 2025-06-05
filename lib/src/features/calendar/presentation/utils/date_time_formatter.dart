import 'package:flutter/material.dart';

/// Utility class for formatting date and time values in the calendar feature
class DateTimeFormatter {
  /// Formats a DateTime to a user-friendly date string
  /// Example: "Jan 15, 2024"
  static String formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  /// Formats a TimeOfDay to a user-friendly time string
  /// Example: "2:30 PM"
  static String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Get the abbreviated month name for a given month number (1-12)
  static String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
