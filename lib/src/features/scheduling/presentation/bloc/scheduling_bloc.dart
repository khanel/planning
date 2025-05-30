import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/core/errors/failures.dart';
import '../../domain/entities/schedule_event.dart';
import '../../domain/usecases/create_event_usecase.dart';
import '../../domain/usecases/get_events_usecase.dart';
import '../../domain/usecases/update_event_usecase.dart';
import '../../domain/usecases/delete_event_usecase.dart';
import '../../domain/usecases/get_events_by_date_range_usecase.dart';
import '../../domain/usecases/get_events_by_task_id_usecase.dart';

part 'scheduling_event.dart';
part 'scheduling_state.dart';

/// Business Logic Component for managing scheduling state.
/// 
/// Handles all scheduling-related events including:
/// - Loading events
/// - Creating new events
/// - Updating existing events
/// - Deleting events
/// - Loading events by date range
/// - Loading events by task ID
/// 
/// Follows clean architecture principles with dependency injection
/// of use cases for business logic operations.
class SchedulingBloc extends Bloc<SchedulingEvent, SchedulingState> {
  final CreateEventUseCase createEvent;
  final GetEventsUseCase getEvents;
  final UpdateEventUseCase updateEvent;
  final DeleteEventUseCase deleteEvent;
  final GetEventsByDateRangeUseCase getEventsByDateRange;
  final GetEventsByTaskIdUseCase getEventsByTaskId;

  SchedulingBloc({
    required this.createEvent,
    required this.getEvents,
    required this.updateEvent,
    required this.deleteEvent,
    required this.getEventsByDateRange,
    required this.getEventsByTaskId,
  }) : super(const SchedulingInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<CreateEvent>(_onCreateEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<LoadEventsByDateRange>(_onLoadEventsByDateRange);
    on<LoadEventsByTaskId>(_onLoadEventsByTaskId);
  }

  Future<void> _onLoadEvents(
    LoadEvents event,
    Emitter<SchedulingState> emit,
  ) async {
    emit(const SchedulingLoading());
    final result = await getEvents(NoParams());

    result.fold(
      (failure) => emit(SchedulingError(message: _mapFailureToMessage(failure))),
      (events) => emit(SchedulingEventsLoaded(events: events)),
    );
  }

  Future<void> _onCreateEvent(
    CreateEvent event,
    Emitter<SchedulingState> emit,
  ) async {
    emit(const SchedulingLoading());
    final result = await createEvent(CreateEventParams(event: event.event));

    await result.fold(
      (failure) async => emit(SchedulingError(message: _mapFailureToMessage(failure))),
      (createdEvent) async {
        emit(SchedulingEventCreated(event: createdEvent));
        // Reload events to update the UI
        await _reloadEvents(emit);
      },
    );
  }

  Future<void> _onUpdateEvent(
    UpdateEvent event,
    Emitter<SchedulingState> emit,
  ) async {
    emit(const SchedulingLoading());
    final result = await updateEvent(UpdateEventParams(event: event.event));

    await result.fold(
      (failure) async => emit(SchedulingError(message: _mapFailureToMessage(failure))),
      (updatedEvent) async {
        emit(SchedulingEventUpdated(event: updatedEvent));
        // Reload events to update the UI
        await _reloadEvents(emit);
      },
    );
  }

  Future<void> _onDeleteEvent(
    DeleteEvent event,
    Emitter<SchedulingState> emit,
  ) async {
    emit(const SchedulingLoading());
    final result = await deleteEvent(DeleteEventParams(eventId: event.eventId));

    await result.fold(
      (failure) async => emit(SchedulingError(message: _mapFailureToMessage(failure))),
      (_) async {
        emit(SchedulingEventDeleted(eventId: event.eventId));
        // Reload events to update the UI
        await _reloadEvents(emit);
      },
    );
  }

  Future<void> _onLoadEventsByDateRange(
    LoadEventsByDateRange event,
    Emitter<SchedulingState> emit,
  ) async {
    emit(const SchedulingLoading());
    
    // Validate date range
    if (event.endDate.isBefore(event.startDate)) {
      emit(const SchedulingError(message: 'End date cannot be before start date'));
      return;
    }
    
    final result = await getEventsByDateRange(
      GetEventsByDateRangeParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(SchedulingError(message: _mapFailureToMessage(failure))),
      (events) => emit(SchedulingEventsByDateRangeLoaded(
        events: events,
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }

  Future<void> _onLoadEventsByTaskId(
    LoadEventsByTaskId event,
    Emitter<SchedulingState> emit,
  ) async {
    emit(const SchedulingLoading());
    
    // Validate task ID
    if (event.taskId.trim().isEmpty) {
      emit(const SchedulingError(message: 'Task ID cannot be empty'));
      return;
    }
    
    final result = await getEventsByTaskId(
      GetEventsByTaskIdParams(taskId: event.taskId),
    );

    result.fold(
      (failure) => emit(SchedulingError(message: _mapFailureToMessage(failure))),
      (events) => emit(SchedulingEventsByTaskIdLoaded(
        events: events,
        taskId: event.taskId,
      )),
    );
  }

  /// Helper method to reload events and emit the appropriate state
  Future<void> _reloadEvents(Emitter<SchedulingState> emit) async {
    final eventsResult = await getEvents(NoParams());
    eventsResult.fold(
      (failure) => emit(SchedulingError(message: _mapFailureToMessage(failure))),
      (events) => emit(SchedulingEventsLoaded(events: events)),
    );
  }

  /// Maps failures to user-friendly error messages
  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      CacheFailure() => failure.message.isNotEmpty 
          ? failure.message 
          : 'Local storage error occurred',
      NetworkFailure() => failure.message.isNotEmpty 
          ? failure.message 
          : 'Network connection error',
      ServerFailure() => 'Server error occurred. Please try again later.',
      ValidationFailure() => failure.message.isNotEmpty 
          ? failure.message 
          : 'Invalid input provided',
      _ => 'An unexpected error occurred. Please try again.',
    };
  }
}
