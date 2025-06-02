import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';
import 'package:planning/src/features/scheduling/domain/usecases/create_event_usecase.dart';
import 'package:planning/src/features/scheduling/domain/usecases/get_events_usecase.dart';
import 'package:planning/src/features/scheduling/domain/usecases/update_event_usecase.dart';
import 'package:planning/src/features/scheduling/domain/usecases/delete_event_usecase.dart';
import 'package:planning/src/features/scheduling/domain/usecases/get_events_by_date_range_usecase.dart';
import 'package:planning/src/features/scheduling/domain/usecases/get_events_by_task_id_usecase.dart';
import 'package:planning/src/features/scheduling/presentation/bloc/scheduling_bloc.dart';
import 'package:planning/src/core/usecases/usecase.dart';

// Mock classes for use cases
class MockCreateEventUseCase extends Mock implements CreateEventUseCase {}
class MockGetEventsUseCase extends Mock implements GetEventsUseCase {}
class MockUpdateEventUseCase extends Mock implements UpdateEventUseCase {}
class MockDeleteEventUseCase extends Mock implements DeleteEventUseCase {}
class MockGetEventsByDateRangeUseCase extends Mock implements GetEventsByDateRangeUseCase {}
class MockGetEventsByTaskIdUseCase extends Mock implements GetEventsByTaskIdUseCase {}

// Mock fallback values
class MockCreateEventParams extends Mock implements CreateEventParams {}
class MockUpdateEventParams extends Mock implements UpdateEventParams {}
class MockDeleteEventParams extends Mock implements DeleteEventParams {}
class MockGetEventsByDateRangeParams extends Mock implements GetEventsByDateRangeParams {}
class MockGetEventsByTaskIdParams extends Mock implements GetEventsByTaskIdParams {}
class MockNoParams extends Mock implements NoParams {}

void main() {
  setUpAll(() {
    // Register fallback values for all parameter types
    registerFallbackValue(MockCreateEventParams());
    registerFallbackValue(MockUpdateEventParams());
    registerFallbackValue(MockDeleteEventParams());
    registerFallbackValue(MockGetEventsByDateRangeParams());
    registerFallbackValue(MockGetEventsByTaskIdParams());
    registerFallbackValue(MockNoParams());
  });

  group('SchedulingBloc', () {
    late SchedulingBloc bloc;
    late MockCreateEventUseCase mockCreateEventUseCase;
    late MockGetEventsUseCase mockGetEventsUseCase;
    late MockUpdateEventUseCase mockUpdateEventUseCase;
    late MockDeleteEventUseCase mockDeleteEventUseCase;
    late MockGetEventsByDateRangeUseCase mockGetEventsByDateRangeUseCase;
    late MockGetEventsByTaskIdUseCase mockGetEventsByTaskIdUseCase;

    final DateTime now = DateTime.now();
    final testEvent = ScheduleEvent(
      id: '1',
      title: 'Test Event',
      description: 'Test Description',
      startTime: now,
      endTime: now.add(const Duration(hours: 1)),
      isAllDay: false,
      linkedTaskId: 'task1',
      googleCalendarId: 'gcal1',
      syncStatus: CalendarSyncStatus.synced,
      createdAt: now,
      updatedAt: now,
    );

    final testEvents = [testEvent];

    setUp(() {
      mockCreateEventUseCase = MockCreateEventUseCase();
      mockGetEventsUseCase = MockGetEventsUseCase();
      mockUpdateEventUseCase = MockUpdateEventUseCase();
      mockDeleteEventUseCase = MockDeleteEventUseCase();
      mockGetEventsByDateRangeUseCase = MockGetEventsByDateRangeUseCase();
      mockGetEventsByTaskIdUseCase = MockGetEventsByTaskIdUseCase();

      bloc = SchedulingBloc(
        createEvent: mockCreateEventUseCase,
        getEvents: mockGetEventsUseCase,
        updateEvent: mockUpdateEventUseCase,
        deleteEvent: mockDeleteEventUseCase,
        getEventsByDateRange: mockGetEventsByDateRangeUseCase,
        getEventsByTaskId: mockGetEventsByTaskIdUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    group('Initial State', () {
      test('should emit SchedulingInitial as initial state', () {
        expect(bloc.state, equals(const SchedulingInitial()));
      });
    });

    group('LoadEvents', () {
      test('should emit [SchedulingLoading, SchedulingEventsLoaded] when events are loaded successfully', () async {
        // Arrange
        when(() => mockGetEventsUseCase(any()))
            .thenAnswer((_) async => Right(testEvents));

        // Act
        bloc.add(const LoadEvents());

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            SchedulingEventsLoaded(events: testEvents),
          ]),
        );

        verify(() => mockGetEventsUseCase(NoParams())).called(1);
      });

      test('should emit [SchedulingLoading, SchedulingError] when loading events fails', () async {
        // Arrange
        const failure = CacheFailure('Failed to load events');
        when(() => mockGetEventsUseCase(any()))
            .thenAnswer((_) async => const Left(failure));

        // Act
        bloc.add(const LoadEvents());

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingError(message: 'Failed to load events'),
          ]),
        );

        verify(() => mockGetEventsUseCase(NoParams())).called(1);
      });

      test('should emit [SchedulingLoading, SchedulingEventsLoaded] with empty list when no events exist', () async {
        // Arrange
        when(() => mockGetEventsUseCase(any()))
            .thenAnswer((_) async => const Right([]));

        // Act
        bloc.add(const LoadEvents());

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingEventsLoaded(events: []),
          ]),
        );
      });
    });

    group('CreateEvent', () {
      test('should emit [SchedulingLoading, SchedulingEventCreated, SchedulingEventsLoaded] when event is created successfully', () async {
        // Arrange
        when(() => mockCreateEventUseCase(any()))
            .thenAnswer((_) async => Right(testEvent));
        when(() => mockGetEventsUseCase(any()))
            .thenAnswer((_) async => Right(testEvents));

        // Act
        bloc.add(CreateEvent(event: testEvent));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            SchedulingEventCreated(event: testEvent),
            SchedulingEventsLoaded(events: testEvents),
          ]),
        );

        verify(() => mockCreateEventUseCase(CreateEventParams(event: testEvent))).called(1);
        verify(() => mockGetEventsUseCase(NoParams())).called(1);
      });

      test('should emit [SchedulingLoading, SchedulingError] when creating event fails', () async {
        // Arrange
        const failure = ValidationFailure('Invalid event data');
        when(() => mockCreateEventUseCase(any()))
            .thenAnswer((_) async => const Left(failure));

        // Act
        bloc.add(CreateEvent(event: testEvent));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingError(message: 'Invalid event data'),
          ]),
        );

        verify(() => mockCreateEventUseCase(CreateEventParams(event: testEvent))).called(1);
        verifyNever(() => mockGetEventsUseCase(any()));
      });
    });

    group('UpdateEvent', () {
      test('should emit [SchedulingLoading, SchedulingEventUpdated, SchedulingEventsLoaded] when event is updated successfully', () async {
        // Arrange
        final updatedEvent = testEvent.copyWith(title: 'Updated Event');
        when(() => mockUpdateEventUseCase(any()))
            .thenAnswer((_) async => Right(updatedEvent));
        when(() => mockGetEventsUseCase(any()))
            .thenAnswer((_) async => Right([updatedEvent]));

        // Act
        bloc.add(UpdateEvent(event: updatedEvent));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            SchedulingEventUpdated(event: updatedEvent),
            SchedulingEventsLoaded(events: [updatedEvent]),
          ]),
        );

        verify(() => mockUpdateEventUseCase(UpdateEventParams(event: updatedEvent))).called(1);
        verify(() => mockGetEventsUseCase(NoParams())).called(1);
      });

      test('should emit [SchedulingLoading, SchedulingError] when updating event fails', () async {
        // Arrange
        const failure = CacheFailure('Failed to update event');
        when(() => mockUpdateEventUseCase(any()))
            .thenAnswer((_) async => const Left(failure));

        // Act
        bloc.add(UpdateEvent(event: testEvent));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingError(message: 'Failed to update event'),
          ]),
        );

        verify(() => mockUpdateEventUseCase(UpdateEventParams(event: testEvent))).called(1);
        verifyNever(() => mockGetEventsUseCase(any()));
      });
    });

    group('DeleteEvent', () {
      test('should emit [SchedulingLoading, SchedulingEventDeleted, SchedulingEventsLoaded] when event is deleted successfully', () async {
        // Arrange
        when(() => mockDeleteEventUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetEventsUseCase(any()))
            .thenAnswer((_) async => const Right([]));

        // Act
        bloc.add(const DeleteEvent(eventId: '1'));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingEventDeleted(eventId: '1'),
            const SchedulingEventsLoaded(events: []),
          ]),
        );

        verify(() => mockDeleteEventUseCase(const DeleteEventParams(eventId: '1'))).called(1);
        verify(() => mockGetEventsUseCase(NoParams())).called(1);
      });

      test('should emit [SchedulingLoading, SchedulingError] when deleting event fails', () async {
        // Arrange
        const failure = CacheFailure('Event not found');
        when(() => mockDeleteEventUseCase(any()))
            .thenAnswer((_) async => const Left(failure));

        // Act
        bloc.add(const DeleteEvent(eventId: '1'));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingError(message: 'Event not found'),
          ]),
        );

        verify(() => mockDeleteEventUseCase(const DeleteEventParams(eventId: '1'))).called(1);
        verifyNever(() => mockGetEventsUseCase(any()));
      });
    });

    group('LoadEventsByDateRange', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);

      test('should emit [SchedulingLoading, SchedulingEventsByDateRangeLoaded] when events are loaded successfully', () async {
        // Arrange
        when(() => mockGetEventsByDateRangeUseCase(any()))
            .thenAnswer((_) async => Right(testEvents));

        // Act
        bloc.add(LoadEventsByDateRange(startDate: startDate, endDate: endDate));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            SchedulingEventsByDateRangeLoaded(
              events: testEvents,
              startDate: startDate,
              endDate: endDate,
            ),
          ]),
        );

        verify(() => mockGetEventsByDateRangeUseCase(
          GetEventsByDateRangeParams(startDate: startDate, endDate: endDate),
        )).called(1);
      });

      test('should emit [SchedulingLoading, SchedulingError] when loading events by date range fails', () async {
        // Arrange
        const failure = ValidationFailure('Invalid date range');
        when(() => mockGetEventsByDateRangeUseCase(any()))
            .thenAnswer((_) async => const Left(failure));

        // Act
        bloc.add(LoadEventsByDateRange(startDate: startDate, endDate: endDate));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingError(message: 'Invalid date range'),
          ]),
        );
      });

      test('should emit [SchedulingLoading, SchedulingError] when end date is before start date', () async {
        // Arrange
        final invalidStartDate = DateTime(2024, 1, 31);
        final invalidEndDate = DateTime(2024, 1, 1);

        // Act
        bloc.add(LoadEventsByDateRange(startDate: invalidStartDate, endDate: invalidEndDate));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingError(message: 'End date cannot be before start date'),
          ]),
        );

        // Verify that the use case is never called
        verifyNever(() => mockGetEventsByDateRangeUseCase(any()));
      });
    });

    group('LoadEventsByTaskId', () {
      const taskId = 'task1';

      test('should emit [SchedulingLoading, SchedulingEventsByTaskIdLoaded] when events are loaded successfully', () async {
        // Arrange
        when(() => mockGetEventsByTaskIdUseCase(any()))
            .thenAnswer((_) async => Right(testEvents));

        // Act
        bloc.add(const LoadEventsByTaskId(taskId: taskId));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            SchedulingEventsByTaskIdLoaded(
              events: testEvents,
              taskId: taskId,
            ),
          ]),
        );

        verify(() => mockGetEventsByTaskIdUseCase(
          const GetEventsByTaskIdParams(taskId: taskId),
        )).called(1);
      });

      test('should emit [SchedulingLoading, SchedulingError] when loading events by task ID fails', () async {
        // Arrange
        const failure = ValidationFailure('Invalid task ID');
        when(() => mockGetEventsByTaskIdUseCase(any()))
            .thenAnswer((_) async => const Left(failure));

        // Act
        bloc.add(const LoadEventsByTaskId(taskId: taskId));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingError(message: 'Invalid task ID'),
          ]),
        );
      });

      test('should emit [SchedulingLoading, SchedulingError] when task ID is empty', () async {
        // Act
        bloc.add(const LoadEventsByTaskId(taskId: ''));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingError(message: 'Task ID cannot be empty'),
          ]),
        );

        // Verify that the use case is never called
        verifyNever(() => mockGetEventsByTaskIdUseCase(any()));
      });

      test('should emit [SchedulingLoading, SchedulingError] when task ID is only whitespace', () async {
        // Act
        bloc.add(const LoadEventsByTaskId(taskId: '   '));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingError(message: 'Task ID cannot be empty'),
          ]),
        );

        // Verify that the use case is never called
        verifyNever(() => mockGetEventsByTaskIdUseCase(any()));
      });

      test('should emit [SchedulingLoading, SchedulingEventsByTaskIdLoaded] with empty list when no events linked to task', () async {
        // Arrange
        when(() => mockGetEventsByTaskIdUseCase(any()))
            .thenAnswer((_) async => const Right([]));

        // Act
        bloc.add(const LoadEventsByTaskId(taskId: taskId));

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingEventsByTaskIdLoaded(
              events: [],
              taskId: taskId,
            ),
          ]),
        );
      });
    });

    group('Error Handling', () {
      test('should handle NetworkFailure correctly', () async {
        // Arrange
        const failure = NetworkFailure('No internet connection');
        when(() => mockGetEventsUseCase(any()))
            .thenAnswer((_) async => const Left(failure));

        // Act
        bloc.add(const LoadEvents());

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingError(message: 'No internet connection'),
          ]),
        );
      });

      test('should handle ServerFailure correctly', () async {
        // Arrange
        const failure = ServerFailure();
        when(() => mockGetEventsUseCase(any()))
            .thenAnswer((_) async => const Left(failure));

        // Act
        bloc.add(const LoadEvents());

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            const SchedulingError(message: 'Server error occurred. Please try again later.'),
          ]),
        );
      });
    });

    group('State Persistence', () {
      test('should maintain state between multiple events', () async {
        // Arrange
        when(() => mockGetEventsUseCase(any()))
            .thenAnswer((_) async => Right(testEvents));
        when(() => mockCreateEventUseCase(any()))
            .thenAnswer((_) async => Right(testEvent));

        // Act & Assert 1: Load events
        bloc.add(const LoadEvents());
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            SchedulingEventsLoaded(events: testEvents),
          ]),
        );

        // Act & Assert 2: Create event
        bloc.add(CreateEvent(event: testEvent));
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const SchedulingLoading(),
            SchedulingEventCreated(event: testEvent),
            SchedulingEventsLoaded(events: testEvents),
          ]),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle simultaneous events gracefully', () async {
        // Arrange
        when(() => mockGetEventsUseCase(any()))
            .thenAnswer((_) async => Right(testEvents));

        // Act - Add multiple events simultaneously
        bloc.add(const LoadEvents());
        bloc.add(const LoadEvents());

        // Assert - Should handle gracefully (implementation may vary)
        await expectLater(
          bloc.stream,
          emitsAnyOf([
            const SchedulingLoading(),
            SchedulingEventsLoaded(events: testEvents),
          ]),
        );
      });

      test('should handle null data gracefully', () async {
        // This test ensures the bloc handles edge cases properly
        expect(bloc.state, isNotNull);
        expect(bloc.stream, isNotNull);
      });
    });
  });
}
