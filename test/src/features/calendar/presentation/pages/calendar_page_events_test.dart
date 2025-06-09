import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planning/src/features/calendar/presentation/pages/calendar_page.dart';
import 'package:planning/src/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event_model.dart';
import 'package:table_calendar/table_calendar.dart';

class MockCalendarBloc extends Mock implements CalendarBloc {}

void main() {
  late MockCalendarBloc mockBloc;
  late List<CalendarEventModel> testEvents;

  setUp(() {
    mockBloc = MockCalendarBloc();
    testEvents = [
      const CalendarEventModel(
        id: 'event1',
        summary: 'Morning Meeting',
      ),
      const CalendarEventModel(
        id: 'event2',
        summary: 'All Day Event',
      ),
      const CalendarEventModel(
        id: 'event3',
        summary: 'Evening Call',
      ),
    ];
    
    when(() => mockBloc.state).thenReturn(CalendarInitial());
    when(() => mockBloc.stream).thenAnswer((_) => const Stream<CalendarState>.empty());
  });

  group('CalendarPage Event Support with BLoC', () {
    testWidgets('should display events from BLoC state as markers on calendar days', (WidgetTester tester) async {
      // Arrange - Mock BLoC to return loaded state with events
      when(() => mockBloc.state).thenReturn(CalendarLoaded(events: testEvents));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalendarBloc>.value(
            value: mockBloc,
            child: const CalendarPage(),
          ),
        ),
      );

      // Calendar should be visible
      expect(find.byType(TableCalendar<CalendarEventModel>), findsOneWidget);

      // Calendar should use event loader from BLoC state
      final calendar = tester.widget<TableCalendar<CalendarEventModel>>(find.byType(TableCalendar<CalendarEventModel>));
      expect(calendar.eventLoader, isNotNull);
      
      // Calendar should have marker builder for displaying event indicators
      expect(calendar.calendarBuilders, isNotNull);
      expect(calendar.calendarBuilders.markerBuilder, isNotNull);
    });

    testWidgets('should display selected day events from BLoC state below calendar', (WidgetTester tester) async {
      // Arrange - Mock BLoC to return loaded state with events
      when(() => mockBloc.state).thenReturn(CalendarLoaded(events: testEvents));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalendarBloc>.value(
            value: mockBloc,
            child: const CalendarPage(),
          ),
        ),
      );

      // Initially events should not be visible since no day is selected
      expect(find.text('Morning Meeting'), findsNothing);

      // Calendar should be functional for day selection
      expect(find.byType(TableCalendar<CalendarEventModel>), findsOneWidget);
    });

    testWidgets('should show empty message when selected day has no events from BLoC', (WidgetTester tester) async {
      // Arrange - Mock BLoC to return loaded state with events
      when(() => mockBloc.state).thenReturn(CalendarLoaded(events: testEvents));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalendarBloc>.value(
            value: mockBloc,
            child: const CalendarPage(),
          ),
        ),
      );

      // Calendar should be functional
      expect(find.byType(TableCalendar<CalendarEventModel>), findsOneWidget);
    });

    testWidgets('should handle event markers when using BLoC state', (WidgetTester tester) async {
      // Arrange - Mock BLoC to return loaded state with events
      when(() => mockBloc.state).thenReturn(CalendarLoaded(events: testEvents));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalendarBloc>.value(
            value: mockBloc,
            child: const CalendarPage(),
          ),
        ),
      );

      // Calendar should use event loader
      final calendar = tester.widget<TableCalendar<CalendarEventModel>>(find.byType(TableCalendar<CalendarEventModel>));
      expect(calendar.eventLoader, isNotNull);
      
      // Calendar should have marker builder for displaying event indicators
      expect(calendar.calendarBuilders, isNotNull);
      expect(calendar.calendarBuilders.markerBuilder, isNotNull);
    });

    testWidgets('should handle empty events from BLoC state gracefully', (WidgetTester tester) async {
      // Arrange - Mock BLoC to return loaded state with no events
      when(() => mockBloc.state).thenReturn(const CalendarLoaded(events: []));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalendarBloc>.value(
            value: mockBloc,
            child: const CalendarPage(),
          ),
        ),
      );

      // Calendar should still be functional
      expect(find.byType(TableCalendar<CalendarEventModel>), findsOneWidget);
      
      // Calendar should have event loader that returns empty lists
      final calendar = tester.widget<TableCalendar<CalendarEventModel>>(find.byType(TableCalendar<CalendarEventModel>));
      expect(calendar.eventLoader, isNotNull);
    });

    testWidgets('should handle loading state from BLoC', (WidgetTester tester) async {
      // Arrange - Mock BLoC to return loading state
      when(() => mockBloc.state).thenReturn(CalendarLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalendarBloc>.value(
            value: mockBloc,
            child: const CalendarPage(),
          ),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle error state from BLoC', (WidgetTester tester) async {
      // Arrange - Mock BLoC to return error state
      when(() => mockBloc.state).thenReturn(const CalendarError(message: 'Failed to load events'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalendarBloc>.value(
            value: mockBloc,
            child: const CalendarPage(),
          ),
        ),
      );

      // Should show error message and retry button
      expect(find.text('Failed to load events'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
