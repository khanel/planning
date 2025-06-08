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

    group('LoadCalendarEvents', () {
      // Mock Google Calendar Repository/Service needed here
      // For now, let's assume a simple successful load and an error case

      blocTest<CalendarBloc, CalendarState>(
        'emits [CalendarLoading, CalendarLoaded] when LoadCalendarEvents is added and succeeds',
        build: () {
          // final mockCalendarRepository = MockCalendarRepository();
          // when(() => mockCalendarRepository.fetchEvents()).thenAnswer((_) async => [CalendarEventModel(id: '1', summary: 'Test Event')]);
          // return CalendarBloc(calendarRepository: mockCalendarRepository);
          return CalendarBloc(); // Placeholder until repository is set up
        },
        act: (bloc) => bloc.add(const LoadCalendarEvents()), // Pass simulateError: false (default)
        expect: () => [
          isA<CalendarLoading>(),
          isA<CalendarLoaded>(),
        ],
      );

      blocTest<CalendarBloc, CalendarState>(
        'emits [CalendarLoading, CalendarError] when LoadCalendarEvents is added and fails',
        build: () {
          // final mockCalendarRepository = MockCalendarRepository();
          // when(() => mockCalendarRepository.fetchEvents()).thenThrow(Exception('Failed to load events'));
          // return CalendarBloc(calendarRepository: mockCalendarRepository);
          return CalendarBloc(); // Placeholder until repository is set up
        },
        act: (bloc) => bloc.add(const LoadCalendarEvents(simulateError: true)), // Pass simulateError: true
        expect: () => [
          isA<CalendarLoading>(),
          isA<CalendarError>(),
        ],
      );
    });
  });
}
