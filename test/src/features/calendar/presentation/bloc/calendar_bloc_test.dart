import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/calendar/presentation/bloc/calendar_bloc.dart';

void main() {
  group('CalendarBloc', () {
    blocTest<CalendarBloc, CalendarState>(
      'emits [] when nothing is added',
      build: () => CalendarBloc(),
      expect: () => [],
    );

    blocTest<CalendarBloc, CalendarState>(
      'emits [CalendarInitial] when created',
      build: () => CalendarBloc(),
      expect: () => [],
    );

    test('initial state is CalendarInitial', () {
      expect(CalendarBloc().state, isA<CalendarInitial>());
    });
  });
}
