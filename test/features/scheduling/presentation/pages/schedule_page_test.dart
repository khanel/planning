import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';

import 'package:planning/src/features/scheduling/presentation/bloc/scheduling_bloc.dart';
import 'package:planning/src/features/scheduling/presentation/pages/schedule_page.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';

class MockSchedulingBloc extends Mock implements SchedulingBloc {
  final StreamController<SchedulingState> _controller = StreamController<SchedulingState>.broadcast();
  
  @override
  Stream<SchedulingState> get stream => _controller.stream;
  
  @override
  Future<void> close() {
    _controller.close();
    return Future.value();
  }
}

// Fake classes for mocktail
class FakeSchedulingEvent extends Fake implements SchedulingEvent {}

void main() {
  late MockSchedulingBloc mockSchedulingBloc;

  setUpAll(() {
    registerFallbackValue(FakeSchedulingEvent());
  });

  setUp(() {
    mockSchedulingBloc = MockSchedulingBloc();
    // Set up default state
    when(() => mockSchedulingBloc.state).thenReturn(const SchedulingInitial());
  });

  tearDown(() {
    mockSchedulingBloc.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<SchedulingBloc>(
        create: (_) => mockSchedulingBloc,
        child: const SchedulePage(),
      ),
    );
  }

  group('SchedulePage', () {
    testWidgets('should display app bar with correct title', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display loading indicator when state is loading', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(SchedulingLoading());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message when state is error', (tester) async {
      // arrange
      const errorMessage = 'Failed to load events';
      when(() => mockSchedulingBloc.state).thenReturn(
        const SchedulingError(message: errorMessage),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Error: $errorMessage'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should display empty state when no events exist', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(
        const SchedulingEventsLoaded(events: []),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('No events scheduled'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('should display list of events when events are loaded', (tester) async {
      // arrange
      final events = [
        ScheduleEvent(
          id: '1',
          title: 'Meeting',
          description: 'Team meeting',
          startTime: DateTime(2025, 5, 31, 10, 0),
          endTime: DateTime(2025, 5, 31, 11, 0),
          isAllDay: false,
          createdAt: DateTime(2025, 5, 31, 9, 0),
          updatedAt: DateTime(2025, 5, 31, 9, 0),
        ),
        ScheduleEvent(
          id: '2',
          title: 'Lunch',
          description: 'Lunch break',
          startTime: DateTime(2025, 5, 31, 12, 0),
          endTime: DateTime(2025, 5, 31, 13, 0),
          isAllDay: false,
          createdAt: DateTime(2025, 5, 31, 9, 0),
          updatedAt: DateTime(2025, 5, 31, 9, 0),
        ),
      ];
      when(() => mockSchedulingBloc.state).thenReturn(
        SchedulingEventsLoaded(events: events),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Meeting'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
    });

    testWidgets('should display floating action button to add new event', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(SchedulingInitial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should trigger GetEventsEvent when page is initialized', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(SchedulingInitial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      verify(() => mockSchedulingBloc.add(const LoadEvents())).called(1);
    });

    testWidgets('should navigate to add event page when FAB is tapped', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(const SchedulingEventsLoaded(events: []));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Give additional pump for widget to render

      // assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      
      // act - tap the FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
    });
  });
}
