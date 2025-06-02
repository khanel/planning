import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:planning/src/features/scheduling/presentation/widgets/event_card.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';

void main() {
  late ScheduleEvent testEvent;

  setUp(() {
    testEvent = ScheduleEvent(
      id: '1',
      title: 'Meeting',
      description: 'Team meeting discussion',
      startTime: DateTime(2025, 5, 31, 10, 0),
      endTime: DateTime(2025, 5, 31, 11, 0),
      isAllDay: false,
      createdAt: DateTime(2025, 5, 31, 9, 0),
      updatedAt: DateTime(2025, 5, 31, 9, 0),
    );
  });

  Widget createWidgetUnderTest({VoidCallback? onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: EventCard(
          event: testEvent,
          onTap: onTap,
        ),
      ),
    );
  }

  group('EventCard', () {
    testWidgets('should display event title and description', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Meeting'), findsOneWidget);
      expect(find.text('Team meeting discussion'), findsOneWidget);
    });

    testWidgets('should display formatted time for non-all-day events', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('10:00 AM - 11:00 AM'), findsOneWidget);
    });

    testWidgets('should display "All Day" for all-day events', (tester) async {
      // arrange
      final allDayEvent = ScheduleEvent(
        id: '2',
        title: 'Holiday',
        description: 'Public holiday',
        startTime: DateTime(2025, 5, 31),
        endTime: DateTime(2025, 5, 31, 23, 59, 59),
        isAllDay: true,
        createdAt: DateTime(2025, 5, 31, 9, 0),
        updatedAt: DateTime(2025, 5, 31, 9, 0),
      );

      // act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EventCard(
            event: allDayEvent,
            onTap: () {},
          ),
        ),
      ));

      // assert
      expect(find.text('All Day'), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      // arrange
      bool wasTapped = false;
      void onTap() => wasTapped = true;

      // act
      await tester.pumpWidget(createWidgetUnderTest(onTap: onTap));
      await tester.tap(find.byType(Card));

      // assert
      expect(wasTapped, isTrue);
    });

    testWidgets('should display calendar icon', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byIcon(Icons.event), findsOneWidget);
    });

    testWidgets('should display event card with proper styling', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('should handle events with empty description', (tester) async {
      // arrange
      final eventWithoutDescription = ScheduleEvent(
        id: '3',
        title: 'Quick Meeting',
        description: '',
        startTime: DateTime(2025, 5, 31, 14, 0),
        endTime: DateTime(2025, 5, 31, 14, 30),
        isAllDay: false,
        createdAt: DateTime(2025, 5, 31, 9, 0),
        updatedAt: DateTime(2025, 5, 31, 9, 0),
      );

      // act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EventCard(
            event: eventWithoutDescription,
            onTap: () {},
          ),
        ),
      ));

      // assert
      expect(find.text('Quick Meeting'), findsOneWidget);
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('should handle long event titles gracefully', (tester) async {
      // arrange
      final eventWithLongTitle = ScheduleEvent(
        id: '4',
        title: 'This is a very long event title that should be handled gracefully by the UI component',
        description: 'Short description',
        startTime: DateTime(2025, 5, 31, 15, 0),
        endTime: DateTime(2025, 5, 31, 16, 0),
        isAllDay: false,
        createdAt: DateTime(2025, 5, 31, 9, 0),
        updatedAt: DateTime(2025, 5, 31, 9, 0),
      );

      // act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EventCard(
            event: eventWithLongTitle,
            onTap: () {},
          ),
        ),
      ));

      // assert
      expect(find.text('This is a very long event title that should be handled gracefully by the UI component'), findsOneWidget);
    });
  });
}
