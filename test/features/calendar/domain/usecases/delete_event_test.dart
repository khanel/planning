import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:planning/src/features/calendar/domain/usecases/delete_event.dart';

class MockCalendarRepository extends Mock implements CalendarRepository {}

void main() {
  late DeleteEvent usecase;
  late MockCalendarRepository mockRepository;

  setUp(() {
    mockRepository = MockCalendarRepository();
    usecase = DeleteEvent(repository: mockRepository);
  });

  const tEventId = 'test-event-1';
  const tCalendarId = 'primary';
  const tParams = DeleteEventParams(
    eventId: tEventId,
    calendarId: tCalendarId,
  );

  group('DeleteEvent', () {
    test('should delete event successfully when repository call succeeds', () async {
      // arrange
      when(() => mockRepository.deleteEvent(
        eventId: any(named: 'eventId'),
        calendarId: any(named: 'calendarId'),
      )).thenAnswer((_) async => const Right(true));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right(true));
      verify(() => mockRepository.deleteEvent(
        eventId: tEventId,
        calendarId: tCalendarId,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      const tFailure = ServerFailure();
      when(() => mockRepository.deleteEvent(
        eventId: any(named: 'eventId'),
        calendarId: any(named: 'calendarId'),
      )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.deleteEvent(
        eventId: tEventId,
        calendarId: tCalendarId,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when event ID is empty', () async {
      // arrange
      const invalidParams = DeleteEventParams(
        eventId: '', // Invalid: empty eventId
        calendarId: tCalendarId,
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (success) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.deleteEvent(
        eventId: any(named: 'eventId'),
        calendarId: any(named: 'calendarId'),
      ));
    });

    test('should return ValidationFailure when calendar ID is empty', () async {
      // arrange
      const invalidParams = DeleteEventParams(
        eventId: tEventId,
        calendarId: '', // Invalid: empty calendarId
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (success) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.deleteEvent(
        eventId: any(named: 'eventId'),
        calendarId: any(named: 'calendarId'),
      ));
    });

    test('should trim eventId and calendarId before validation', () async {
      // arrange
      const paramsWithSpaces = DeleteEventParams(
        eventId: '  test-event-1  ',
        calendarId: '  primary  ',
      );
      when(() => mockRepository.deleteEvent(
        eventId: any(named: 'eventId'),
        calendarId: any(named: 'calendarId'),
      )).thenAnswer((_) async => const Right(true));

      // act
      final result = await usecase(paramsWithSpaces);

      // assert
      expect(result, const Right(true));
      verify(() => mockRepository.deleteEvent(
        eventId: 'test-event-1', // Should be trimmed
        calendarId: 'primary',   // Should be trimmed
      )).called(1);
    });

    test('should handle NetworkFailure gracefully', () async {
      // arrange
      const tFailure = NetworkFailure();
      when(() => mockRepository.deleteEvent(
        eventId: any(named: 'eventId'),
        calendarId: any(named: 'calendarId'),
      )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.deleteEvent(
        eventId: tEventId,
        calendarId: tCalendarId,
      )).called(1);
    });

    test('should handle CacheFailure gracefully', () async {
      // arrange
      const tFailure = CacheFailure('Event not found');
      when(() => mockRepository.deleteEvent(
        eventId: any(named: 'eventId'),
        calendarId: any(named: 'calendarId'),
      )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.deleteEvent(
        eventId: tEventId,
        calendarId: tCalendarId,
      )).called(1);
    });
  });

  group('DeleteEventParams', () {
    test('should create params with eventId and calendarId', () {
      // act
      const params = DeleteEventParams(
        eventId: tEventId,
        calendarId: tCalendarId,
      );

      // assert
      expect(params.eventId, tEventId);
      expect(params.calendarId, tCalendarId);
      expect(params.props, [tEventId, tCalendarId]);
    });

    test('should support equality comparison', () {
      // arrange
      const params1 = DeleteEventParams(
        eventId: tEventId,
        calendarId: tCalendarId,
      );
      const params2 = DeleteEventParams(
        eventId: tEventId,
        calendarId: tCalendarId,
      );

      // assert
      expect(params1, equals(params2));
      expect(params1.hashCode, equals(params2.hashCode));
    });
  });
}
