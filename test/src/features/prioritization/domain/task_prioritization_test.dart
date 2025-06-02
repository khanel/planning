import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';

void main() {
  group('Task Eisenhower Prioritization', () {
    late Task task;
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(const Duration(days: 1));
    final DateTime tomorrow = now.add(const Duration(days: 1));
    final DateTime nextWeek = now.add(const Duration(days: 7));

    setUp(() {
      task = Task(
        id: '1',
        name: 'Test Task',
        description: 'Test Description',
        dueDate: tomorrow,
        completed: false,
        importance: TaskImportance.medium,
        createdAt: now,
        updatedAt: now,
        priority: EisenhowerCategory.unprioritized,
      );
    });

    test('should update priority when user assigns new priority category', () {
      expect(task.priority, EisenhowerCategory.unprioritized);
      
      final updatedTask = task.copyWith(
        priority: EisenhowerCategory.doNow,
      );
      
      expect(updatedTask.priority, EisenhowerCategory.doNow);
      expect(updatedTask.eisenhowerCategory, EisenhowerCategory.doNow);
    });

    test('should calculate as urgent when due date is today or in the past', () {
      // Due yesterday (past) - should be urgent
      final pastTask = task.copyWith(dueDate: yesterday);
      expect(pastTask.isUrgent, true);
      
      // Due today - should be urgent
      final today = DateTime(now.year, now.month, now.day);
      final todayTask = task.copyWith(dueDate: today);
      expect(todayTask.isUrgent, true);
    });

    test('should not be urgent when due date is in the future', () {
      // Due tomorrow - should not be urgent
      expect(task.isUrgent, false);
      
      // Due next week - should not be urgent
      final futureTask = task.copyWith(dueDate: nextWeek);
      expect(futureTask.isUrgent, false);
    });

    test('should not be urgent when due date is null', () {
      final noDueDateTask = task.copyWith(dueDate: null);
      expect(noDueDateTask.isUrgent, false);
    });

    test('should calculate eisenhowerCategory based on importance and urgency when unprioritized', () {
      // High importance, urgent task -> Do Now
      final highUrgentTask = task.copyWith(
        importance: TaskImportance.high,
        dueDate: yesterday,
        priority: EisenhowerCategory.unprioritized,
      );
      expect(highUrgentTask.eisenhowerCategory, EisenhowerCategory.doNow);
      
      // High importance, not urgent task -> Decide
      final highNotUrgentTask = task.copyWith(
        importance: TaskImportance.high,
        dueDate: nextWeek,
        priority: EisenhowerCategory.unprioritized,
      );
      expect(highNotUrgentTask.eisenhowerCategory, EisenhowerCategory.decide);
      
      // Low importance, urgent task -> Delegate
      final lowUrgentTask = task.copyWith(
        importance: TaskImportance.low,
        dueDate: yesterday,
        priority: EisenhowerCategory.unprioritized,
      );
      expect(lowUrgentTask.eisenhowerCategory, EisenhowerCategory.delegate);
      
      // Low importance, not urgent task -> Delete
      final lowNotUrgentTask = task.copyWith(
        importance: TaskImportance.low,
        dueDate: nextWeek,
        priority: EisenhowerCategory.unprioritized,
      );
      expect(lowNotUrgentTask.eisenhowerCategory, EisenhowerCategory.delete);
    });

    test('should respect user-assigned priority over calculated priority', () {
      // Even though task would calculate as Delete, user assigned it to Do Now
      final overriddenTask = task.copyWith(
        importance: TaskImportance.low,
        dueDate: nextWeek,
        priority: EisenhowerCategory.doNow,
      );
      
      expect(overriddenTask.eisenhowerCategory, EisenhowerCategory.doNow);
    });

    test('should treat very high importance same as high for eisenhower matrix', () {
      final veryHighTask = task.copyWith(
        importance: TaskImportance.veryHigh,
        dueDate: nextWeek,
        priority: EisenhowerCategory.unprioritized,
      );
      
      expect(veryHighTask.eisenhowerCategory, EisenhowerCategory.decide);
    });
  });
}
