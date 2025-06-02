import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_strategy.dart';

void main() {
  group('EisenhowerStrategy', () {
    late EisenhowerStrategy strategy;

    setUp(() {
      strategy = EisenhowerStrategy();
    });

    test('should return doNow for important and urgent tasks', () {
      final result = strategy.calculatePriority(
        isImportant: true,
        isUrgent: true,
      );
      expect(result, EisenhowerCategory.doNow);
    });

    test('should return decide for important but not urgent tasks', () {
      final result = strategy.calculatePriority(
        isImportant: true,
        isUrgent: false,
      );
      expect(result, EisenhowerCategory.decide);
    });

    test('should return delegate for urgent but not important tasks', () {
      final result = strategy.calculatePriority(
        isImportant: false,
        isUrgent: true,
      );
      expect(result, EisenhowerCategory.delegate);
    });

    test('should return delete for neither important nor urgent tasks', () {
      final result = strategy.calculatePriority(
        isImportant: false,
        isUrgent: false,
      );
      expect(result, EisenhowerCategory.delete);
    });
  });
}
