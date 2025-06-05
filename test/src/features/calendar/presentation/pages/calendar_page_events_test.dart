import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/calendar/presentation/pages/calendar_page.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  group('CalendarPage Event Support', () {
    late List<ScheduleEvent> testEvents;

    setUp(() {
      testEvents = [
        ScheduleEvent(
          id: 'event1',
          title: 'Morning Meeting',
          startTime: DateTime(2024, 1, 15, 9, 0),
          endTime: DateTime(2024, 1, 15, 10, 0),
          isAllDay: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: CalendarSyncStatus.synced,
        ),
        ScheduleEvent(
          id: 'event2',
          title: 'All Day Event',
          startTime: DateTime(2024, 1, 15),
          endTime: DateTime(2024, 1, 15),
          isAllDay: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: CalendarSyncStatus.syncing,
        ),
        ScheduleEvent(
          id: 'event3',
          title: 'Evening Call',
          startTime: DateTime(2024, 1, 16, 18, 0),
          endTime: DateTime(2024, 1, 16, 19, 0),
          isAllDay: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: CalendarSyncStatus.synced,
        ),
      ];
    });

    testWidgets('should display events as markers on calendar days', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(events: testEvents),
        ),
      );

      // Calendar should be visible
      expect(find.byType(TableCalendar<ScheduleEvent>), findsOneWidget);

      // Events should be loaded for TableCalendar
      final calendar = tester.widget<TableCalendar<ScheduleEvent>>(find.byType(TableCalendar<ScheduleEvent>));
      expect(calendar.eventLoader, isNotNull);

      // Event loader should return events for the correct dates
      final eventsFor15th = calendar.eventLoader!(DateTime(2024, 1, 15));
      expect(eventsFor15th.length, equals(2)); // Morning Meeting + All Day Event
      
      final eventsFor16th = calendar.eventLoader!(DateTime(2024, 1, 16));
      expect(eventsFor16th.length, equals(1)); // Evening Call
      
      final eventsForEmpty = calendar.eventLoader!(DateTime(2024, 1, 17));
      expect(eventsForEmpty.length, equals(0)); // No events
    });

    testWidgets('should display selected day events list below calendar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(events: testEvents),
        ),
      );

      // Initially no day is selected, so no events list should be shown
      expect(find.text('Events for selected day'), findsNothing);

      // Tap on a day with events (January 15, 2024)
      final calendar = tester.widget<TableCalendar<ScheduleEvent>>(find.byType(TableCalendar<ScheduleEvent>));
      if (calendar.onDaySelected != null) {
        calendar.onDaySelected!(DateTime(2024, 1, 15), DateTime(2024, 1, 15));
      }
      await tester.pump();

      // Events list should be visible
      expect(find.text('Events for selected day'), findsOneWidget);
      expect(find.text('Morning Meeting'), findsOneWidget);
      expect(find.text('All Day Event'), findsOneWidget);
    });

    testWidgets('should show empty message when selected day has no events', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(events: testEvents),
        ),
      );

      // Tap on a day with no events (January 17, 2024)
      final calendar = tester.widget<TableCalendar<ScheduleEvent>>(find.byType(TableCalendar<ScheduleEvent>));
      if (calendar.onDaySelected != null) {
        calendar.onDaySelected!(DateTime(2024, 1, 17), DateTime(2024, 1, 17));
      }
      await tester.pump();

      // Should show empty message
      expect(find.text('Events for selected day'), findsOneWidget);
      expect(find.text('No events for this day'), findsOneWidget);
    });

    testWidgets('should handle event time display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(events: testEvents),
        ),
      );

      // Select day with events
      final calendar = tester.widget<TableCalendar<ScheduleEvent>>(find.byType(TableCalendar<ScheduleEvent>));
      if (calendar.onDaySelected != null) {
        calendar.onDaySelected!(DateTime(2024, 1, 15), DateTime(2024, 1, 15));
      }
      await tester.pump();

      // All-day events should show "All Day"
      expect(find.text('All Day'), findsOneWidget);
      
      // Timed events should show time range
      expect(find.text('09:00 - 10:00'), findsOneWidget);
    });

    testWidgets('should display event markers on calendar when events exist', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(events: testEvents),
        ),
      );

      // Calendar should use event loader
      final calendar = tester.widget<TableCalendar<ScheduleEvent>>(find.byType(TableCalendar<ScheduleEvent>));
      expect(calendar.eventLoader, isNotNull);
      
      // Calendar should have marker builder for displaying event indicators
      expect(calendar.calendarBuilders, isNotNull);
      expect(calendar.calendarBuilders.markerBuilder, isNotNull);
    });

    testWidgets('should handle empty events list gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(events: []),
        ),
      );

      // Calendar should still be functional
      expect(find.byType(TableCalendar<ScheduleEvent>), findsOneWidget);
      
      // Event loader should return empty lists
      final calendar = tester.widget<TableCalendar<ScheduleEvent>>(find.byType(TableCalendar<ScheduleEvent>));
      expect(calendar.eventLoader, isNotNull);
      
      final events = calendar.eventLoader!(DateTime(2024, 1, 15));
      expect(events.length, equals(0));
    });
  });
}
