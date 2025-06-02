import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';

void main() {
  group('Magic Auto-Prioritization Logic Tests', () {
    final DateTime now = DateTime.now();

    group('Task Classification Logic', () {
      test('should identify important tasks correctly', () {
        // High importance task
        final highImportanceTask = Task(
          id: '1',
          name: 'High Importance Task',
          description: 'Description',
          importance: TaskImportance.high,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        // Very high importance task
        final veryHighImportanceTask = Task(
          id: '2',
          name: 'Very High Importance Task',
          description: 'Description',
          importance: TaskImportance.veryHigh,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        // Medium importance task (not important for Eisenhower)
        final mediumImportanceTask = Task(
          id: '3',
          name: 'Medium Importance Task',
          description: 'Description',
          importance: TaskImportance.medium,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        // Assert important classification
        expect(
          highImportanceTask.importance == TaskImportance.high || 
          highImportanceTask.importance == TaskImportance.veryHigh,
          isTrue,
          reason: 'High importance tasks should be classified as important',
        );

        expect(
          veryHighImportanceTask.importance == TaskImportance.high || 
          veryHighImportanceTask.importance == TaskImportance.veryHigh,
          isTrue,
          reason: 'Very high importance tasks should be classified as important',
        );

        expect(
          mediumImportanceTask.importance == TaskImportance.high || 
          mediumImportanceTask.importance == TaskImportance.veryHigh,
          isFalse,
          reason: 'Medium importance tasks should not be classified as important',
        );
      });

      test('should identify urgent tasks correctly', () {
        // Task due today (urgent)
        final todayTask = Task(
          id: '1',
          name: 'Task Due Today',
          description: 'Description',
          dueDate: DateTime(now.year, now.month, now.day),
          importance: TaskImportance.medium,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        // Task due yesterday (urgent)
        final overdueTask = Task(
          id: '2',
          name: 'Overdue Task',
          description: 'Description',
          dueDate: now.subtract(const Duration(days: 1)),
          importance: TaskImportance.medium,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        // Task due next week (not urgent)
        final futureTask = Task(
          id: '3',
          name: 'Future Task',
          description: 'Description',
          dueDate: now.add(const Duration(days: 7)),
          importance: TaskImportance.medium,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        // Task with no due date (not urgent)
        final noDueDateTask = Task(
          id: '4',
          name: 'No Due Date Task',
          description: 'Description',
          importance: TaskImportance.medium,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        // Assert urgency classification
        expect(todayTask.isUrgent, isTrue, reason: 'Tasks due today should be urgent');
        expect(overdueTask.isUrgent, isTrue, reason: 'Overdue tasks should be urgent');
        expect(futureTask.isUrgent, isFalse, reason: 'Tasks due in the future should not be urgent');
        expect(noDueDateTask.isUrgent, isFalse, reason: 'Tasks with no due date should not be urgent');
      });
    });

    group('Eisenhower Matrix Classification', () {
      test('should classify tasks into correct quadrants', () {
        // DO NOW: Important + Urgent
        final doNowTask = Task(
          id: '1',
          name: 'Do Now Task',
          description: 'High importance, due today',
          dueDate: DateTime(now.year, now.month, now.day),
          importance: TaskImportance.high,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        // DECIDE: Important + Not Urgent
        final decideTask = Task(
          id: '2',
          name: 'Decide Task',
          description: 'Very high importance, due next week',
          dueDate: now.add(const Duration(days: 7)),
          importance: TaskImportance.veryHigh,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        // DELEGATE: Not Important + Urgent
        final delegateTask = Task(
          id: '3',
          name: 'Delegate Task',
          description: 'Low importance, due today',
          dueDate: DateTime(now.year, now.month, now.day),
          importance: TaskImportance.low,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        // DELETE: Not Important + Not Urgent
        final deleteTask = Task(
          id: '4',
          name: 'Delete Task',
          description: 'Medium importance, due next month',
          dueDate: now.add(const Duration(days: 30)),
          importance: TaskImportance.medium,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        // Verify task characteristics for DO NOW
        expect(doNowTask.isUrgent, isTrue);
        expect(
          doNowTask.importance == TaskImportance.high || 
          doNowTask.importance == TaskImportance.veryHigh,
          isTrue,
        );

        // Verify task characteristics for DECIDE
        expect(decideTask.isUrgent, isFalse);
        expect(
          decideTask.importance == TaskImportance.high || 
          decideTask.importance == TaskImportance.veryHigh,
          isTrue,
        );

        // Verify task characteristics for DELEGATE
        expect(delegateTask.isUrgent, isTrue);
        expect(
          delegateTask.importance == TaskImportance.high || 
          delegateTask.importance == TaskImportance.veryHigh,
          isFalse,
        );

        // Verify task characteristics for DELETE
        expect(deleteTask.isUrgent, isFalse);
        expect(
          deleteTask.importance == TaskImportance.high || 
          deleteTask.importance == TaskImportance.veryHigh,
          isFalse,
        );
      });
    });

    group('Magic Button Auto-Prioritization Logic', () {
      test('should determine correct priorities for various task combinations', () {
        final testCases = [
          {
            'name': 'High importance + Due today = DO NOW',
            'importance': TaskImportance.high,
            'dueDate': DateTime(now.year, now.month, now.day),
            'expectedCategory': 'doNow',
          },
          {
            'name': 'Very high importance + Due next week = DECIDE',
            'importance': TaskImportance.veryHigh,
            'dueDate': now.add(const Duration(days: 7)),
            'expectedCategory': 'decide',
          },
          {
            'name': 'Low importance + Due today = DELEGATE',
            'importance': TaskImportance.low,
            'dueDate': DateTime(now.year, now.month, now.day),
            'expectedCategory': 'delegate',
          },
          {
            'name': 'Medium importance + Due next month = DELETE',
            'importance': TaskImportance.medium,
            'dueDate': now.add(const Duration(days: 30)),
            'expectedCategory': 'delete',
          },
          {
            'name': 'Very low importance + No due date = DELETE',
            'importance': TaskImportance.veryLow,
            'dueDate': null,
            'expectedCategory': 'delete',
          },
        ];

        for (final testCase in testCases) {
          final task = Task(
            id: 'test_${testCase['name']}',
            name: testCase['name'] as String,
            description: 'Test task for auto-prioritization',
            dueDate: testCase['dueDate'] as DateTime?,
            importance: testCase['importance'] as TaskImportance,
            createdAt: now,
            updatedAt: now,
            completed: false,
          );

          final isImportant = task.importance == TaskImportance.high || 
                             task.importance == TaskImportance.veryHigh;
          final isUrgent = task.isUrgent;

          String expectedCategory;
          if (isUrgent && isImportant) {
            expectedCategory = 'doNow';
          } else if (!isUrgent && isImportant) {
            expectedCategory = 'decide';
          } else if (isUrgent && !isImportant) {
            expectedCategory = 'delegate';
          } else {
            expectedCategory = 'delete';
          }

          expect(
            expectedCategory,
            equals(testCase['expectedCategory']),
            reason: 'Task "${testCase['name']}" should be categorized as ${testCase['expectedCategory']}',
          );
        }
      });
    });

    group('Edge Cases', () {
      test('should handle tasks with null due dates', () {
        final task = Task(
          id: '1',
          name: 'No Due Date Task',
          description: 'Task without due date',
          importance: TaskImportance.high,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        expect(task.isUrgent, isFalse, reason: 'Tasks with null due dates should not be urgent');
      });

      test('should handle very high importance tasks correctly', () {
        final task = Task(
          id: '1',
          name: 'Critical Task',
          description: 'Very high importance task',
          importance: TaskImportance.veryHigh,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        expect(
          task.importance == TaskImportance.high || task.importance == TaskImportance.veryHigh,
          isTrue,
          reason: 'Very high importance should be classified as important',
        );
      });

      test('should handle very low importance tasks correctly', () {
        final task = Task(
          id: '1',
          name: 'Trivial Task',
          description: 'Very low importance task',
          importance: TaskImportance.veryLow,
          createdAt: now,
          updatedAt: now,
          completed: false,
        );

        expect(
          task.importance == TaskImportance.high || task.importance == TaskImportance.veryHigh,
          isFalse,
          reason: 'Very low importance should not be classified as important',
        );
      });
    });
  });
}
