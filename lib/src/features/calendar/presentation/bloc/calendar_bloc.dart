import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc() : super(CalendarInitial()) {
    on<LoadCalendarEvents>(_onLoadCalendarEvents);
  }

  Future<void> _onLoadCalendarEvents(
    LoadCalendarEvents event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    // Simulate network delay or actual data fetching
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, you would fetch events from a repository
    emit(const CalendarLoaded(events: []));
  }
}
