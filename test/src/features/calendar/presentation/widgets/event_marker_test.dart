import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/calendar/presentation/widgets/event_marker.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';

void main() {
  group('EventMarker Widget Tests', () {
    // Helper function to create test events
    ScheduleEvent createTestEvent({
      String id = 'test-id',
      String title = 'Test Event',
      String? description,
      required DateTime startTime,
      required DateTime endTime,
      bool isAllDay = false,
    }) {
      return ScheduleEvent(
        id: id,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        isAllDay: isAllDay,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: CalendarSyncStatus.notSynced,
      );
    }

    group('Basic Rendering Tests', () {
      testWidgets('should return SizedBox.shrink when events list is empty', (WidgetTester tester) async {
        // Arrange
        const emptyEvents = <ScheduleEvent>[];
        final testDay = DateTime(2024, 1, 15);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: emptyEvents,
              ),
            ),
          ),
        );

        // Assert
        final sizedBoxFinder = find.byType(SizedBox);
        expect(sizedBoxFinder, findsOneWidget);
        
        final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
        expect(sizedBox.width, equals(0.0));
        expect(sizedBox.height, equals(0.0));
        
        // Verify that no Container is present when empty
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsNothing);
      });

      testWidgets('should display a marker when there is exactly one event', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final singleEvent = createTestEvent(
          id: 'event-1',
          title: 'Single Event',
          startTime: DateTime(2024, 1, 15, 10, 0),
          endTime: DateTime(2024, 1, 15, 11, 0),
        );
        final events = [singleEvent];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: events,
              ),
            ),
          ),
        );

        // Assert
        // Should display a Container as marker
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsOneWidget);
        
        // Should not display SizedBox.shrink
        final sizedBoxFinder = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.width == 0.0 && widget.height == 0.0,
        );
        expect(sizedBoxFinder, findsNothing);
        
        // Verify marker has basic styling
        final container = tester.widget<Container>(containerFinder);
        expect(container.decoration, isA<BoxDecoration>());
        
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.shape, equals(BoxShape.circle));
        expect(decoration.color, isNotNull);
      });

      testWidgets('should not show count text for single event', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final singleEvent = createTestEvent(
          id: 'event-1',
          title: 'Single Event',
          startTime: DateTime(2024, 1, 15, 10, 0),
          endTime: DateTime(2024, 1, 15, 11, 0),
        );
        final events = [singleEvent];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: events,
              ),
            ),
          ),
        );

        // Assert
        // Should not display any Text widget for count
        final textFinder = find.byType(Text);
        expect(textFinder, findsNothing);
      });

      testWidgets('should display a marker with count when there are multiple events', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final events = [
          createTestEvent(
            id: 'event-1',
            title: 'Event 1',
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 11, 0),
          ),
          createTestEvent(
            id: 'event-2',
            title: 'Event 2',
            startTime: DateTime(2024, 1, 15, 14, 0),
            endTime: DateTime(2024, 1, 15, 15, 0),
          ),
          createTestEvent(
            id: 'event-3',
            title: 'Event 3',
            startTime: DateTime(2024, 1, 15, 16, 0),
            endTime: DateTime(2024, 1, 15, 17, 0),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: events,
              ),
            ),
          ),
        );

        // Assert
        // Should display a Container as marker
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsOneWidget);
        
        // Should display count text for multiple events
        final textFinder = find.byType(Text);
        expect(textFinder, findsOneWidget);
        
        final text = tester.widget<Text>(textFinder);
        expect(text.data, equals('3'));
        
        // Verify marker has basic styling
        final container = tester.widget<Container>(containerFinder);
        expect(container.decoration, isA<BoxDecoration>());
        
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.shape, equals(BoxShape.circle));
        expect(decoration.color, isNotNull);
      });

      testWidgets('should show correct count text for multiple events (2-9)', (WidgetTester tester) async {
        // Test with 5 events
        final testDay = DateTime(2024, 1, 15);
        final events = List.generate(5, (index) => createTestEvent(
          id: 'event-$index',
          title: 'Event $index',
          startTime: DateTime(2024, 1, 15, 10 + index, 0),
          endTime: DateTime(2024, 1, 15, 11 + index, 0),
        ));

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: events,
              ),
            ),
          ),
        );

        // Assert
        final textFinder = find.byType(Text);
        expect(textFinder, findsOneWidget);
        
        final text = tester.widget<Text>(textFinder);
        expect(text.data, equals('5'));
      });

      testWidgets('should show 9+ for events count of 10 or more', (WidgetTester tester) async {
        // Test with 12 events
        final testDay = DateTime(2024, 1, 15);
        final events = List.generate(12, (index) => createTestEvent(
          id: 'event-$index',
          title: 'Event $index',
          startTime: DateTime(2024, 1, 15, 8 + (index % 12), 0),
          endTime: DateTime(2024, 1, 15, 9 + (index % 12), 0),
        ));

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: events,
              ),
            ),
          ),
        );

        // Assert
        final textFinder = find.byType(Text);
        expect(textFinder, findsOneWidget);
        
        final text = tester.widget<Text>(textFinder);
        expect(text.data, equals('9+'));
      });

      testWidgets('should only display events for the specific day', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final events = [
          // Event on the test day
          createTestEvent(
            id: 'event-1',
            title: 'Today Event',
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 11, 0),
          ),
          // Event on different day - should be ignored
          createTestEvent(
            id: 'event-2',
            title: 'Tomorrow Event',
            startTime: DateTime(2024, 1, 16, 10, 0),
            endTime: DateTime(2024, 1, 16, 11, 0),
          ),
          // Event on previous day - should be ignored
          createTestEvent(
            id: 'event-3',
            title: 'Yesterday Event',
            startTime: DateTime(2024, 1, 14, 10, 0),
            endTime: DateTime(2024, 1, 14, 11, 0),
          ),
          // Another event on the test day
          createTestEvent(
            id: 'event-4',
            title: 'Another Today Event',
            startTime: DateTime(2024, 1, 15, 14, 0),
            endTime: DateTime(2024, 1, 15, 15, 0),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: events,
              ),
            ),
          ),
        );

        // Assert
        // Should display marker with count 2 (only events for testDay)
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsOneWidget);
        
        final textFinder = find.byType(Text);
        expect(textFinder, findsOneWidget);
        
        final text = tester.widget<Text>(textFinder);
        expect(text.data, equals('2'));
      });

      testWidgets('should handle events spanning multiple days correctly', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final events = [
          // Multi-day event that starts on test day
          createTestEvent(
            id: 'event-1',
            title: 'Multi-day Event',
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 16, 11, 0),
          ),
          // Multi-day event that ends on test day
          createTestEvent(
            id: 'event-2',
            title: 'Another Multi-day Event',
            startTime: DateTime(2024, 1, 14, 10, 0),
            endTime: DateTime(2024, 1, 15, 11, 0),
          ),
          // Regular event on test day
          createTestEvent(
            id: 'event-3',
            title: 'Regular Event',
            startTime: DateTime(2024, 1, 15, 14, 0),
            endTime: DateTime(2024, 1, 15, 15, 0),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: events,
              ),
            ),
          ),
        );

        // Assert
        // Should display marker with count 3 (all events that intersect with testDay)
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsOneWidget);
        
        final textFinder = find.byType(Text);
        expect(textFinder, findsOneWidget);
        
        final text = tester.widget<Text>(textFinder);
        expect(text.data, equals('3'));
      });
    });

    group('Layout and Positioning Tests', () {
      testWidgets('should apply correct top padding to the marker', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final events = [
          createTestEvent(
            id: 'event-1',
            title: 'Test Event',
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 11, 0),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: events,
              ),
            ),
          ),
        );

        // Assert
        final paddingFinder = find.byType(Padding);
        expect(paddingFinder, findsOneWidget);
        
        final padding = tester.widget<Padding>(paddingFinder);
        expect(padding.padding, equals(const EdgeInsets.only(top: 5.0)));
      });

      testWidgets('should center the marker horizontally within its container', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final events = [
          createTestEvent(
            id: 'event-1',
            title: 'Test Event',
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 11, 0),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: events,
              ),
            ),
          ),
        );

        // Assert
        final rowFinder = find.byType(Row);
        expect(rowFinder, findsOneWidget);
        
        final row = tester.widget<Row>(rowFinder);
        expect(row.mainAxisAlignment, equals(MainAxisAlignment.center));
      });

      testWidgets('should have correct marker size dimensions', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final events = [
          createTestEvent(
            id: 'event-1',
            title: 'Test Event',
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 11, 0),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: events,
              ),
            ),
          ),
        );

        // Assert
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsOneWidget);
        
        final container = tester.widget<Container>(containerFinder);
        expect(container.constraints?.minWidth, equals(6.0));
        expect(container.constraints?.maxWidth, equals(6.0));
        expect(container.constraints?.minHeight, equals(6.0));
        expect(container.constraints?.maxHeight, equals(6.0));
      });

      testWidgets('should position marker and count badge side by side', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final events = [
          createTestEvent(
            id: 'event-1',
            title: 'Event 1',
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 11, 0),
          ),
          createTestEvent(
            id: 'event-2',
            title: 'Event 2',
            startTime: DateTime(2024, 1, 15, 14, 0),
            endTime: DateTime(2024, 1, 15, 15, 0),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: events,
              ),
            ),
          ),
        );

        // Assert
        final rowFinder = find.byType(Row);
        expect(rowFinder, findsOneWidget);
        
        final row = tester.widget<Row>(rowFinder);
        expect(row.children.length, equals(2));
        
        // First child should be Container (marker)
        expect(row.children[0], isA<Container>());
        // Second child should be Text (count badge)
        expect(row.children[1], isA<Text>());
      });

      testWidgets('should calculate correct overall widget size for single event', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final events = [
          createTestEvent(
            id: 'event-1',
            title: 'Test Event',
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 11, 0),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: events,
              ),
            ),
          ),
        );

        // Assert
        final eventMarkerFinder = find.byType(EventMarker);
        expect(eventMarkerFinder, findsOneWidget);
        
        final RenderBox renderBox = tester.renderObject(eventMarkerFinder);
        final Size actualSize = renderBox.size;
        
        // Expected size: width should be marker size (6.0), height should be marker size + top padding (6.0 + 5.0)
        expect(actualSize.width, equals(6.0));
        expect(actualSize.height, equals(11.0)); // 6.0 + 5.0 top padding
      });

      testWidgets('should calculate correct overall widget size for multiple events', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final events = [
          createTestEvent(
            id: 'event-1',
            title: 'Event 1',
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 11, 0),
          ),
          createTestEvent(
            id: 'event-2',
            title: 'Event 2',
            startTime: DateTime(2024, 1, 15, 14, 0),
            endTime: DateTime(2024, 1, 15, 15, 0),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventMarker(
                day: testDay,
                events: events,
              ),
            ),
          ),
        );

        // Assert
        final eventMarkerFinder = find.byType(EventMarker);
        expect(eventMarkerFinder, findsOneWidget);
        
        final RenderBox renderBox = tester.renderObject(eventMarkerFinder);
        final Size actualSize = renderBox.size;
        
        // Expected size: width should be marker size + count badge width
        // Height should be max(marker height, count badge height) + top padding
        expect(actualSize.width, greaterThan(6.0)); // Should be wider than just the marker
        expect(actualSize.height, equals(11.0)); // Should still be 6.0 + 5.0 top padding (assuming text height <= marker height)
      });

      testWidgets('should maintain consistent positioning relative to parent widget', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final events = [
          createTestEvent(
            id: 'event-1',
            title: 'Test Event',
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 11, 0),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                width: 200,
                height: 200,
                child: EventMarker(
                  day: testDay,
                  events: events,
                ),
              ),
            ),
          ),
        );

        // Assert
        final eventMarkerFinder = find.byType(EventMarker);
        expect(eventMarkerFinder, findsOneWidget);
        
        final RenderBox renderBox = tester.renderObject(eventMarkerFinder);
        final Offset position = renderBox.localToGlobal(Offset.zero);
        
        // Should be positioned at the top-left of its constraints with proper padding
        expect(position.dx, equals(97.0)); // Centered horizontally: (200 - 6) / 2 = 97
        expect(position.dy, equals(5.0)); // Top padding of 5.0
      });

      testWidgets('should handle zero-sized container gracefully', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final events = [
          createTestEvent(
            id: 'event-1',
            title: 'Test Event',
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 11, 0),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 0,
                height: 0,
                child: EventMarker(
                  day: testDay,
                  events: events,
                ),
              ),
            ),
          ),
        );

        // Assert
        final eventMarkerFinder = find.byType(EventMarker);
        expect(eventMarkerFinder, findsOneWidget);
        
        final RenderBox renderBox = tester.renderObject(eventMarkerFinder);
        final Size actualSize = renderBox.size;
        
        // Should not cause overflow or crash
        expect(actualSize.width, greaterThanOrEqualTo(0));
        expect(actualSize.height, greaterThanOrEqualTo(0));
      });

      testWidgets('should respect parent constraints and not overflow', (WidgetTester tester) async {
        // Arrange
        final testDay = DateTime(2024, 1, 15);
        final events = [
          createTestEvent(
            id: 'event-1',
            title: 'Event 1',
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 11, 0),
          ),
          createTestEvent(
            id: 'event-2',
            title: 'Event 2',
            startTime: DateTime(2024, 1, 15, 14, 0),
            endTime: DateTime(2024, 1, 15, 15, 0),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 10, // Very narrow container
                height: 10, // Very short container
                child: EventMarker(
                  day: testDay,
                  events: events,
                ),
              ),
            ),
          ),
        );

        // Assert
        final eventMarkerFinder = find.byType(EventMarker);
        expect(eventMarkerFinder, findsOneWidget);
        
        final RenderBox renderBox = tester.renderObject(eventMarkerFinder);
        final Size actualSize = renderBox.size;
        
        // Should not exceed parent constraints
        expect(actualSize.width, lessThanOrEqualTo(10));
        expect(actualSize.height, lessThanOrEqualTo(10));
        
        // Should not cause overflow errors (test will fail if there are overflow errors)
        expect(tester.takeException(), isNull);
      });
    });
  });
}
