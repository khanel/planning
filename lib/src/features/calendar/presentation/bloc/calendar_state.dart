part of 'calendar_bloc.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object> get props => [];
}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarLoaded extends CalendarState {
  final List<CalendarEventModel> events;

  const CalendarLoaded({required this.events});

  @override
  List<Object> get props => [events];
}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError({required this.message});

  @override
  List<Object> get props => [message];
}
