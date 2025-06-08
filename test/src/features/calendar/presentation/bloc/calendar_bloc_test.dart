import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:planning/src/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart' as domain;
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:planning/src/core/errors/failures.dart';

// Mock classes
class MockCalendarRepository extends Mock implements CalendarRepository {}

// Fake classes for mocktail
class FakeCalendarEvent extends Fake implements domain.CalendarEvent {}

void main() {
  group('CalendarBloc', () {
    late CalendarBloc bloc;
    late MockCalendarRepository mockRepository;

    setUpAll(() {
      registerFallbackValue(FakeCalendarEvent());
    });

    setUp(() {
      mockRepository = MockCalendarRepository();
      bloc = CalendarBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is CalendarInitial', () {
      expect(CalendarBloc(repository: mockRepository).state, isA<CalendarInitial>());
    });

    group('LoadCalendarEvents with real repository integration', () {
      final tDomainEvents = [
        domain.CalendarEvent(
          id: '1',
          title: 'Domain Event 1',
          description: 'Test domain event 1',
          startTime: DateTime.parse('2024-01-01T09:00:00Z'),
          endTime: DateTime.parse('2024-01-01T10:00:00Z'),
          isAllDay: false,
        ),
        domain.CalendarEvent(
          id: '2',
          title: 'Domain Event 2',
          description: 'Test domain event 2',
          startTime: DateTime.parse('2024-01-02T14:00:00Z'),
          endTime: DateTime.parse('2024-01-02T15:00:00Z'),
          isAllDay: false,
        ),
      ];

      blocTest<CalendarBloc, CalendarState>(
        'emits [CalendarLoading, CalendarLoaded] when repository returns events successfully',
        build: () {
          when(() => mockRepository.getEvents(
            timeMin: any(named: 'timeMin'),
            timeMax: any(named: 'timeMax'),
            calendarId: any(named: 'calendarId'),
            maxResults: any(named: 'maxResults'),
          )).thenAnswer((_) async => Right(tDomainEvents));
          return CalendarBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LoadCalendarEvents()),
        expect: () => [
          isA<CalendarLoading>(),
          isA<CalendarLoaded>().having(
            (state) => state.events.length,
            'events length',
            2,
          ).having(
            (state) => state.events.first.id,
            'first event id',
            '1',
          ).having(
            (state) => state.events.first.summary,
            'first event summary',
            'Domain Event 1',
          ),
        ],
        verify: (bloc) {
          verify(() => mockRepository.getEvents(
            timeMin: any(named: 'timeMin'),
            timeMax: any(named: 'timeMax'),
            calendarId: 'primary',
            maxResults: 100,
          )).called(1);
        },
      );

      blocTest<CalendarBloc, CalendarState>(
        'emits [CalendarLoading, CalendarError] when repository returns NetworkFailure',
        build: () {
          when(() => mockRepository.getEvents(
            timeMin: any(named: 'timeMin'),
            timeMax: any(named: 'timeMax'),
            calendarId: any(named: 'calendarId'),
            maxResults: any(named: 'maxResults'),
          )).thenAnswer((_) async => const Left(NetworkFailure()));
          return CalendarBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LoadCalendarEvents()),
        expect: () => [
          isA<CalendarLoading>(),
          isA<CalendarError>().having(
            (state) => state.message,
            'error message',
            'Network error. Please check your connection.',
          ),
        ],
        verify: (bloc) {
          verify(() => mockRepository.getEvents(
            timeMin: any(named: 'timeMin'),
            timeMax: any(named: 'timeMax'),
            calendarId: 'primary',
            maxResults: 100,
          )).called(1);
        },
      );

      blocTest<CalendarBloc, CalendarState>(
        'emits [CalendarLoading, CalendarError] when repository returns AuthFailure',
        build: () {
          when(() => mockRepository.getEvents(
            timeMin: any(named: 'timeMin'),
            timeMax: any(named: 'timeMax'),
            calendarId: any(named: 'calendarId'),
            maxResults: any(named: 'maxResults'),
          )).thenAnswer((_) async => const Left(AuthFailure()));
          return CalendarBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LoadCalendarEvents()),
        expect: () => [
          isA<CalendarLoading>(),
          isA<CalendarError>().having(
            (state) => state.message,
            'error message',
            'Authentication failed. Please sign in again.',
          ),
        ],
      );

      blocTest<CalendarBloc, CalendarState>(
        'emits [CalendarLoading, CalendarError] when repository returns ServerFailure',
        build: () {
          when(() => mockRepository.getEvents(
            timeMin: any(named: 'timeMin'),
            timeMax: any(named: 'timeMax'),
            calendarId: any(named: 'calendarId'),
            maxResults: any(named: 'maxResults'),
          )).thenAnswer((_) async => const Left(ServerFailure()));
          return CalendarBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LoadCalendarEvents()),
        expect: () => [
          isA<CalendarLoading>(),
          isA<CalendarError>().having(
            (state) => state.message,
            'error message',
            'Server error. Please try again later.',
          ),
        ],
      );

      blocTest<CalendarBloc, CalendarState>(
        'emits [CalendarLoading, CalendarError] when repository throws exception',
        build: () {
          when(() => mockRepository.getEvents(
            timeMin: any(named: 'timeMin'),
            timeMax: any(named: 'timeMax'),
            calendarId: any(named: 'calendarId'),
            maxResults: any(named: 'maxResults'),
          )).thenThrow(Exception('Unexpected error'));
          return CalendarBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LoadCalendarEvents()),
        expect: () => [
          isA<CalendarLoading>(),
          isA<CalendarError>().having(
            (state) => state.message,
            'error message',
            contains('Exception: Unexpected error'),
          ),
        ],
      );

      blocTest<CalendarBloc, CalendarState>(
        'maintains backward compatibility with simulateError flag',
        build: () {
          // Even with repository dependency, simulateError should take precedence
          when(() => mockRepository.getEvents(
            timeMin: any(named: 'timeMin'),
            timeMax: any(named: 'timeMax'),
            calendarId: any(named: 'calendarId'),
            maxResults: any(named: 'maxResults'),
          )).thenAnswer((_) async => Right(tDomainEvents));
          return CalendarBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LoadCalendarEvents(simulateError: true)),
        expect: () => [
          isA<CalendarLoading>(),
          isA<CalendarError>().having(
            (state) => state.message,
            'error message',
            'Exception: Failed to load events (simulated)',
          ),
        ],
        verify: (bloc) {
          // Should not call repository when simulating error
          verifyNever(() => mockRepository.getEvents(
            timeMin: any(named: 'timeMin'),
            timeMax: any(named: 'timeMax'),
            calendarId: any(named: 'calendarId'),
            maxResults: any(named: 'maxResults'),
          ));
        },
      );

      test('uses correct date range for repository calls', () async {
        // Arrange
        when(() => mockRepository.getEvents(
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
          calendarId: any(named: 'calendarId'),
          maxResults: any(named: 'maxResults'),
        )).thenAnswer((_) async => const Right([]));

        final bloc = CalendarBloc(repository: mockRepository);

        // Act
        bloc.add(const LoadCalendarEvents());
        await untilCalled(() => mockRepository.getEvents(
          timeMin: any(named: 'timeMin'),
          timeMax: any(named: 'timeMax'),
          calendarId: any(named: 'calendarId'),
          maxResults: any(named: 'maxResults'),
        ));

        // Assert
        final captured = verify(() => mockRepository.getEvents(
          timeMin: captureAny(named: 'timeMin'),
          timeMax: captureAny(named: 'timeMax'),
          calendarId: captureAny(named: 'calendarId'),
          maxResults: captureAny(named: 'maxResults'),
        )).captured;

        final timeMin = captured[0] as DateTime;
        final timeMax = captured[1] as DateTime;
        final calendarId = captured[2] as String;
        final maxResults = captured[3] as int;

        expect(calendarId, equals('primary'));
        expect(maxResults, equals(100));
        expect(timeMax.difference(timeMin).inDays, greaterThan(300)); // ~1 year range
        
        await bloc.close();
      });
    });
  });
}
