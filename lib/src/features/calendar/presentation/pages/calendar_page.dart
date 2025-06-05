import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';

class CalendarPage extends StatefulWidget {
  final List<ScheduleEvent> events;

  const CalendarPage({
    super.key,
    this.events = const [],
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<ScheduleEvent> _selectedDayEvents = [];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendarFormatToggle(),
            _buildCalendar(),
            if (_selectedDay != null)
              Container(
                height: 200,
                child: _buildSelectedDayEvents(),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Calendar'),
      elevation: 0,
    );
  }

  Widget _buildCalendarFormatToggle() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: _toggleCalendarFormat,
        child: const Text('Change Format'),
      ),
    );
  }

  Widget _buildCalendar() {
    return SizedBox(
      height: _calendarFormat == CalendarFormat.month ? 350 : 340,
      child: TableCalendar<ScheduleEvent>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: _isSelectedDay,
        calendarFormat: _calendarFormat,
        onDaySelected: _onDaySelected,
        onFormatChanged: _onFormatChanged,
        onPageChanged: _onPageChanged,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: _buildCalendarStyle(),
        headerStyle: _buildHeaderStyle(),
        eventLoader: _getEventsForDay,
        calendarBuilders: CalendarBuilders<ScheduleEvent>(
          markerBuilder: _buildEventMarker,
        ),
        availableGestures: AvailableGestures.all,
        sixWeekMonthsEnforced: false,
        daysOfWeekHeight: 30,
        rowHeight: 40,
      ),
    );
  }

  CalendarStyle _buildCalendarStyle() {
    return const CalendarStyle(
      outsideDaysVisible: false,
      weekendTextStyle: TextStyle(color: Colors.red),
      holidayTextStyle: TextStyle(color: Colors.red),
    );
  }

  HeaderStyle _buildHeaderStyle() {
    return const HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
    );
  }

  bool _isSelectedDay(DateTime day) {
    return isSameDay(_selectedDay, day);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedDayEvents = _getEventsForDay(selectedDay);
    });
  }

  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  void _toggleCalendarFormat() {
    setState(() {
      _calendarFormat = _calendarFormat == CalendarFormat.month
          ? CalendarFormat.twoWeeks
          : CalendarFormat.month;
    });
  }

  List<ScheduleEvent> _getEventsForDay(DateTime day) {
    return widget.events.where((event) {
      if (event.isAllDay) {
        return isSameDay(event.startTime, day);
      } else {
        return event.startTime.year == day.year &&
               event.startTime.month == day.month &&
               event.startTime.day == day.day;
      }
    }).toList();
  }

  Widget? _buildEventMarker(BuildContext context, DateTime day, List<ScheduleEvent> events) {
    if (events.isEmpty) return null;
    
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

  Widget _buildSelectedDayEvents() {
    return Container(
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
            child: _selectedDayEvents.isEmpty
                ? const Center(child: Text('No events for this day'))
                : ListView.builder(
                    itemCount: _selectedDayEvents.length,
                    itemBuilder: (context, index) {
                      final event = _selectedDayEvents[index];
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
