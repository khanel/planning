part of 'scheduling_bloc.dart';

abstract class SchedulingState extends Equatable {
  const SchedulingState();

  @override
  List<Object?> get props => [];
}

class SchedulingInitial extends SchedulingState {
  const SchedulingInitial();
}

class SchedulingLoading extends SchedulingState {
  const SchedulingLoading();
}

class SchedulingEventsLoaded extends SchedulingState {
  final List<ScheduleEvent> events;

  const SchedulingEventsLoaded({required this.events});

  @override
  List<Object> get props => [events];
}

class SchedulingEventCreated extends SchedulingState {
  final ScheduleEvent event;

  const SchedulingEventCreated({required this.event});

  @override
  List<Object> get props => [event];
}

class SchedulingEventUpdated extends SchedulingState {
  final ScheduleEvent event;

  const SchedulingEventUpdated({required this.event});

  @override
  List<Object> get props => [event];
}

class SchedulingEventDeleted extends SchedulingState {
  final String eventId;

  const SchedulingEventDeleted({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

class SchedulingEventsByDateRangeLoaded extends SchedulingState {
  final List<ScheduleEvent> events;
  final DateTime startDate;
  final DateTime endDate;

  const SchedulingEventsByDateRangeLoaded({
    required this.events,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [events, startDate, endDate];
}

class SchedulingEventsByTaskIdLoaded extends SchedulingState {
  final List<ScheduleEvent> events;
  final String taskId;

  const SchedulingEventsByTaskIdLoaded({
    required this.events,
    required this.taskId,
  });

  @override
  List<Object> get props => [events, taskId];
}

class SchedulingError extends SchedulingState {
  final String message;

  const SchedulingError({required this.message});

  @override
  List<Object> get props => [message];
}
