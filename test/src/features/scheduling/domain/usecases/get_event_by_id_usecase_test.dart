import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/repositories/scheduling_repository.dart';
import 'package:planning/src/features/scheduling/domain/usecases/get_event_by_id_usecase.dart';

class MockSchedulingRepository extends Mock implements SchedulingRepository {}

void main() {
  late GetEventByIdUseCase usecase;
  late MockSchedulingRepository mockRepository;

  setUp(() {
    mockRepository = MockSchedulingRepository();
    usecase = GetEventByIdUseCase(mockRepository);
  });

  const tEventId = 'test-event-1';
  const tParams = GetEventByIdParams(eventId: tEventId);

  final tEvent = ScheduleEvent(
    id: tEventId,
    title: 'Test Event',
    description: 'Test Description',
    startTime: DateTime(2025, 6, 1, 10, 0),
    endTime: DateTime(2025, 6, 1, 11, 0),
    isAllDay: false,
    createdAt: DateTime(2025, 5, 30),
    updatedAt: DateTime(2025, 5, 30),
    syncStatus: CalendarSyncStatus.synced,
    googleCalendarId: 'google-123',
    linkedTaskId: 'task-456',
  );

  group('GetEventByIdUseCase', () {
    test('should get event by ID via the repository when valid event ID is provided', () async {
      // arrange
      when(() => mockRepository.getEventById(any()))
          .thenAnswer((_) async => Right(tEvent));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tEvent));
      verify(() => mockRepository.getEventById(tEventId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when repository returns failure', () async {
      // arrange
      const tFailure = CacheFailure('Event not found');
      when(() => mockRepository.getEventById(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.getEventById(tEventId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure for empty event ID', () async {
      // arrange
      const invalidParams = GetEventByIdParams(eventId: '');

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (event) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.getEventById(any()));
    });

    test('should return ValidationFailure for whitespace-only event ID', () async {
      // arrange
      const invalidParams = GetEventByIdParams(eventId: '   ');

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (event) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.getEventById(any()));
    });

    test('should handle network failure gracefully', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockRepository.getEventById(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.getEventById(tEventId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should trim eventId before validation', () async {
      // arrange
      const paramsWithSpaces = GetEventByIdParams(eventId: '  test-event-1  ');
      when(() => mockRepository.getEventById(any()))
          .thenAnswer((_) async => Right(tEvent));

      // act
      final result = await usecase(paramsWithSpaces);

      // assert
      expect(result, Right(tEvent));
      verify(() => mockRepository.getEventById('test-event-1')); // Should be trimmed
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle event with all-day flag correctly', () async {
      // arrange
      final allDayEvent = tEvent.copyWith(isAllDay: true);
      when(() => mockRepository.getEventById(any()))
          .thenAnswer((_) async => Right(allDayEvent));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(allDayEvent));
      result.fold(
        (failure) => fail('Expected success'),
        (event) => expect(event.isAllDay, true),
      );
      verify(() => mockRepository.getEventById(tEventId));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetEventByIdParams', () {
    test('should create params with event ID', () {
      // act
      const params = GetEventByIdParams(eventId: 'test-123');

      // assert
      expect(params.eventId, 'test-123');
      expect(params.props, ['test-123']);
    });

    test('should support equality comparison', () {
      // act
      const params1 = GetEventByIdParams(eventId: 'test-123');
      const params2 = GetEventByIdParams(eventId: 'test-123');

      // assert
      expect(params1, params2);
    });
  });
}
