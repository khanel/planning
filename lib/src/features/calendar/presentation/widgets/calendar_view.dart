import 'package:flutter/material.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Calendar'),
      ),
      body: const Center(
        child: Text('Calendar View - Coming Soon!'),
      ),
    );
  }
}
