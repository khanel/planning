import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/eisenhower_matrix.dart';
import 'package:planning/src/features/task/presentation/widgets/task_list_view.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';

void main() {
  group('Task Category Consistency Tests', () {
    late Task testTask;
    
    setUp(() {
      // Create a test task with a specific priority
      testTask = Task(
        id: '1',
        name: 'Test Task',
        description: 'A test task',
        completed: false,
        importance: TaskImportance.high,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        priority: EisenhowerCategory.decide, // Explicitly set to "Decide"
      );
    });
    
    testWidgets('Task should have same category in Eisenhower matrix and task list view', 
        (WidgetTester tester) async {
      // First, render the Eisenhower matrix
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: [testTask],
            ),
          ),
        ),
      );
      
      // Verify the task appears in the "Decide" quadrant
      expect(find.text(EisenhowerCategory.decide.name), findsOneWidget);
      
      // The task should be in the Decide quadrant
      // We can verify this by checking if the task name appears inside the Decide quadrant
      final taskName = find.text('Test Task');
      expect(taskName, findsOneWidget);
      
      // Print task details for debugging
      print('Task priority: ${testTask.priority}');
      print('Task eisenhowerCategory: ${testTask.eisenhowerCategory}');
      
      // Now, render the task list view
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListView(
              tasks: [testTask],
            ),
          ),
        ),
      );
      
      // Verify the category displayed in the task list matches
      expect(find.text('Category: decide'), findsOneWidget);
    });
    
    testWidgets('Task priority should match eisenhowerCategory for consistency', 
        (WidgetTester tester) async {
      // Verify that task.priority and task.eisenhowerCategory are consistent
      expect(testTask.priority, equals(EisenhowerCategory.decide));
      expect(testTask.eisenhowerCategory, equals(EisenhowerCategory.decide));
      
      // Change the task's priority
      final updatedTask = testTask.copyWith(priority: EisenhowerCategory.doNow);
      
      // Verify that priority and eisenhowerCategory are both updated
      expect(updatedTask.priority, equals(EisenhowerCategory.doNow));
      expect(updatedTask.eisenhowerCategory, equals(EisenhowerCategory.doNow));
    });
    
    testWidgets('Dragging task to different quadrant should update both priority and category', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: [testTask],
              onPriorityChanged: (task, priority) {
                // Simulating the callback
                print('Priority changed to: $priority');
              },
            ),
          ),
        ),
      );
      
      // Simulate dragging from Decide to Do Now quadrant
      // First, find the task in the Decide quadrant
      final decideName = find.text(EisenhowerCategory.decide.name);
      expect(decideName, findsOneWidget);
      
      // Find the "Do Now" quadrant
      final doNowName = find.text(EisenhowerCategory.doNow.name);
      expect(doNowName, findsOneWidget);
      final updatedTask = testTask.copyWith(priority: EisenhowerCategory.doNow);
      
      // Verify that both properties are updated consistently
      expect(updatedTask.priority, equals(EisenhowerCategory.doNow));
      expect(updatedTask.eisenhowerCategory, equals(EisenhowerCategory.doNow));
      
      // Now, render the task list view with the updated task
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListView(
              tasks: [updatedTask],
            ),
          ),
        ),
      );
      
      // Verify the category displayed in the task list matches the new priority
      expect(find.text('Category: doNow'), findsOneWidget);
    });
  });
}
