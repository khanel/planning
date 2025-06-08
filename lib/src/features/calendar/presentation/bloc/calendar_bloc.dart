import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event_model.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc() : super(CalendarInitial()) {
    on<LoadCalendarEvents>(_onLoadCalendarEvents);
  }

  // Handles the LoadCalendarEvents event.
  // Currently, this handler is synchronous for simplicity in the initial TDD cycles
  // and uses a 'simulateError' flag in the event to test both success and error paths
  // without a full repository mock.
  // This will be updated to be asynchronous and interact with a data repository
  // in a future TDD cycle dedicated to data fetching.
  void _onLoadCalendarEvents(
    LoadCalendarEvents event,
    Emitter<CalendarState> emit,
  ) {
    emit(CalendarLoading());
    try {
      // The 'simulateError' flag allows tests to control the outcome of this operation.
      if (event.simulateError) {
        throw Exception('Failed to load events (simulated)');
      }
      // Placeholder for actual data fetching logic.
      // In a real scenario, this would involve an asynchronous call to a repository.
      final events = <CalendarEventModel>[];
      emit(CalendarLoaded(events: events));
    } catch (e) {
      // Emits CalendarError state if an exception occurs.
      emit(CalendarError(message: e.toString()));
    }
  }
}
