import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/services/infrastructure/calendar_retry_service.dart';
import 'package:planning/src/features/calendar/services/sync/calendar_sync_service.dart';
import 'package:planning/src/features/calendar/services/infrastructure/retry_config.dart';

class MockCalendarSyncService extends Mock implements CalendarSyncService {}

void main() {
  group('CalendarRetryService - Advanced Retry Mechanisms', () {
    late CalendarRetryService retryService;
    late MockCalendarSyncService mockSyncService;

    setUp(() {
      mockSyncService = MockCalendarSyncService();
      retryService = CalendarRetryService(syncService: mockSyncService);
    });

    group('Exponential Backoff Retry', () {
      test('should retry operation with exponential backoff on transient failures', () async {
        // Arrange
        var attemptCount = 0;
        when(() => mockSyncService.performFullSync()).thenAnswer((_) async {
          attemptCount++;
          if (attemptCount < 3) {
            return const Left(NetworkFailure('Temporary network error'));
          }
          return const Right([]);
        });

        // Act
        final result = await retryService.performSyncWithRetry();

        // Assert
        expect(result.isRight(), true);
        verify(() => mockSyncService.performFullSync()).called(3);
      });

      test('should respect maximum retry attempts', () async {
        // Arrange
        when(() => mockSyncService.performFullSync()).thenAnswer(
          (_) async => const Left(NetworkFailure('Persistent network error')),
        );

        // Act
        final result = await retryService.performSyncWithRetry();

        // Assert
        expect(result.isLeft(), true);
        verify(() => mockSyncService.performFullSync()).called(4); // 1 initial + 3 retries
      });

      test('should not retry on non-retryable failures', () async {
        // Arrange
        when(() => mockSyncService.performFullSync()).thenAnswer(
          (_) async => const Left(AuthFailure()),
        );

        // Act
        final result = await retryService.performSyncWithRetry();

        // Assert
        expect(result.isLeft(), true);
        verify(() => mockSyncService.performFullSync()).called(1); // No retries for auth failures
      });

      test('should calculate correct exponential backoff delays', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();
        when(() => mockSyncService.performFullSync()).thenAnswer(
          (_) async => const Left(NetworkFailure('Network timeout')),
        );

        // Act
        await retryService.performSyncWithRetry();
        stopwatch.stop();

        // Assert
        // Should have waited approximately: 1s + 2s + 4s = 7s
        // Allow for some variance in timing
        expect(stopwatch.elapsedMilliseconds, greaterThan(6000));
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      });
    });

    group('Circuit Breaker Pattern', () {
      test('should open circuit breaker after consecutive failures', () async {
        // Arrange
        when(() => mockSyncService.performFullSync()).thenAnswer(
          (_) async => const Left(ServerFailure()),
        );

        // Act - Trigger failures to open circuit
        for (int i = 0; i < 5; i++) {
          await retryService.performSyncWithRetry();
        }

        // Reset mock to track subsequent calls
        reset(mockSyncService);
        when(() => mockSyncService.performFullSync()).thenAnswer(
          (_) async => const Left(ServerFailure()),
        );

        // Next call should be short-circuited
        final result = await retryService.performSyncWithRetry();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => {
            expect(failure, isA<ServerFailure>()),
            expect((failure as ServerFailure).message, contains('Circuit breaker is open'))
          },
          (_) => fail('Expected failure'),
        );
        // Circuit breaker should prevent any calls to sync service
        verifyNever(() => mockSyncService.performFullSync());
      });

      test('should allow requests after circuit breaker timeout', () async {
        // Arrange
        when(() => mockSyncService.performFullSync()).thenAnswer(
          (_) async => const Left(ServerFailure()),
        );

        // Act - Open circuit breaker
        for (int i = 0; i < 5; i++) {
          await retryService.performSyncWithRetry();
        }

        // Fast-forward time to allow circuit recovery
        await retryService.resetCircuitBreakerForTesting();

        // Arrange for success
        when(() => mockSyncService.performFullSync()).thenAnswer(
          (_) async => const Right([]),
        );

        // Act - Try again after circuit recovery
        final result = await retryService.performSyncWithRetry();

        // Assert
        expect(result.isRight(), true);
      });
    });

    group('Jitter and Rate Limiting', () {
      test('should apply jitter to prevent thundering herd', () async {
        // Arrange
        final retryTimes = <int>[];
        when(() => mockSyncService.performFullSync()).thenAnswer((_) async {
          retryTimes.add(DateTime.now().millisecondsSinceEpoch);
          return const Left(NetworkFailure('Rate limited'));
        });

        // Act
        await retryService.performSyncWithRetry();

        // Assert
        // Should have recorded multiple attempts with varying delays due to jitter
        expect(retryTimes.length, equals(4)); // 1 initial + 3 retries
        
        // Check that delays are not exactly exponential (due to jitter)
        if (retryTimes.length >= 4) {
          final delay1 = retryTimes[1] - retryTimes[0];
          final delay2 = retryTimes[2] - retryTimes[1];
          
          // With jitter, delays should not be exactly 2x each other
          expect(delay2, isNot(equals(delay1 * 2)));
        }
      });

      test('should respect rate limiting headers', () async {
        // Arrange
        when(() => mockSyncService.performFullSync()).thenAnswer(
          (_) async => const Left(NetworkFailure('Rate limit exceeded')),
        );

        // Act
        final result = await retryService.performSyncWithRetry(
          rateLimitDelayMs: 5000,
        );

        // Assert
        expect(result.isLeft(), true);
        // Should respect the rate limit delay
        verify(() => mockSyncService.performFullSync()).called(4); // 1 initial + 3 retries
      });
    });

    group('Retry Policy Configuration', () {
      test('should use custom retry configuration', () async {
        // Arrange
        final customRetryService = CalendarRetryService(
          syncService: mockSyncService,
          config: const RetryConfig(
            maxRetries: 5,
            baseDelayMs: 500,
            maxDelayMs: 10000,
          ),
        );
        
        when(() => mockSyncService.performFullSync()).thenAnswer(
          (_) async => const Left(NetworkFailure('Custom retry test')),
        );

        // Act
        final result = await customRetryService.performSyncWithRetry();

        // Assert
        expect(result.isLeft(), true);
        verify(() => mockSyncService.performFullSync()).called(6); // 1 initial + 5 retries
      });

      test('should handle success on first retry attempt', () async {
        // Arrange
        var attemptCount = 0;
        when(() => mockSyncService.performFullSync()).thenAnswer((_) async {
          attemptCount++;
          if (attemptCount == 1) {
            return const Left(NetworkFailure('First attempt fails'));
          }
          return const Right([]);
        });

        // Act
        final result = await retryService.performSyncWithRetry();

        // Assert
        expect(result.isRight(), true);
        verify(() => mockSyncService.performFullSync()).called(2);
      });
    });

    group('Specific Error Handling', () {
      test('should handle 429 rate limit errors with special backoff', () async {
        // Arrange
        when(() => mockSyncService.performFullSync()).thenAnswer(
          (_) async => const Left(NetworkFailure('429 Too Many Requests')),
        );

        // Act
        final result = await retryService.performSyncWithRetry();

        // Assert
        expect(result.isLeft(), true);
        // Should still attempt retries for rate limit errors
        verify(() => mockSyncService.performFullSync()).called(4); // 1 initial + 3 retries
      });

      test('should handle 503 service unavailable with backoff', () async {
        // Arrange
        when(() => mockSyncService.performFullSync()).thenAnswer(
          (_) async => const Left(ServerFailure('Service temporarily unavailable')),
        );

        // Act
        final result = await retryService.performSyncWithRetry();

        // Assert
        expect(result.isLeft(), true);
        verify(() => mockSyncService.performFullSync()).called(4); // 1 initial + 3 retries
      });
    });
  });
}
