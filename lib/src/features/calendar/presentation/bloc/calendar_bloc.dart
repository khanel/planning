import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event_model.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart' as domain;
import 'package:planning/src/core/errors/failures.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

/// BLoC that manages calendar events state and business logic.
/// 
/// Handles loading events from Google Calendar API through the repository pattern,
/// mapping domain entities to presentation models, and managing error states.
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  /// Repository for calendar data operations
  final CalendarRepository repository;

  /// Default date range for fetching calendar events (6 months)
  static const int _defaultDateRangeMonths = 6;
  
  /// Default maximum number of events to fetch
  static const int _defaultMaxResults = 100;
  
  /// Default calendar ID for primary calendar
  static const String _primaryCalendarId = 'primary';

  CalendarBloc({required this.repository}) : super(CalendarInitial()) {
    on<LoadCalendarEvents>(_onLoadCalendarEvents);
    on<CreateCalendarEvent>(_onCreateCalendarEvent);
  }

  /// Handles the [LoadCalendarEvents] event.
  /// 
  /// Fetches calendar events from the repository and emits appropriate states.
  /// Maps domain entities to presentation models and handles various failure scenarios.
  /// 
  /// Emits:
  /// - [CalendarLoading] while fetching data
  /// - [CalendarLoaded] with events on success
  /// - [CalendarError] with user-friendly message on failure
  Future<void> _onLoadCalendarEvents(
    LoadCalendarEvents event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    
    try {
      // Maintain backward compatibility with simulateError flag
      if (event.simulateError) {
        throw Exception('Failed to load events (simulated)');
      }

      // Calculate date range for event fetching
      final now = DateTime.now();
      final timeMin = now.subtract(Duration(days: _defaultDateRangeMonths * 30));
      final timeMax = now.add(Duration(days: _defaultDateRangeMonths * 30));
      
      // Fetch events from repository
      final result = await repository.getEvents(
        timeMin: timeMin,
        timeMax: timeMax,
        calendarId: _primaryCalendarId,
        maxResults: _defaultMaxResults,
      );
      
      // Handle result and emit appropriate state
      result.fold(
        (failure) => emit(CalendarError(message: _mapFailureToMessage(failure))),
        (domainEvents) => emit(CalendarLoaded(events: _mapDomainEventsToModels(domainEvents))),
      );
    } catch (error) {
      // Handle any unexpected exceptions
      // Maintain backward compatibility with exact error message format
      final errorMessage = error.toString();
      emit(CalendarError(message: errorMessage));
    }
  }

  /// Handles the [CreateCalendarEvent] event.
  /// 
  /// Creates a new calendar event in the repository and emits appropriate states.
  /// 
  /// Emits:
  /// - [CalendarCreatingEvent] while creating the event
  /// - [CalendarEventCreated] with created event on success
  /// - [CalendarError] with user-friendly message on failure
  Future<void> _onCreateCalendarEvent(
    CreateCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarCreatingEvent());
    
    try {
      // Convert presentation model to domain entity with minimal required fields
      final now = DateTime.now();
      final domainEvent = domain.CalendarEvent(
        id: event.event.id,
        title: event.event.summary,
        description: '', // Minimal value for GREEN phase
        startTime: now, // Minimal value for GREEN phase
        endTime: now.add(Duration(hours: 1)), // Minimal value for GREEN phase
        isAllDay: false, // Minimal value for GREEN phase
      );
      
      // Create event using repository
      final result = await repository.createEvent(
        event: domainEvent,
        calendarId: _primaryCalendarId,
      );
      
      // Handle result and emit appropriate state
      result.fold(
        (failure) => emit(CalendarError(message: _mapFailureToMessage(failure))),
        (createdEvent) => emit(CalendarEventCreated(
          createdEvent: CalendarEventModel(
            id: createdEvent.id,
            summary: createdEvent.title,
          ),
        )),
      );
    } catch (error) {
      emit(CalendarError(message: error.toString()));
    }
  }

  /// Maps domain [CalendarEvent] entities to presentation [CalendarEventModel] models.
  /// 
  /// This ensures proper separation between domain and presentation layers.
  List<CalendarEventModel> _mapDomainEventsToModels(List<domain.CalendarEvent> domainEvents) {
    return domainEvents.map((domainEvent) => CalendarEventModel(
      id: domainEvent.id,
      summary: domainEvent.title,
      // TODO: Extend CalendarEventModel to include more fields as needed
      // startTime: domainEvent.startTime,
      // endTime: domainEvent.endTime,
      // description: domainEvent.description,
    )).toList();
  }

  /// Maps [Failure] objects to user-friendly error messages.
  /// 
  /// This provides consistent error messaging throughout the application
  /// and helps maintain a good user experience.
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
