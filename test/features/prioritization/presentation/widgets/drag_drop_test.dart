import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';

void main() {
  group('Drag and Drop Task Functionality Tests', () {
    late Task task;
    final DateTime now = DateTime.now();

    setUp(() {
      task = Task(
        id: '1',
        name: 'Test Task',
        description: 'Test Description',
        dueDate: now,
        completed: false,
        importance: TaskImportance.high,
        createdAt: now,
        updatedAt: now,
        priority: EisenhowerCategory.unprioritized,
      );
    });

    testWidgets('Task should be draggable', (WidgetTester tester) async {
      bool onAcceptCalled = false;
      Task? draggedTask;

      // Build a simple drag source and target to test functionality
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Drag source
                Draggable<Task>(
                  data: task,
                  feedback: Material(
                    elevation: 4.0,
                    child: Container(
                      width: 200,
                      height: 80,
                      color: Colors.blue.withOpacity(0.5),
                      child: Center(child: Text(task.name)),
                    ),
                  ),
                  childWhenDragging: Container(
                    width: 200,
                    height: 80,
                    color: Colors.grey.withOpacity(0.3),
                    child: Center(child: Text(task.name, style: const TextStyle(color: Colors.grey))),
                  ),
                  child: Container(
                    width: 200,
                    height: 80,
                    color: Colors.blue,
                    child: Center(child: Text(task.name)),
                  ),
                ),
                const SizedBox(height: 100),
                // Drop target
                DragTarget<Task>(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 300,
                      height: 150,
                      color: candidateData.isNotEmpty 
                          ? Colors.green.withOpacity(0.5) 
                          : Colors.green,
                      child: const Center(
                        child: Text('Drop Here to Change Priority'),
                      ),
                    );
                  },
                  onAccept: (Task data) {
                    onAcceptCalled = true;
                    draggedTask = data;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Drop Here to Change Priority'), findsOneWidget);
      expect(onAcceptCalled, false);

      // Get the center points of the source and target
      final sourceLocation = tester.getCenter(find.text('Test Task'));
      final targetLocation = tester.getCenter(find.text('Drop Here to Change Priority'));

      // Start drag operation
      final TestGesture gesture = await tester.startGesture(sourceLocation);
      await tester.pump(); // Start the drag
      
      // Move to the target
      await gesture.moveTo(targetLocation);
      await tester.pump(); // Update during the drag
      
      // Release to drop
      await gesture.up();
      await tester.pumpAndSettle();

      // Verify the drag operation was successful
      expect(onAcceptCalled, true);
      expect(draggedTask, equals(task));
    });

    testWidgets('Drag feedback should show during drag operation', (WidgetTester tester) async {
      // Build a simple drag source
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Draggable<Task>(
                data: task,
                feedback: Material(
                  elevation: 4.0,
                  child: Container(
                    width: 200,
                    height: 80,
                    color: Colors.blue.withOpacity(0.5),
                    child: Center(child: Text('Dragging: ${task.name}')),
                  ),
                ),
                childWhenDragging: Container(
                  width: 200,
                  height: 80,
                  color: Colors.grey.withOpacity(0.3),
                  child: const Center(child: Text('Original Position')),
                ),
                child: Container(
                  width: 200,
                  height: 80,
                  color: Colors.blue,
                  child: Center(child: Text(task.name)),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Dragging: Test Task'), findsNothing);
      expect(find.text('Original Position'), findsNothing);

      // Start drag operation but don't complete it
      final dragStartLocation = tester.getCenter(find.text('Test Task'));
      final gesture = await tester.startGesture(dragStartLocation);
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();

      // During drag, both feedback and childWhenDragging should be visible
      expect(find.text('Test Task'), findsNothing); // Original is hidden
      expect(find.text('Dragging: Test Task'), findsOneWidget); // Feedback is shown
      expect(find.text('Original Position'), findsOneWidget); // Placeholder is shown

      // Complete the gesture
      await gesture.up();
      await tester.pumpAndSettle();

      // After drag ends, original should be visible again
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Dragging: Test Task'), findsNothing);
      expect(find.text('Original Position'), findsNothing);
    });
  });
}
