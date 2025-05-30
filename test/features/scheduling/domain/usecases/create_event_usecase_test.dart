import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';
import 'package:planning/src/features/scheduling/domain/repositories/scheduling_repository.dart';
import 'package:planning/src/features/scheduling/domain/usecases/create_event_usecase.dart';

class MockSchedulingRepository extends Mock implements SchedulingRepository {}

class FakeScheduleEvent extends Fake implements ScheduleEvent {}

void main() {
  late CreateEventUseCase usecase;
  late MockSchedulingRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeScheduleEvent());
  });

  setUp(() {
    mockRepository = MockSchedulingRepository();
    usecase = CreateEventUseCase(mockRepository);
  });

  final testEvent = ScheduleEvent(
    id: 'test-id',
    title: 'Test Event',
    description: 'Test Description',
    startTime: DateTime(2025, 5, 30, 10, 0),
    endTime: DateTime(2025, 5, 30, 11, 0),
    isAllDay: false,
    createdAt: DateTime(2025, 5, 30, 9, 0),
    updatedAt: DateTime(2025, 5, 30, 9, 0),
    googleCalendarId: null,
    syncStatus: CalendarSyncStatus.notSynced,
    lastSyncAt: null,
    linkedTaskId: 'task-123',
  );

  group('CreateEventUseCase', () {
    test('should create event successfully when repository call succeeds', () async {
      // arrange
      when(() => mockRepository.createEvent(any()))
          .thenAnswer((_) async => Right(testEvent));

      // act
      final result = await usecase(CreateEventParams(event: testEvent));

      // assert
      expect(result, Right(testEvent));
      verify(() => mockRepository.createEvent(testEvent));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository call fails', () async {
      // arrange
      final failure = CacheFailure('Test failure');
      when(() => mockRepository.createEvent(any()))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(CreateEventParams(event: testEvent));

      // assert
      expect(result, Left(failure));
      verify(() => mockRepository.createEvent(testEvent));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should validate event before creating', () async {
      // arrange
      final invalidEvent = ScheduleEvent(
        id: 'test-id',
        title: '', // Invalid: empty title
        description: 'Test Description',
        startTime: DateTime(2025, 5, 30, 10, 0),
        endTime: DateTime(2025, 5, 30, 9, 0), // Invalid: end before start
        isAllDay: false,
        createdAt: DateTime(2025, 5, 30, 9, 0),
        updatedAt: DateTime(2025, 5, 30, 9, 0),
        linkedTaskId: 'task-123',
      );

      // act
      final result = await usecase(CreateEventParams(event: invalidEvent));

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (event) => fail('Expected validation failure'),
      );
      verifyNever(() => mockRepository.createEvent(any()));
    });

    test('should handle event with Google Calendar ID', () async {
      // arrange
      final eventWithGoogleId = testEvent.copyWith(
        googleCalendarId: 'google-123',
        syncStatus: CalendarSyncStatus.synced,
      );
      when(() => mockRepository.createEvent(any()))
          .thenAnswer((_) async => Right(eventWithGoogleId));

      // act
      final result = await usecase(CreateEventParams(event: eventWithGoogleId));

      // assert
      expect(result, Right(eventWithGoogleId));
      verify(() => mockRepository.createEvent(eventWithGoogleId));
    });

    test('should handle all-day events', () async {
      // arrange
      final allDayEvent = testEvent.copyWith(
        isAllDay: true,
        startTime: DateTime(2025, 5, 30),
        endTime: DateTime(2025, 5, 30, 23, 59, 59),
      );
      when(() => mockRepository.createEvent(any()))
          .thenAnswer((_) async => Right(allDayEvent));

      // act
      final result = await usecase(CreateEventParams(event: allDayEvent));

      // assert
      expect(result, Right(allDayEvent));
      verify(() => mockRepository.createEvent(allDayEvent));
    });
  });

  group('CreateEventParams', () {
    test('should create params with event', () {
      // act
      final params = CreateEventParams(event: testEvent);

      // assert
      expect(params.event, testEvent);
      expect(params.props, [testEvent]);
    });

    test('should support equality comparison', () {
      // act
      final params1 = CreateEventParams(event: testEvent);
      final params2 = CreateEventParams(event: testEvent);

      // assert
      expect(params1, params2);
    });
  });
}
