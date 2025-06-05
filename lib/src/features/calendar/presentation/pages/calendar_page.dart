import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/calendar/presentation/config/calendar_config.dart';
import 'package:planning/src/features/calendar/presentation/utils/calendar_event_utils.dart';
import 'package:planning/src/features/calendar/presentation/widgets/calendar_format_toggle.dart';
import 'package:planning/src/features/calendar/presentation/widgets/event_marker.dart';
import 'package:planning/src/features/calendar/presentation/widgets/selected_day_events_panel.dart';

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
      builder: (context) => _EventCreationDialog(
        selectedDate: _selectedDay ?? _focusedDay,
        onEventCreated: widget.onEventCreated,
      ),
    );
  }
}

class _EventCreationDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(ScheduleEvent)? onEventCreated;

  const _EventCreationDialog({
    required this.selectedDate,
    this.onEventCreated,
  });

  @override
  State<_EventCreationDialog> createState() => _EventCreationDialogState();
}

class _EventCreationDialogState extends State<_EventCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Event'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const Key('event_title_field'),
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an event title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              key: const Key('event_date_field'),
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                ),
                child: Text(_formatDate(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              key: const Key('event_time_field'),
              onTap: _selectTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                ),
                child: Text(_formatTime(_selectedTime)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveEvent,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      final event = ScheduleEvent(
        id: now.millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: '',
        startTime: startDateTime,
        endTime: startDateTime.add(const Duration(hours: 1)),
        createdAt: now,
        updatedAt: now,
      );

      widget.onEventCreated?.call(event);
      Navigator.of(context).pop();
    }
  }
}
