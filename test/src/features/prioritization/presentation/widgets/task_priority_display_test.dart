import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/eisenhower_matrix.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';

void main() {
  group('Task Priority Display Test', () {
    testWidgets('should display tasks in correct quadrants based on priority',
        (WidgetTester tester) async {
      // Create tasks with explicit priorities
      final doNowTask = Task(
        id: '1',
        name: 'Do Now Task',
        description: 'This task should appear in Do Now quadrant',
        completed: false,
        importance: TaskImportance.high,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        priority: EisenhowerCategory.doNow,
      );

      final decideTask = Task(
        id: '2',
        name: 'Decide Task',
        description: 'This task should appear in Decide quadrant',
        completed: false,
        importance: TaskImportance.high,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        priority: EisenhowerCategory.decide,
      );

      final unprioritizedTask = Task(
        id: '3',
        name: 'Unprioritized Task',
        description: 'This task should appear in Unprioritized section',
        completed: false,
        importance: TaskImportance.medium,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        priority: EisenhowerCategory.unprioritized,
      );

      final tasks = [doNowTask, decideTask, unprioritizedTask];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: tasks,
            ),
          ),
        ),
      );

      // Verify tasks appear in the correct quadrants
      expect(find.text('Do Now Task'), findsOneWidget);
      expect(find.text('Decide Task'), findsOneWidget);
      expect(find.text('Unprioritized Task'), findsOneWidget);

      // Verify task counts in each section
      expect(find.text('Unprioritized Tasks (1)'), findsOneWidget);
    });

    testWidgets('should update task display when priority changes',
        (WidgetTester tester) async {
      // Task for testing
      final task = Task(
        id: '1',
        name: 'Test Task',
        description: 'Description',
        completed: false,
        importance: TaskImportance.high,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        priority: EisenhowerCategory.doNow,
      );
      
      // Track priority changes
      EisenhowerCategory? newPriority;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: [task],
              onPriorityChanged: (task, priority) {
                newPriority = priority;
              },
            ),
          ),
        ),
      );
      
      // Initially in Do Now quadrant
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Do Now Tasks (1)'), findsNothing); // Quadrant titles don't include counts
      expect(find.text('Unprioritized Tasks (0)'), findsOneWidget);
      
      // Simulate drag to unprioritized section
      final taskWidget = find.text('Test Task').first;
      final unprioritizedSection = find.text('Unprioritized Tasks (0)').first;
      
      await tester.drag(taskWidget, tester.getCenter(unprioritizedSection) - tester.getCenter(taskWidget));
      await tester.pump();
      
      // Verify priority was updated correctly
      expect(newPriority, equals(EisenhowerCategory.unprioritized));
    });
  });
}
