import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:planning/src/features/calendar/domain/usecases/create_event.dart';

class MockCalendarRepository extends Mock implements CalendarRepository {}

class FakeCalendarEvent extends Fake implements CalendarEvent {}

void main() {
  late CreateEvent usecase;
  late MockCalendarRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeCalendarEvent());
  });

  setUp(() {
    mockRepository = MockCalendarRepository();
    usecase = CreateEvent(repository: mockRepository);
  });

  final tCalendarEvent = CalendarEvent(
    id: 'test-event-1',
    title: 'Test Event',
    description: 'Test Description',
    startTime: DateTime(2024, 1, 15, 10, 0),
    endTime: DateTime(2024, 1, 15, 11, 0),
    isAllDay: false,
    calendarId: 'primary',
  );

  final tParams = CreateEventParams(
    event: tCalendarEvent,
    calendarId: 'primary',
  );

  group('CreateEvent', () {
    test('should create event successfully when repository call succeeds', () async {
      // arrange
      when(() => mockRepository.createEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      )).thenAnswer((_) async => Right(tCalendarEvent));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tCalendarEvent));
      verify(() => mockRepository.createEvent(
        event: tCalendarEvent,
        calendarId: 'primary',
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      const tFailure = ServerFailure('Failed to create event');
      when(() => mockRepository.createEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.createEvent(
        event: tCalendarEvent,
        calendarId: 'primary',
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when event title is empty', () async {
      // arrange
      final invalidEvent = CalendarEvent(
        id: 'test-event-1',
        title: '', // Invalid: empty title
        description: 'Test Description',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 11, 0),
        isAllDay: false,
        calendarId: 'primary',
      );
      final invalidParams = CreateEventParams(
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
      verifyNever(() => mockRepository.createEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      ));
    });

    test('should return ValidationFailure when calendar ID is empty', () async {
      // arrange
      final invalidParams = CreateEventParams(
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
      verifyNever(() => mockRepository.createEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      ));
    });

    test('should return ValidationFailure when end time is before start time', () async {
      // arrange
      final invalidEvent = CalendarEvent(
        id: 'test-event-1',
        title: 'Test Event',
        description: 'Test Description',
        startTime: DateTime(2024, 1, 15, 11, 0), // After end time
        endTime: DateTime(2024, 1, 15, 10, 0),   // Before start time
        isAllDay: false,
        calendarId: 'primary',
      );
      final invalidParams = CreateEventParams(
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
      verifyNever(() => mockRepository.createEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      ));
    });

    test('should handle all-day events correctly', () async {
      // arrange
      final allDayEvent = CalendarEvent(
        id: 'test-event-1',
        title: 'All Day Event',
        description: 'Test Description',
        startTime: DateTime(2024, 1, 15),
        endTime: DateTime(2024, 1, 15, 23, 59, 59),
        isAllDay: true,
        calendarId: 'primary',
      );
      final allDayParams = CreateEventParams(
        event: allDayEvent,
        calendarId: 'primary',
      );
      when(() => mockRepository.createEvent(
        event: any(named: 'event'),
        calendarId: any(named: 'calendarId'),
      )).thenAnswer((_) async => Right(allDayEvent));

      // act
      final result = await usecase(allDayParams);

      // assert
      expect(result, Right(allDayEvent));
      verify(() => mockRepository.createEvent(
        event: allDayEvent,
        calendarId: 'primary',
      )).called(1);
    });
  });

  group('CreateEventParams', () {
    test('should create params with event and calendarId', () {
      // act
      final params = CreateEventParams(
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
      final params1 = CreateEventParams(
        event: tCalendarEvent,
        calendarId: 'primary',
      );
      final params2 = CreateEventParams(
        event: tCalendarEvent,
        calendarId: 'primary',
      );

      // assert
      expect(params1, equals(params2));
      expect(params1.hashCode, equals(params2.hashCode));
    });
  });
}