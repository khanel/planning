import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';

void main() {
  group('EisenhowerCategory', () {
    test('should have the correct values and properties for all categories', () {
      // Test Do Now (Q1)
      expect(EisenhowerCategory.doNow.name, 'Do Now');
      expect(
        EisenhowerCategory.doNow.description,
        'Important and urgent tasks that require immediate attention',
      );
      expect(EisenhowerCategory.doNow.color, Colors.red);

      // Test Decide (Q2)
      expect(EisenhowerCategory.decide.name, 'Decide');
      expect(
        EisenhowerCategory.decide.description,
        'Important but not urgent tasks that require planning',
      );
      expect(EisenhowerCategory.decide.color, Colors.blue);

      // Test Delegate (Q3)
      expect(EisenhowerCategory.delegate.name, 'Delegate');
      expect(
        EisenhowerCategory.delegate.description,
        'Urgent but not important tasks that can be delegated',
      );
      expect(EisenhowerCategory.delegate.color, Colors.amber);

      // Test Delete (Q4)
      expect(EisenhowerCategory.delete.name, 'Delete');
      expect(
        EisenhowerCategory.delete.description,
        'Neither important nor urgent tasks that can be eliminated',
      );
      expect(EisenhowerCategory.delete.color, Colors.green);

      // Test Unprioritized
      expect(EisenhowerCategory.unprioritized.name, 'Unprioritized');
      expect(
        EisenhowerCategory.unprioritized.description,
        'Tasks that have not been prioritized yet',
      );
      expect(EisenhowerCategory.unprioritized.color, Colors.grey);
    });

    test('values list should contain all categories', () {
      expect(EisenhowerCategory.values.length, 5);
      expect(EisenhowerCategory.values, contains(EisenhowerCategory.doNow));
      expect(EisenhowerCategory.values, contains(EisenhowerCategory.decide));
      expect(EisenhowerCategory.values, contains(EisenhowerCategory.delegate));
      expect(EisenhowerCategory.values, contains(EisenhowerCategory.delete));
      expect(EisenhowerCategory.values, contains(EisenhowerCategory.unprioritized));
    });
  });
}
