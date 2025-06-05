import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarConfig {
  static const double monthViewHeight = 350;
  static const double twoWeeksViewHeight = 340;
  static const double daysOfWeekHeight = 30;
  static const double rowHeight = 40;
  
  static const EdgeInsets toggleButtonPadding = EdgeInsets.all(8.0);
  static const EdgeInsets eventsPanelPadding = EdgeInsets.all(16.0);
  
  static const double eventMarkerSize = 6.0;
  static const double eventMarkerTopMargin = 5.0;
  
  static CalendarStyle get calendarStyle => const CalendarStyle(
    outsideDaysVisible: false,
    weekendTextStyle: TextStyle(color: Colors.red),
    holidayTextStyle: TextStyle(color: Colors.red),
  );
  
  static HeaderStyle get headerStyle => const HeaderStyle(
    formatButtonVisible: false,
    titleCentered: true,
  );
  
  static DateTime get firstDay => DateTime.utc(2020, 1, 1);
  static DateTime get lastDay => DateTime.utc(2030, 12, 31);
}
