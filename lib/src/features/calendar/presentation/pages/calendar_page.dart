import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event_model.dart';
import 'package:planning/src/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:planning/src/features/calendar/presentation/config/calendar_config.dart';
import 'package:planning/src/features/calendar/presentation/constants/calendar_page_constants.dart';
import 'package:planning/src/features/calendar/presentation/widgets/calendar_format_toggle.dart';

/// Main calendar page displaying events using BLoC state management.
/// 
/// Provides a clean interface for viewing and interacting with calendar events,
/// following Flutter and BLoC best practices for maintainable code structure.
/// 
/// The page handles various states including loading, loaded with events, and
/// error states through a BLoC pattern implementation.
class CalendarPage extends StatefulWidget {
  /// Creates a [CalendarPage].
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // State management variables
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<CalendarEventModel> _selectedDayEvents = [];

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _loadCalendarEvents();
  }

  // ============================================================================
  // BLoC INTERACTION METHODS
  // ============================================================================

  /// Triggers loading of calendar events through BLoC.
  /// 
  /// Dispatches a [LoadCalendarEvents] event to the calendar BLoC
  /// to initiate data fetching process.
  void _loadCalendarEvents() {
    context.read<CalendarBloc>().add(const LoadCalendarEvents());
  }

  // ============================================================================
  // WIDGET BUILD METHODS
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, state) => _buildBody(state),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Builds the app bar for the calendar page.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(CalendarPageConstants.calendarTitle),
      elevation: 0,
    );
  }

  /// Builds the main body content based on the current BLoC state.
  Widget _buildBody(CalendarState state) {
    if (state is CalendarLoading) {
      return _buildLoadingView();
    }

    if (state is CalendarError) {
      return _buildErrorView(state.message);
    }

    if (state is CalendarLoaded) {
      return _buildCalendarView(state.events);
    }

    // Initial state - show calendar with empty events
    return _buildCalendarView(const []);
  }

  /// Builds the loading view with progress indicator.
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: CalendarPageConstants.loadingSpacing),
          Text(CalendarPageConstants.loadingMessage),
        ],
      ),
    );
  }

  /// Builds the error view with retry functionality.
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: CalendarPageConstants.errorIconSize,
            color: Colors.red,
          ),
          const SizedBox(height: CalendarPageConstants.errorSpacing),
          const Text(CalendarPageConstants.errorMessage),
          const SizedBox(height: CalendarPageConstants.errorSmallSpacing),
          Text('Error: $errorMessage'),
          const SizedBox(height: CalendarPageConstants.errorSpacing),
          ElevatedButton(
            onPressed: _loadCalendarEvents,
            child: const Text(CalendarPageConstants.retryButtonText),
          ),
        ],
      ),
    );
  }

  /// Builds the main calendar view with events.
  Widget _buildCalendarView(List<CalendarEventModel> events) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CalendarFormatToggle(
            currentFormat: _calendarFormat,
            onToggle: _toggleCalendarFormat,
          ),
          _buildCalendar(events),
          _buildSelectedDayEventsPanel(),
        ],
      ),
    );
  }

  /// Builds the floating action button for event creation.
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showEventCreationDialog,
      tooltip: CalendarPageConstants.addButtonTooltip,
      child: const Icon(Icons.add),
    );
  }

  /// Builds the TableCalendar widget with the provided events.
  Widget _buildCalendar(List<CalendarEventModel> events) {
    return SizedBox(
      height: _getCalendarHeight(),
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

  /// Gets the appropriate height for the calendar based on format.
  double _getCalendarHeight() {
    return _calendarFormat == CalendarFormat.month 
        ? CalendarConfig.monthViewHeight 
        : CalendarConfig.twoWeeksViewHeight;
  }

  // ============================================================================
  // EVENT HANDLING METHODS
  // ============================================================================

  /// Checks if the given day is the currently selected day.
  bool _isSelectedDay(DateTime day) {
    return isSameDay(_selectedDay, day);
  }

  /// Handles day selection and updates the focused day and selected events.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay, List<CalendarEventModel> events) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedDayEvents = _getEventsForDay(selectedDay, events);
    });
  }

  /// Handles calendar format changes.
  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  /// Handles calendar page changes (month navigation).
  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  /// Toggles between month and two-week calendar formats.
  void _toggleCalendarFormat() {
    setState(() {
      _calendarFormat = _calendarFormat == CalendarFormat.month
          ? CalendarFormat.twoWeeks
          : CalendarFormat.month;
    });
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Gets events for a specific day.
  /// 
  /// Currently returns all events since [CalendarEventModel] doesn't have date fields yet.
  /// This method should be updated when date filtering is implemented.
  List<CalendarEventModel> _getEventsForDay(DateTime day, List<CalendarEventModel> events) {
    // Simple implementation for now - in a real app, you'd filter by date
    return events.where((event) {
      // For now, return all events since CalendarEventModel doesn't have date fields yet
      return true;
    }).toList();
  }

  /// Builds event markers for calendar days with events.
  Widget? _buildEventMarker(BuildContext context, DateTime day, List<CalendarEventModel> events) {
    if (events.isEmpty) return null;
    
    return Container(
      margin: const EdgeInsets.only(top: CalendarPageConstants.markerTopMargin),
      padding: const EdgeInsets.all(CalendarPageConstants.markerPadding),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(CalendarPageConstants.markerOpacity),
        borderRadius: BorderRadius.circular(CalendarPageConstants.markerBorderRadius),
      ),
      child: Text(
        '${events.length}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: CalendarPageConstants.markerFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Builds the panel showing events for the selected day.
  Widget _buildSelectedDayEventsPanel() {
    if (_selectedDay == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(CalendarPageConstants.containerMargin),
      padding: const EdgeInsets.all(CalendarPageConstants.containerPadding),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(CalendarPageConstants.containerBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getSelectedDayTitle(),
            style: const TextStyle(
              fontSize: CalendarPageConstants.selectedDayTitleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: CalendarPageConstants.errorSmallSpacing),
          ..._buildEventsList(),
        ],
      ),
    );
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Gets the title for the selected day events panel.
  String _getSelectedDayTitle() {
    return 'Events for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}';
  }

  /// Builds the list of events for the selected day.
  List<Widget> _buildEventsList() {
    if (_selectedDayEvents.isEmpty) {
      return [const Text(CalendarPageConstants.noEventsMessage)];
    }
    
    return _selectedDayEvents
        .map((event) => Padding(
              padding: const EdgeInsets.symmetric(vertical: CalendarPageConstants.eventItemSpacing),
              child: Text('• ${event.summary}'),
            ))
        .toList();
  }

  // ============================================================================
  // DIALOG METHODS
  // ============================================================================

  /// Shows the event creation dialog.
  /// 
  /// Currently displays a placeholder dialog. In the future, this will
  /// dispatch a [CreateCalendarEvent] to the BLoC for proper event creation.
  void _showEventCreationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(CalendarPageConstants.createEventTitle),
        content: const Text(CalendarPageConstants.createEventContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(CalendarPageConstants.cancelButtonText),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Future: Dispatch CreateCalendarEvent to BLoC
            },
            child: const Text(CalendarPageConstants.saveButtonText),
          ),
        ],
      ),
    );
  }
}
