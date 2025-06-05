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

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(top: 5),
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
          if (events.length > 1)
            Text(
              ' ${events.length}',
              style: const TextStyle(fontSize: 10),
            ),
        ],
      ),
    );
  }
}
