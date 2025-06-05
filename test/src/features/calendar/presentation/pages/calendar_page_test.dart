import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:planning/src/features/calendar/presentation/pages/calendar_page.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  group('CalendarPage - RED PHASE - Failing Tests for Basic Calendar UI', () {
    testWidgets('should display TableCalendar widget when page loads', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const CalendarPage(),
        ),
      );

      // Assert - This should FAIL initially as CalendarPage doesn't exist
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    testWidgets('should display app bar with Calendar title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const CalendarPage(),
        ),
      );

      // Assert - This should FAIL initially as CalendarPage doesn't exist
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('should display calendar with current month focused', (WidgetTester tester) async {
      // Arrange
      final now = DateTime.now();
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: const CalendarPage(),
        ),
      );

      // Assert - This should FAIL initially as CalendarPage doesn't exist
      final tableCalendar = tester.widget<TableCalendar>(find.byType(TableCalendar));
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
            builder: (context, state) => const CalendarPage(),
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

      // Assert - This should FAIL initially as CalendarPage doesn't exist and route isn't configured
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    testWidgets('should allow date selection interaction', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CalendarPage(),
        ),
      );

      // Act - Tap on a date cell (this is a basic interaction test)
      final dateCell = find.text('15').first; // Find first occurrence of '15'
      await tester.tap(dateCell);
      await tester.pump();

      // Assert - This should FAIL initially as CalendarPage doesn't exist
      // For now, we just verify the page still displays properly after interaction
      expect(find.byType(TableCalendar), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle calendar format changes', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CalendarPage(),
        ),
      );

      // Act - Look for format button (TableCalendar has a built-in format button)
      final formatButton = find.byType(ElevatedButton).first;
      await tester.tap(formatButton);
      await tester.pump();

      // Assert - This should FAIL initially as CalendarPage doesn't exist
      expect(find.byType(TableCalendar), findsOneWidget);
    });
  });
}
