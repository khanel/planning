part of 'calendar_bloc.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object> get props => [];
}

class LoadCalendarEvents extends CalendarEvent {
  final bool simulateError;

  const LoadCalendarEvents({this.simulateError = false});

  @override
  List<Object> get props => [simulateError];
}
