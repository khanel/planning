import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event_model.dart';
import 'package:planning/src/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:planning/src/features/calendar/presentation/config/calendar_config.dart';
import 'package:planning/src/features/calendar/presentation/widgets/calendar_format_toggle.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<CalendarEventModel> _selectedDayEvents = [];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    // Dispatch LoadCalendarEvents when page is initialized
    context.read<CalendarBloc>().add(const LoadCalendarEvents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, state) {
          if (state is CalendarLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading calendar events...'),
                ],
              ),
            );
          }

          if (state is CalendarError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load events'),
                  const SizedBox(height: 8),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CalendarBloc>().add(const LoadCalendarEvents());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CalendarLoaded) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  CalendarFormatToggle(
                    currentFormat: _calendarFormat,
                    onToggle: _toggleCalendarFormat,
                  ),
                  _buildCalendar(state.events),
                  _buildSelectedDayEventsPanel(),
                ],
              ),
            );
          }

          // Initial state - show calendar with empty events
          return SingleChildScrollView(
            child: Column(
              children: [
                CalendarFormatToggle(
                  currentFormat: _calendarFormat,
                  onToggle: _toggleCalendarFormat,
                ),
                _buildCalendar(const []), // Empty events list for initial state
                _buildSelectedDayEventsPanel(),
              ],
            ),
          );
        },
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

  Widget _buildCalendar(List<CalendarEventModel> events) {
    return SizedBox(
      height: _calendarFormat == CalendarFormat.month 
        ? CalendarConfig.monthViewHeight 
        : CalendarConfig.twoWeeksViewHeight,
      child: TableCalendar<CalendarEventModel>(
        firstDay: CalendarConfig.firstDay,
        lastDay: CalendarConfig.lastDay,
        focusedDay: _focusedDay,
        selectedDayPredicate: _isSelectedDay,
        calendarFormat: _calendarFormat,
        onDaySelected: (selectedDay, focusedDay) => _onDaySelected(selectedDay, focusedDay, events),
        onFormatChanged: _onFormatChanged,
        onPageChanged: _onPageChanged,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarConfig.calendarStyle,
        headerStyle: CalendarConfig.headerStyle,
        eventLoader: (day) => _getEventsForDay(day, events),
        calendarBuilders: CalendarBuilders<CalendarEventModel>(
          markerBuilder: (context, day, events) => _buildEventMarker(context, day, events),
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

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay, List<CalendarEventModel> events) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedDayEvents = _getEventsForDay(selectedDay, events);
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

  List<CalendarEventModel> _getEventsForDay(DateTime day, List<CalendarEventModel> events) {
    // Simple implementation for now - in a real app, you'd filter by date
    return events.where((event) {
      // For now, return all events since CalendarEventModel doesn't have date fields yet
      return true;
    }).toList();
  }

  Widget? _buildEventMarker(BuildContext context, DateTime day, List<CalendarEventModel> events) {
    if (events.isEmpty) return null;
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${events.length}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSelectedDayEventsPanel() {
    if (_selectedDay == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Events for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_selectedDayEvents.isEmpty)
            const Text('No events for this day')
          else
            ..._selectedDayEvents.map((event) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('• ${event.summary}'),
            )),
        ],
      ),
    );
  }

  void _showEventCreationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Event'),
        content: const Text('Event creation will be implemented with BLoC integration'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Future: Dispatch CreateCalendarEvent to BLoC
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
