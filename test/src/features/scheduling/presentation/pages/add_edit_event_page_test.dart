import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';

import 'package:planning/src/features/scheduling/presentation/bloc/scheduling_bloc.dart';
import 'package:planning/src/features/scheduling/presentation/pages/add_edit_event_page.dart';
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

  Widget createWidgetUnderTest({ScheduleEvent? event}) {
    return MaterialApp(
      home: BlocProvider<SchedulingBloc>(
        create: (_) => mockSchedulingBloc,
        child: AddEditEventPage(event: event),
      ),
    );
  }

  group('AddEditEventPage', () {
    testWidgets('should display "Add Event" title when creating new event', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Add Event'), findsOneWidget);
    });

    testWidgets('should display "Edit Event" title when editing existing event', (tester) async {
      // arrange
      final existingEvent = ScheduleEvent(
        id: '1',
        title: 'Meeting',
        description: 'Team meeting',
        startTime: DateTime(2025, 5, 31, 10, 0),
        endTime: DateTime(2025, 5, 31, 11, 0),
        isAllDay: false,
        createdAt: DateTime(2025, 5, 31, 9, 0),
        updatedAt: DateTime(2025, 5, 31, 9, 0),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest(event: existingEvent));

      // assert
      expect(find.text('Edit Event'), findsOneWidget);
    });

    testWidgets('should display form fields for event details', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(SchedulingInitial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(TextFormField), findsNWidgets(2)); // title and description
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('should display date and time picker fields', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(SchedulingInitial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Date'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);
    });

    testWidgets('should display all-day toggle switch', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(SchedulingInitial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('All Day'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should hide time fields when all-day is enabled', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(SchedulingInitial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Toggle all-day switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Start Time'), findsNothing);
      expect(find.text('End Time'), findsNothing);
    });

    testWidgets('should display save button', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(SchedulingInitial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should validate required fields', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(const SchedulingInitial());
      
      // Set larger screen size for test
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('should pre-populate fields when editing existing event', (tester) async {
      // arrange
      final existingEvent = ScheduleEvent(
        id: '1',
        title: 'Meeting',
        description: 'Team meeting',
        startTime: DateTime(2025, 5, 31, 10, 0),
        endTime: DateTime(2025, 5, 31, 11, 0),
        isAllDay: false,
        createdAt: DateTime(2025, 5, 31, 9, 0),
        updatedAt: DateTime(2025, 5, 31, 9, 0),
      );
      when(() => mockSchedulingBloc.state).thenReturn(const SchedulingInitial());

      // act
      await tester.pumpWidget(createWidgetUnderTest(event: existingEvent));

      // assert
      expect(find.text('Meeting'), findsOneWidget);
      expect(find.text('Team meeting'), findsOneWidget);
    });

    testWidgets('should dispatch CreateEvent when saving new event', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(const SchedulingInitial());
      
      // Set larger screen size for test
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextFormField).first, 'New Meeting');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // assert
      verify(() => mockSchedulingBloc.add(any(that: isA<CreateEvent>()))).called(1);
    });

    testWidgets('should dispatch UpdateEvent when saving existing event', (tester) async {
      // arrange
      final existingEvent = ScheduleEvent(
        id: '1',
        title: 'Meeting',
        description: 'Team meeting',
        startTime: DateTime(2025, 5, 31, 10, 0),
        endTime: DateTime(2025, 5, 31, 11, 0),
        isAllDay: false,
        createdAt: DateTime(2025, 5, 31, 9, 0),
        updatedAt: DateTime(2025, 5, 31, 9, 0),
      );
      when(() => mockSchedulingBloc.state).thenReturn(const SchedulingInitial());
      
      // Set larger screen size for test
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // act
      await tester.pumpWidget(createWidgetUnderTest(event: existingEvent));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // assert
      verify(() => mockSchedulingBloc.add(any(that: isA<UpdateEvent>()))).called(1);
    });

    testWidgets('should show loading indicator when submitting', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(const SchedulingLoading());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when submission fails', (tester) async {
      // arrange
      when(() => mockSchedulingBloc.state).thenReturn(
        const SchedulingError(message: 'Failed to save event'),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Failed to save event'), findsOneWidget);
    });
  });
}
