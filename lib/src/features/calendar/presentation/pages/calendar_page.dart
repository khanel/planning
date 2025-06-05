import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/calendar/presentation/config/calendar_config.dart';
import 'package:planning/src/features/calendar/presentation/utils/calendar_event_utils.dart';
import 'package:planning/src/features/calendar/presentation/widgets/calendar_format_toggle.dart';
import 'package:planning/src/features/calendar/presentation/widgets/event_marker.dart';
import 'package:planning/src/features/calendar/presentation/widgets/selected_day_events_panel.dart';
import 'package:planning/src/features/calendar/presentation/widgets/event_creation_dialog.dart';

class CalendarPage extends StatefulWidget {
  final List<ScheduleEvent> events;
  final Function(ScheduleEvent)? onEventCreated;

  const CalendarPage({
    super.key,
    this.events = const [],
    this.onEventCreated,
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
            CalendarFormatToggle(
              currentFormat: _calendarFormat,
              onToggle: _toggleCalendarFormat,
            ),
            _buildCalendar(),
            SelectedDayEventsPanel(
              selectedDay: _selectedDay,
              events: _selectedDayEvents,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEventCreationDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Calendar'),
      elevation: 0,
    );
  }


  Widget _buildCalendar() {
    return SizedBox(
      height: _calendarFormat == CalendarFormat.month 
        ? CalendarConfig.monthViewHeight 
        : CalendarConfig.twoWeeksViewHeight,
      child: TableCalendar<ScheduleEvent>(
        firstDay: CalendarConfig.firstDay,
        lastDay: CalendarConfig.lastDay,
        focusedDay: _focusedDay,
        selectedDayPredicate: _isSelectedDay,
        calendarFormat: _calendarFormat,
        onDaySelected: _onDaySelected,
        onFormatChanged: _onFormatChanged,
        onPageChanged: _onPageChanged,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarConfig.calendarStyle,
        headerStyle: CalendarConfig.headerStyle,
        eventLoader: _getEventsForDay,
        calendarBuilders: CalendarBuilders<ScheduleEvent>(
          markerBuilder: _buildEventMarker,
        ),
        availableGestures: AvailableGestures.all,
        sixWeekMonthsEnforced: false,
        daysOfWeekHeight: CalendarConfig.daysOfWeekHeight,
        rowHeight: CalendarConfig.rowHeight,
      ),
    );
  }



  bool _isSelectedDay(DateTime day) {
    return isSameDay(_selectedDay, day);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedDayEvents = CalendarEventUtils.getEventsForDay(selectedDay, widget.events);
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
    return CalendarEventUtils.getEventsForDay(day, widget.events);
  }

  Widget? _buildEventMarker(BuildContext context, DateTime day, List<ScheduleEvent> events) {
    if (events.isEmpty) return null;
    return EventMarker(day: day, events: events);
  }

  void _showEventCreationDialog() {
    showDialog(
      context: context,
      builder: (context) => EventCreationDialog(
        selectedDate: _selectedDay ?? _focusedDay,
        onEventCreated: widget.onEventCreated,
      ),
    );
  }
}
