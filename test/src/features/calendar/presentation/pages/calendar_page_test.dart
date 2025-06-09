import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planning/src/features/calendar/presentation/pages/calendar_page.dart';
import 'package:planning/src/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event_model.dart';
import 'package:table_calendar/table_calendar.dart';

class MockCalendarBloc extends Mock implements CalendarBloc {}

void main() {
  late MockCalendarBloc mockBloc;

  setUp(() {
    mockBloc = MockCalendarBloc();
    when(() => mockBloc.state).thenReturn(CalendarInitial());
    when(() => mockBloc.stream).thenAnswer((_) => const Stream<CalendarState>.empty());
  });

  group('CalendarPage Basic UI Tests', () {
    testWidgets('should display TableCalendar widget when page loads', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalendarBloc>.value(
            value: mockBloc,
            child: const CalendarPage(),
          ),
        ),
      );

      // Assert
      expect(find.byType(TableCalendar<CalendarEventModel>), findsOneWidget);
    });

    testWidgets('should display app bar with Calendar title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalendarBloc>.value(
            value: mockBloc,
            child: const CalendarPage(),
          ),
        ),
      );

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('should display calendar with current month focused', (WidgetTester tester) async {
      // Arrange
      final now = DateTime.now();
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalendarBloc>.value(
            value: mockBloc,
            child: const CalendarPage(),
          ),
        ),
      );

      // Assert
      final tableCalendar = tester.widget<TableCalendar<CalendarEventModel>>(find.byType(TableCalendar<CalendarEventModel>));
      expect(tableCalendar.focusedDay.month, now.month);
      expect(tableCalendar.focusedDay.year, now.year);
    });

    testWidgets('should be navigatable via GoRouter route', (WidgetTester tester) async {
      // Arrange
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home')),
            ),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => BlocProvider<CalendarBloc>.value(
              value: mockBloc,
              child: const CalendarPage(),
            ),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Navigate to calendar page
      router.push('/calendar');
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(find.byType(TableCalendar<CalendarEventModel>), findsOneWidget);
    });

    testWidgets('should allow date selection interaction', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalendarBloc>.value(
            value: mockBloc,
            child: const CalendarPage(),
          ),
        ),
      );

      // Act - Tap on a date cell (this is a basic interaction test)
      final dateCell = find.text('15').first; // Find first occurrence of '15'
      await tester.tap(dateCell);
      await tester.pump();

      // Assert
      // For now, we just verify the page still displays properly after interaction
      expect(find.byType(TableCalendar<CalendarEventModel>), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle calendar format changes', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalendarBloc>.value(
            value: mockBloc,
            child: const CalendarPage(),
          ),
        ),
      );

      // Act - Look for format button (TableCalendar has a built-in format button)
      final formatButton = find.byType(ElevatedButton).first;
      await tester.tap(formatButton);
      await tester.pump();

      // Assert
      expect(find.byType(TableCalendar<CalendarEventModel>), findsOneWidget);
    });
  });
}
