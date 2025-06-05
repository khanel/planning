import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarFormatToggle extends StatelessWidget {
  final CalendarFormat currentFormat;
  final VoidCallback onToggle;

  const CalendarFormatToggle({
    super.key,
    required this.currentFormat,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onToggle,
        child: Text(
          currentFormat == CalendarFormat.month 
            ? 'Switch to 2 Weeks' 
            : 'Switch to Month'
        ),
      ),
    );
  }
}
