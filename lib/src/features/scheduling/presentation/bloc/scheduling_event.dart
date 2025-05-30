part of 'scheduling_bloc.dart';

abstract class SchedulingEvent extends Equatable {
  const SchedulingEvent();

  @override
  List<Object?> get props => [];
}

class LoadEvents extends SchedulingEvent {
  const LoadEvents();
}

class CreateEvent extends SchedulingEvent {
  final ScheduleEvent event;

  const CreateEvent({required this.event});

  @override
  List<Object> get props => [event];
}

class UpdateEvent extends SchedulingEvent {
  final ScheduleEvent event;

  const UpdateEvent({required this.event});

  @override
  List<Object> get props => [event];
}

class DeleteEvent extends SchedulingEvent {
  final String eventId;

  const DeleteEvent({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

class LoadEventsByDateRange extends SchedulingEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadEventsByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

class LoadEventsByTaskId extends SchedulingEvent {
  final String taskId;

  const LoadEventsByTaskId({required this.taskId});

  @override
  List<Object> get props => [taskId];
}
