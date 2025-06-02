import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/eisenhower_matrix.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart'; // For TaskImportance

void main() {
  group('Unprioritized Tasks Section', () {
    late List<Task> tasks;
    final DateTime now = DateTime.now();
    
    setUp(() {
      tasks = [
        Task(
          id: '1',
          name: 'Do Now Task',
          description: 'This is a Do Now task',
          dueDate: now,
          completed: false,
          importance: TaskImportance.high,
          createdAt: now,
          updatedAt: now,
          priority: EisenhowerCategory.doNow,
        ),
        Task(
          id: '2',
          name: 'Decide Task',
          description: 'This is a Decide task',
          dueDate: now.add(const Duration(days: 5)),
          completed: false,
          importance: TaskImportance.high,
          createdAt: now,
          updatedAt: now,
          priority: EisenhowerCategory.decide,
        ),
      ];
    });

    testWidgets('should always show the unprioritized section even when empty', 
        (WidgetTester tester) async {
      // Build the EisenhowerMatrix with no unprioritized tasks
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: tasks, // All tasks are prioritized
              onPriorityChanged: (_, __) {},
            ),
          ),
        ),
      );
      
      // Verify the unprioritized section is still shown
      expect(find.text('Unprioritized Tasks (0)'), findsOneWidget);
      
      // Verify it has a compact/collapsed appearance
      final unprioritizedSection = find.ancestor(
        of: find.text('Unprioritized Tasks (0)'),
        matching: find.byType(Column),
      ).first;
      
      // Check that the empty state message is shown in the unprioritized section
      expect(
        find.descendant(
          of: unprioritizedSection,
          matching: find.text('Drag tasks here to unprioritize them'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should allow dragging tasks from quadrants to unprioritized section', 
        (WidgetTester tester) async {
      bool priorityChanged = false;
      Task? updatedTask;
      EisenhowerCategory? newPriority;
      
      // Build the EisenhowerMatrix with prioritized tasks
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: tasks,
              onPriorityChanged: (task, priority) {
                priorityChanged = true;
                updatedTask = task;
                newPriority = priority;
              },
            ),
          ),
        ),
      );
      
      // Find a task in the Do Now quadrant
      final doNowTask = find.text('Do Now Task').first;
      expect(doNowTask, findsOneWidget);
      
      // Find the unprioritized section
      final unprioritizedSection = find.text('Unprioritized Tasks (0)').first;
      expect(unprioritizedSection, findsOneWidget);
      
      // Drag the task to the unprioritized section
      final doNowTaskLocation = tester.getCenter(doNowTask);
      final unprioritizedLocation = tester.getCenter(unprioritizedSection);
      
      await tester.dragFrom(doNowTaskLocation, unprioritizedLocation - doNowTaskLocation);
      await tester.pumpAndSettle();
      
      // Verify the callback was called
      expect(priorityChanged, isTrue);
      expect(updatedTask?.id, equals('1'));
      expect(newPriority, equals(EisenhowerCategory.unprioritized));
      
      // The task should now appear in the unprioritized section
      // and the count should be updated to reflect this
      expect(find.text('Unprioritized Tasks (1)'), findsOneWidget);
    });

    testWidgets('should persist task priority change when dragged to unprioritized section', 
        (WidgetTester tester) async {
      late List<Task> localTasks = List.from(tasks);
      
      // Function to update task priority in our local state
      void updateTaskPriority(Task task, EisenhowerCategory priority) {
        final index = localTasks.indexWhere((t) => t.id == task.id);
        if (index >= 0) {
          localTasks[index] = task.copyWith(priority: priority);
        }
      }
      
      // Build the EisenhowerMatrix with the initial tasks
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: localTasks,
              onPriorityChanged: updateTaskPriority,
            ),
          ),
        ),
      );
      
      // Verify initial state - task is in Do Now quadrant
      expect(find.text('Do Now Task'), findsOneWidget);
      expect(find.text('Unprioritized Tasks (0)'), findsOneWidget);
      
      // Find the task in the Do Now quadrant
      final doNowTask = find.text('Do Now Task').first;
      
      // Find the unprioritized section
      final unprioritizedSection = find.text('Unprioritized Tasks (0)').first;
      
      // Drag the task to the unprioritized section
      final doNowTaskLocation = tester.getCenter(doNowTask);
      final unprioritizedLocation = tester.getCenter(unprioritizedSection);
      
      await tester.dragFrom(doNowTaskLocation, unprioritizedLocation - doNowTaskLocation);
      await tester.pumpAndSettle();
      
      // Verify the task is now in the unprioritized section
      expect(find.text('Unprioritized Tasks (1)'), findsOneWidget);
      
      // Verify the task's priority was actually changed in our data model
      final updatedTask = localTasks.firstWhere((task) => task.id == '1');
      expect(updatedTask.priority, equals(EisenhowerCategory.unprioritized));
      
      // Rebuild widget with the updated tasks list to verify persistence
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: localTasks,
              onPriorityChanged: updateTaskPriority,
            ),
          ),
        ),
      );
      
      // Verify the task remains in the unprioritized section after rebuild
      expect(find.text('Unprioritized Tasks (1)'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text('Do Now Task'),
        ),
        findsOneWidget,
      );
      
      // Verify the Do Now quadrant no longer contains the task
      expect(
        find.descendant(
          of: find.text('Do Now'),
          matching: find.text('Do Now Task'),
        ),
        findsNothing,
      );
    });
  });
}
