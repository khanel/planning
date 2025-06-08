import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event_model.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart' as domain;
import 'package:planning/src/core/errors/failures.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarRepository repository;

  CalendarBloc({required this.repository}) : super(CalendarInitial()) {
    on<LoadCalendarEvents>(_onLoadCalendarEvents);
  }

  // Handles the LoadCalendarEvents event.
  // Now uses repository to fetch real calendar data from Google Calendar API
  // Maps domain entities to presentation models and handles failures
  Future<void> _onLoadCalendarEvents(
    LoadCalendarEvents event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    
    try {
      // Check if we should simulate error for backward compatibility
      if (event.simulateError) {
        throw Exception('Failed to load events (simulated)');
      }

      // Call repository to get events with default parameters
      final timeMin = DateTime.now().subtract(const Duration(days: 180));
      final timeMax = DateTime.now().add(const Duration(days: 180));
      
      final result = await repository.getEvents(
        timeMin: timeMin,
        timeMax: timeMax,
        calendarId: 'primary',
        maxResults: 100,
      );
      
      result.fold(
        (failure) {
          // Map failures to user-friendly error messages
          final errorMessage = _mapFailureToMessage(failure);
          emit(CalendarError(message: errorMessage));
        },
        (domainEvents) {
          // Convert domain entities to presentation models
          final events = domainEvents.map((domainEvent) => CalendarEventModel(
            id: domainEvent.id,
            summary: domainEvent.title,
          )).toList();
          emit(CalendarLoaded(events: events));
        },
      );
    } catch (e) {
      // Handle any unexpected exceptions
      emit(CalendarError(message: e.toString()));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      case AuthFailure:
        return 'Authentication failed. Please sign in again.';
      case ServerFailure:
        return 'Server error. Please try again later.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
