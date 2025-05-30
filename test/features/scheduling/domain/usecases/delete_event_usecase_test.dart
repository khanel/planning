import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/scheduling/domain/repositories/scheduling_repository.dart';
import 'package:planning/src/features/scheduling/domain/usecases/delete_event_usecase.dart';

class MockSchedulingRepository extends Mock implements SchedulingRepository {}

void main() {
  late DeleteEventUseCase usecase;
  late MockSchedulingRepository mockRepository;

  setUp(() {
    mockRepository = MockSchedulingRepository();
    usecase = DeleteEventUseCase(mockRepository);
  });

  const tEventId = 'test-event-1';
  const tParams = DeleteEventParams(eventId: tEventId);

  group('DeleteEventUseCase', () {
    test('should delete event via the repository when valid event ID is provided', () async {
      // arrange
      when(() => mockRepository.deleteEvent(any()))
          .thenAnswer((_) async => const Right(unit));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right(unit));
      verify(() => mockRepository.deleteEvent(tEventId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when repository returns failure', () async {
      // arrange
      const tFailure = CacheFailure('Delete failed');
      when(() => mockRepository.deleteEvent(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.deleteEvent(tEventId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure for empty event ID', () async {
      // arrange
      const invalidParams = DeleteEventParams(eventId: '');

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (unit) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.deleteEvent(any()));
    });

    test('should return ValidationFailure for whitespace-only event ID', () async {
      // arrange
      const invalidParams = DeleteEventParams(eventId: '   ');

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (unit) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.deleteEvent(any()));
    });

    test('should handle network failure gracefully', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockRepository.deleteEvent(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.deleteEvent(tEventId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle server failure gracefully', () async {
      // arrange
      const tFailure = ServerFailure();
      when(() => mockRepository.deleteEvent(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.deleteEvent(tEventId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should trim eventId before validation', () async {
      // arrange
      const paramsWithSpaces = DeleteEventParams(eventId: '  test-event-1  ');
      when(() => mockRepository.deleteEvent(any()))
          .thenAnswer((_) async => const Right(unit));

      // act
      final result = await usecase(paramsWithSpaces);

      // assert
      expect(result, const Right(unit));
      verify(() => mockRepository.deleteEvent('test-event-1')); // Should be trimmed
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
