import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/calendar/presentation/pages/calendar_page.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';

void main() {
  group('CalendarPage Event Creation', () {
    testWidgets('should display floating action button for adding events', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(),
        ),
      );

      // Should have a floating action button
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show event creation dialog when FAB is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(),
        ),
      );

      // Tap the floating action button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should show event creation dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Create Event'), findsOneWidget);
    });

    testWidgets('should display event creation form fields in dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(),
        ),
      );

      // Open event creation dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should have title text field
      expect(find.byKey(const Key('event_title_field')), findsOneWidget);
      expect(find.text('Event Title'), findsOneWidget);

      // Should have date selection
      expect(find.byKey(const Key('event_date_field')), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);

      // Should have time selection
      expect(find.byKey(const Key('event_time_field')), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);

      // Should have action buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should close dialog when Cancel is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(),
        ),
      );

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should validate required fields and show error when title is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(),
        ),
      );

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Try to save without entering title
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter an event title'), findsOneWidget);
      // Dialog should still be open
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should call onEventCreated callback when valid event is saved', (WidgetTester tester) async {
      ScheduleEvent? createdEvent;
      
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(
            onEventCreated: (event) {
              createdEvent = event;
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill in event details
      await tester.enterText(find.byKey(const Key('event_title_field')), 'Test Event');
      await tester.pumpAndSettle();

      // Save event
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should have called the callback
      expect(createdEvent, isNotNull);
      expect(createdEvent!.title, equals('Test Event'));
      
      // Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should pre-fill selected date in event creation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(),
        ),
      );

      // Tap on a specific date first
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      // Open event creation dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // The date field should show the selected day in the formatted date
      final dateFinder = find.byKey(const Key('event_date_field'));
      expect(dateFinder, findsOneWidget);
      
      final dateWidget = tester.widget<InkWell>(dateFinder);
      final inputDecorator = dateWidget.child as InputDecorator;
      final textWidget = inputDecorator.child as Text;
      expect(textWidget.data, contains('15'));
    });

    testWidgets('should allow date and time modification in creation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(),
        ),
      );

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap on date field to modify
      await tester.tap(find.byKey(const Key('event_date_field')));
      await tester.pumpAndSettle();

      // Should show date picker
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });
}
