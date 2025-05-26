import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/eisenhower_matrix.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';

void main() {
  group('Dragging Between Quadrants Diagnostic Test', () {
    testWidgets('should correctly update task priority when dragged from unprioritized to quadrant and back',
        (WidgetTester tester) async {
          
      // Create task in unprioritized state
      final task = Task(
        id: '1',
        name: 'Test Task',
        description: 'This is a test task',
        completed: false,
        importance: TaskImportance.medium,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        priority: EisenhowerCategory.unprioritized,
      );
      
      // Store updated tasks for verification
      Task? updatedTask;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: [task],
              onPriorityChanged: (task, priority) {
                // Update our local copy of the task
                updatedTask = task.copyWith(priority: priority);
                print('Priority changed: ${task.name} to $priority');
              },
            ),
          ),
        ),
      );
      
      // Initially in unprioritized section
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Unprioritized Tasks (1)'), findsOneWidget);
      
      // 1. Drag from unprioritized to Decide quadrant
      final taskItem = find.text('Test Task').first;
      final decideQuadrant = find.text('Decide').first;
      
      await tester.drag(taskItem, tester.getCenter(decideQuadrant) - tester.getCenter(taskItem));
      await tester.pump();
      
      // Verify priority was updated to Decide
      expect(updatedTask?.priority, equals(EisenhowerCategory.decide));
      
      // Rebuild with updated task
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: [updatedTask!],
              onPriorityChanged: (task, priority) {
                updatedTask = task.copyWith(priority: priority);
                print('Priority changed: ${task.name} to $priority');
              },
            ),
          ),
        ),
      );
      
      // Task should now be in Decide quadrant
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Unprioritized Tasks (0)'), findsOneWidget);
      
      // 2. Drag back from Decide to unprioritized
      final updatedTaskItem = find.text('Test Task').first;
      final unprioritizedSection = find.text('Unprioritized Tasks (0)').first;
      
      await tester.drag(updatedTaskItem, tester.getCenter(unprioritizedSection) - tester.getCenter(updatedTaskItem));
      await tester.pump();
      
      // Verify priority was updated back to unprioritized
      expect(updatedTask?.priority, equals(EisenhowerCategory.unprioritized));
      
      // Print debug information
      print('Final task state: ${updatedTask?.name}, Priority: ${updatedTask?.priority}');
    });
  });
}
