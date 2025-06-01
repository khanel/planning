import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/scheduling_bloc.dart';
import '../widgets/event_card.dart';
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                ],
              ),
            );
          }
          
          if (state is SchedulingEventsLoaded) {
            if (state.events.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 64),
                    SizedBox(height: 16),
                    Text('No events scheduled'),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final event = state.events[index];
                return EventCard(
                  event: event,
                  onTap: () {
                    final schedulingBloc = context.read<SchedulingBloc>();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: schedulingBloc,
                          child: AddEditEventPage(event: event),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final schedulingBloc = context.read<SchedulingBloc>();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: schedulingBloc,
                child: const AddEditEventPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
