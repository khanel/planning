import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:planning/src/features/calendar/domain/usecases/update_event.dart';

class MockCalendarRepository extends Mock implements CalendarRepository {}

class FakeCalendarEvent extends Fake implements CalendarEvent {}

void main() {
  late UpdateEvent usecase;
  late MockCalendarRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeCalendarEvent());
  });

  setUp(() {
    mockRepository = MockCalendarRepository();
    usecase = UpdateEvent(repository: mockRepository);
  });

  final tCalendarEvent = CalendarEvent(
    id: 'test-event-1',
    title: 'Updated Test Event',
    description: 'Updated Test Description',
    startTime: DateTime(2024, 1, 15, 10, 0),
    endTime: DateTime(2024, 1, 15, 11, 0),
    isAllDay: false,
    calendarId: 'primary',
    googleEventId: 'google-123',
  );

  final tParams = UpdateEventParams(
    event: tCalendarEvent,
    calendarId: 'primary',
  );

  group('UpdateEvent', () {
    test('should update event successfully when repository call succeeds', () async {
      // arrange
      when(() => mockRepository.updateEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      )).thenAnswer((_) async => Right(tCalendarEvent));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tCalendarEvent));
      verify(() => mockRepository.updateEvent(
        event: tCalendarEvent,
        calendarId: 'primary',
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      const tFailure = ServerFailure();
      when(() => mockRepository.updateEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.updateEvent(
        event: tCalendarEvent,
        calendarId: 'primary',
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when event ID is empty', () async {
      // arrange
      final invalidEvent = CalendarEvent(
        id: '', // Invalid: empty ID
        title: 'Updated Test Event',
        description: 'Updated Test Description',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 11, 0),
        isAllDay: false,
        calendarId: 'primary',
      );
      final invalidParams = UpdateEventParams(
        event: invalidEvent,
        calendarId: 'primary',
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (event) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.updateEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      ));
    });

    test('should return ValidationFailure when event title is empty', () async {
      // arrange
      final invalidEvent = CalendarEvent(
        id: 'test-event-1',
        title: '', // Invalid: empty title
        description: 'Updated Test Description',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 11, 0),
        isAllDay: false,
        calendarId: 'primary',
      );
      final invalidParams = UpdateEventParams(
        event: invalidEvent,
        calendarId: 'primary',
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (event) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.updateEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      ));
    });

    test('should return ValidationFailure when calendar ID is empty', () async {
      // arrange
      final invalidParams = UpdateEventParams(
        event: tCalendarEvent,
        calendarId: '', // Invalid: empty calendarId
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (event) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.updateEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      ));
    });

    test('should return ValidationFailure when end time is before start time for non-all-day events', () async {
      // arrange
      final invalidEvent = CalendarEvent(
        id: 'test-event-1',
        title: 'Updated Test Event',
        description: 'Updated Test Description',
        startTime: DateTime(2024, 1, 15, 11, 0), // After end time
        endTime: DateTime(2024, 1, 15, 10, 0),   // Before start time
        isAllDay: false,
        calendarId: 'primary',
      );
      final invalidParams = UpdateEventParams(
        event: invalidEvent,
        calendarId: 'primary',
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (event) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.updateEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      ));
    });

    test('should handle all-day events correctly', () async {
      // arrange
      final allDayEvent = CalendarEvent(
        id: 'test-event-1',
        title: 'Updated All Day Event',
        description: 'Updated Test Description',
        startTime: DateTime(2024, 1, 15),
        endTime: DateTime(2024, 1, 15, 23, 59, 59),
        isAllDay: true,
        calendarId: 'primary',
      );
      final allDayParams = UpdateEventParams(
        event: allDayEvent,
        calendarId: 'primary',
      );
      when(() => mockRepository.updateEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      )).thenAnswer((_) async => Right(allDayEvent));

      // act
      final result = await usecase(allDayParams);

      // assert
      expect(result, Right(allDayEvent));
      verify(() => mockRepository.updateEvent(
        event: allDayEvent,
        calendarId: 'primary',
      )).called(1);
    });

    test('should handle NetworkFailure gracefully', () async {
      // arrange
      const tFailure = NetworkFailure();
      when(() => mockRepository.updateEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.updateEvent(
        event: tCalendarEvent,
        calendarId: 'primary',
      )).called(1);
    });
  });

  group('UpdateEventParams', () {
    test('should create params with event and calendarId', () {
      // act
      final params = UpdateEventParams(
        event: tCalendarEvent,
        calendarId: 'primary',
      );

      // assert
      expect(params.event, tCalendarEvent);
      expect(params.calendarId, 'primary');
      expect(params.props, [tCalendarEvent, 'primary']);
    });

    test('should support equality comparison', () {
      // arrange
      final params1 = UpdateEventParams(
        event: tCalendarEvent,
        calendarId: 'primary',
      );
      final params2 = UpdateEventParams(
        event: tCalendarEvent,
        calendarId: 'primary',
      );

      // assert
      expect(params1, equals(params2));
      expect(params1.hashCode, equals(params2.hashCode));
    });
  });
}
