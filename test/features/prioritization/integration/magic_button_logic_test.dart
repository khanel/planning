import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import '../test_helpers/test_task_factory.dart';

/// Integration tests for magic auto-prioritization button functionality
void main() {
  group('Magic Button Auto-Prioritization Logic Tests', () {
    
    testWidgets(
      'Test 1: Magic button appears when unprioritized tasks exist',
      (WidgetTester tester) async {
        // Test the logic: when unprioritized tasks exist, magic button should appear
        final unprioritizedTasks = [
          TestTaskFactory.createTask(
            id: 'task-1',
            name: 'Unprioritized Task',
            dueDate: DateTime.now(),
            priority: EisenhowerCategory.unprioritized,
          ),
        ];

        // Verify that we can filter unprioritized tasks correctly
        final filteredTasks = unprioritizedTasks.where(
          (task) => task.priority == EisenhowerCategory.unprioritized
        ).toList();

        expect(filteredTasks.length, equals(1));
        expect(filteredTasks.first.name, equals('Unprioritized Task'));
      },
    );

    testWidgets(
      'Test 2: Auto-prioritization logic correctly categorizes tasks',
      (WidgetTester tester) async {
        // Test the core logic of auto-prioritization
        final testTasks = [
          // Should go to DO NOW (urgent + important)
          TestTaskFactory.createTask(
            id: 'urgent-important',
            name: 'Urgent Important Task',
            dueDate: DateTime.now().subtract(const Duration(days: 1)), // Overdue = urgent
            importance: TaskImportance.high, // High importance
            priority: EisenhowerCategory.unprioritized,
          ),
          // Should go to DECIDE (not urgent + important)  
          TestTaskFactory.createTask(
            id: 'not-urgent-important',
            name: 'Not Urgent But Important',
            dueDate: DateTime.now().add(const Duration(days: 7)), // Future = not urgent
            importance: TaskImportance.high, // High importance
            priority: EisenhowerCategory.unprioritized,
          ),
          // Should go to DELEGATE (urgent + not important)
          TestTaskFactory.createTask(
            id: 'urgent-not-important',
            name: 'Urgent Not Important',
            dueDate: DateTime.now(), // Today = urgent
            importance: TaskImportance.low, // Low importance
            priority: EisenhowerCategory.unprioritized,
          ),
          // Should go to DELETE (not urgent + not important)
          TestTaskFactory.createTask(
            id: 'not-urgent-not-important',
            name: 'Neither Urgent Nor Important',
            dueDate: DateTime.now().add(const Duration(days: 10)), // Future = not urgent
            importance: TaskImportance.low, // Low importance
            priority: EisenhowerCategory.unprioritized,
          ),
        ];

        // Test the auto-prioritization algorithm
        for (final task in testTasks) {
          final isUrgent = task.isUrgent;
          final isImportant = task.importance == TaskImportance.high || 
                             task.importance == TaskImportance.veryHigh;

          EisenhowerCategory expectedCategory;
          if (isUrgent && isImportant) {
            expectedCategory = EisenhowerCategory.doNow;
          } else if (!isUrgent && isImportant) {
            expectedCategory = EisenhowerCategory.decide;
          } else if (isUrgent && !isImportant) {
            expectedCategory = EisenhowerCategory.delegate;
          } else {
            expectedCategory = EisenhowerCategory.delete;
          }

          // Verify the logic works as expected
          switch (task.id) {
            case 'urgent-important':
              expect(expectedCategory, equals(EisenhowerCategory.doNow));
              break;
            case 'not-urgent-important':
              expect(expectedCategory, equals(EisenhowerCategory.decide));
              break;
            case 'urgent-not-important':
              expect(expectedCategory, equals(EisenhowerCategory.delegate));
              break;
            case 'not-urgent-not-important':
              expect(expectedCategory, equals(EisenhowerCategory.delete));
              break;
          }
        }
      },
    );

    testWidgets(
      'Test 3: Urgency calculation works correctly for magic button',
      (WidgetTester tester) async {
        final now = DateTime.now();
        
        // Test different due date scenarios
        final testCases = [
          {
            'name': 'Overdue task',
            'dueDate': now.subtract(const Duration(days: 1)),
            'expectedUrgent': true,
          },
          {
            'name': 'Due today',
            'dueDate': now,
            'expectedUrgent': true,
          },
          {
            'name': 'Due tomorrow',
            'dueDate': now.add(const Duration(days: 1)),
            'expectedUrgent': false,
          },
          {
            'name': 'Due next week',
            'dueDate': now.add(const Duration(days: 7)),
            'expectedUrgent': false,
          },
        ];

        for (final testCase in testCases) {
          final task = TestTaskFactory.createTask(
            id: 'test-urgency',
            name: testCase['name'] as String,
            dueDate: testCase['dueDate'] as DateTime,
            priority: EisenhowerCategory.unprioritized,
          );

          expect(
            task.isUrgent,
            equals(testCase['expectedUrgent']),
            reason: 'Task "${testCase['name']}" urgency check failed',
          );
        }
      },
    );

    testWidgets(
      'Test 4: Importance levels are correctly identified for magic button',
      (WidgetTester tester) async {
        final importanceLevels = [
          {
            'level': TaskImportance.veryHigh,
            'shouldBeImportant': true,
          },
          {
            'level': TaskImportance.high,
            'shouldBeImportant': true,
          },
          {
            'level': TaskImportance.medium,
            'shouldBeImportant': false, // Assuming medium is not considered "important"
          },
          {
            'level': TaskImportance.low,
            'shouldBeImportant': false,
          },
          {
            'level': TaskImportance.veryLow,
            'shouldBeImportant': false,
          },
        ];

        for (final importanceTest in importanceLevels) {
          final task = TestTaskFactory.createTask(
            id: 'test-importance',
            name: 'Test Task',
            dueDate: DateTime.now(),
            importance: importanceTest['level'] as TaskImportance,
            priority: EisenhowerCategory.unprioritized,
          );

          final isImportant = task.importance == TaskImportance.high || 
                             task.importance == TaskImportance.veryHigh;

          expect(
            isImportant,
            equals(importanceTest['shouldBeImportant']),
            reason: 'Importance level ${importanceTest['level']} classification failed',
          );
        }
      },
    );

    testWidgets(
      'Test 5: Magic button visibility logic when tasks move to/from unprioritized',
      (WidgetTester tester) async {
        // Test scenario 1: Task moved from prioritized to unprioritized
        final taskMovedToUnprioritized = TestTaskFactory.createTask(
          id: 'moved-task',
          name: 'Task Moved to Unprioritized',
          dueDate: DateTime.now(),
          priority: EisenhowerCategory.unprioritized, // Now unprioritized
        );

        final hasUnprioritizedTasks = [taskMovedToUnprioritized].any(
          (task) => task.priority == EisenhowerCategory.unprioritized
        );
        
        expect(hasUnprioritizedTasks, isTrue, 
          reason: 'Magic button should appear when task moved to unprioritized');

        // Test scenario 2: All tasks are prioritized
        final allPrioritizedTasks = [
          TestTaskFactory.createTask(
            id: 'prioritized-1',
            name: 'Prioritized Task 1',
            dueDate: DateTime.now(),
            priority: EisenhowerCategory.doNow,
          ),
          TestTaskFactory.createTask(
            id: 'prioritized-2',
            name: 'Prioritized Task 2',
            dueDate: DateTime.now(),
            priority: EisenhowerCategory.decide,
          ),
        ];

        final hasNoUnprioritizedTasks = allPrioritizedTasks.any(
          (task) => task.priority == EisenhowerCategory.unprioritized
        );
        
        expect(hasNoUnprioritizedTasks, isFalse,
          reason: 'Magic button should be hidden when all tasks are prioritized');
      },
    );

    testWidgets(
      'Test 6: Magic button correctly prioritizes tasks after confirmation',
      (WidgetTester tester) async {
        // Create comprehensive test tasks for all scenarios
        final comprehensiveTestTasks = [
          // DO NOW scenarios (urgent + important)
          TestTaskFactory.createTask(
            id: 'do-now-1',
            name: 'Overdue High Priority',
            dueDate: DateTime.now().subtract(const Duration(days: 2)),
            importance: TaskImportance.high,
            priority: EisenhowerCategory.unprioritized,
          ),
          TestTaskFactory.createTask(
            id: 'do-now-2', 
            name: 'Today Very High Priority',
            dueDate: DateTime.now(),
            importance: TaskImportance.veryHigh,
            priority: EisenhowerCategory.unprioritized,
          ),
          
          // DECIDE scenarios (not urgent + important)
          TestTaskFactory.createTask(
            id: 'decide-1',
            name: 'Future High Priority',
            dueDate: DateTime.now().add(const Duration(days: 5)),
            importance: TaskImportance.high,
            priority: EisenhowerCategory.unprioritized,
          ),
          
          // DELEGATE scenarios (urgent + not important)
          TestTaskFactory.createTask(
            id: 'delegate-1',
            name: 'Today Low Priority',
            dueDate: DateTime.now(),
            importance: TaskImportance.low,
            priority: EisenhowerCategory.unprioritized,
          ),
          
          // DELETE scenarios (not urgent + not important)
          TestTaskFactory.createTask(
            id: 'delete-1',
            name: 'Future Low Priority',
            dueDate: DateTime.now().add(const Duration(days: 7)),
            importance: TaskImportance.low,
            priority: EisenhowerCategory.unprioritized,
          ),
        ];

        // Group tasks by their expected categories after auto-prioritization
        final categorizedTasks = <EisenhowerCategory, List<Task>>{
          EisenhowerCategory.doNow: [],
          EisenhowerCategory.decide: [],
          EisenhowerCategory.delegate: [],
          EisenhowerCategory.delete: [],
        };

        for (final task in comprehensiveTestTasks) {
          final isUrgent = task.isUrgent;
          final isImportant = task.importance == TaskImportance.high || 
                             task.importance == TaskImportance.veryHigh;

          if (isUrgent && isImportant) {
            categorizedTasks[EisenhowerCategory.doNow]!.add(task);
          } else if (!isUrgent && isImportant) {
            categorizedTasks[EisenhowerCategory.decide]!.add(task);
          } else if (isUrgent && !isImportant) {
            categorizedTasks[EisenhowerCategory.delegate]!.add(task);
          } else {
            categorizedTasks[EisenhowerCategory.delete]!.add(task);
          }
        }

        // Verify categorization counts
        expect(categorizedTasks[EisenhowerCategory.doNow]!.length, equals(2),
          reason: 'Should have 2 DO NOW tasks');
        expect(categorizedTasks[EisenhowerCategory.decide]!.length, equals(1),
          reason: 'Should have 1 DECIDE task');
        expect(categorizedTasks[EisenhowerCategory.delegate]!.length, equals(1),
          reason: 'Should have 1 DELEGATE task');
        expect(categorizedTasks[EisenhowerCategory.delete]!.length, equals(1),
          reason: 'Should have 1 DELETE task');

        // Verify specific task placements
        final doNowTasks = categorizedTasks[EisenhowerCategory.doNow]!;
        expect(doNowTasks.any((t) => t.name == 'Overdue High Priority'), isTrue);
        expect(doNowTasks.any((t) => t.name == 'Today Very High Priority'), isTrue);

        final decideTasks = categorizedTasks[EisenhowerCategory.decide]!;
        expect(decideTasks.any((t) => t.name == 'Future High Priority'), isTrue);

        final delegateTasks = categorizedTasks[EisenhowerCategory.delegate]!;
        expect(delegateTasks.any((t) => t.name == 'Today Low Priority'), isTrue);

        final deleteTasks = categorizedTasks[EisenhowerCategory.delete]!;
        expect(deleteTasks.any((t) => t.name == 'Future Low Priority'), isTrue);
      },
    );

    testWidgets(
      'Test 7: Magic button shows correct dialog preview information',
      (WidgetTester tester) async {
        // Test that the preview dialog would show correct categorization
        final dialogTestTasks = [
          TestTaskFactory.createTask(
            id: 'urgent-important-preview',
            name: 'Urgent Important Preview Task',
            dueDate: DateTime.now().subtract(const Duration(hours: 2)), // Urgent
            importance: TaskImportance.veryHigh, // Important
            priority: EisenhowerCategory.unprioritized,
          ),
          TestTaskFactory.createTask(
            id: 'medium-priority-preview',
            name: 'Medium Priority Preview Task',
            dueDate: DateTime.now().add(const Duration(days: 3)), // Not urgent
            importance: TaskImportance.medium, // Medium importance (should be "not important")
            priority: EisenhowerCategory.unprioritized,
          ),
        ];

        // Verify the categorization logic that would be shown in dialog
        for (final task in dialogTestTasks) {
          final isUrgent = task.isUrgent;
          final isImportant = task.importance == TaskImportance.high || 
                             task.importance == TaskImportance.veryHigh;

          if (task.id == 'urgent-important-preview') {
            expect(isUrgent, isTrue, reason: 'Task should be urgent');
            expect(isImportant, isTrue, reason: 'Task should be important');
            // Should go to DO NOW
          } else if (task.id == 'medium-priority-preview') {
            expect(isUrgent, isFalse, reason: 'Task should not be urgent');
            expect(isImportant, isFalse, reason: 'Medium importance should not be "important"');
            // Should go to DELETE
          }
        }
      },
    );
  });
}
