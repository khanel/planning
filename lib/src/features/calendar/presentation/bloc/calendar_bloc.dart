import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event_model.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc() : super(CalendarInitial()) {
    on<LoadCalendarEvents>(_onLoadCalendarEvents);
  }

  void _onLoadCalendarEvents(
    LoadCalendarEvents event,
    Emitter<CalendarState> emit,
  ) {
    emit(CalendarLoading());
    try {
      if (event.simulateError) {
        throw Exception('Failed to load events');
      }
      final events = <CalendarEventModel>[];
      emit(CalendarLoaded(events: events));
    } catch (e) {
      emit(CalendarError(message: e.toString()));
    }
  }
}
