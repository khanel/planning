import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/scheduling_bloc.dart';
import '../widgets/event_card.dart';
import '../../domain/entities/schedule_event.dart';
import 'add_edit_event_page.dart';

/// Main page for displaying scheduled events.
/// 
/// This page shows a list of events and provides navigation to add new events.
/// It uses the SchedulingBloc to manage state and load events.
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // Constants
  static const double _iconSize = 64.0;
  static const double _spacing = 16.0;
  
  @override
  void initState() {
    super.initState();
    context.read<SchedulingBloc>().add(const LoadEvents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: BlocConsumer<SchedulingBloc, SchedulingState>(
        listener: (context, state) {
          if (state is SchedulingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SchedulingLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is SchedulingError) {
            return _buildErrorState(state.message);
          }
          
          if (state is SchedulingEventsLoaded) {
            if (state.events.isEmpty) {
              return _buildEmptyState();
            }
            
            return _buildEventsList(state.events);
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEvent(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: _iconSize),
          SizedBox(height: _spacing),
          Text('Error: $message'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: _iconSize),
          SizedBox(height: _spacing),
          const Text('No events scheduled'),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<ScheduleEvent> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          onTap: () => _navigateToEditEvent(event),
        );
      },
    );
  }

  void _navigateToAddEvent() {
    final schedulingBloc = context.read<SchedulingBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: schedulingBloc,
          child: const AddEditEventPage(),
        ),
      ),
    );
  }

  void _navigateToEditEvent(ScheduleEvent event) {
    final schedulingBloc = context.read<SchedulingBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: schedulingBloc,
          child: AddEditEventPage(event: event),
        ),
      ),
    );
  }
}
