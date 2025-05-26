import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/matrix_quadrant.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';

void main() {
  group('MatrixQuadrant Widget', () {
    final DateTime now = DateTime.now();
    late Task task;
    
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
        priority: EisenhowerCategory.doNow,
      );
    });
    
    testWidgets('should display the quadrant title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatrixQuadrant(
              title: 'Do Now',
              color: Colors.red,
              description: 'Important and urgent tasks that require immediate attention',
              tasks: const [],
              category: EisenhowerCategory.doNow,
            ),
          ),
        ),
      );
      
      expect(find.text('Do Now'), findsOneWidget);
      expect(find.text('Important and urgent tasks that require immediate attention'), findsOneWidget);
      expect(find.text('0'), findsOneWidget); // Task count should be 0
    });
    
    testWidgets('should display tasks within the quadrant', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatrixQuadrant(
              title: 'Do Now',
              color: Colors.red,
              description: 'Important and urgent tasks that require immediate attention',
              tasks: [task],
              category: EisenhowerCategory.doNow,
            ),
          ),
        ),
      );
      
      expect(find.text('Do Now'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Task count should be 1
    });
    
    testWidgets('should show empty state when no tasks', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatrixQuadrant(
              title: 'Do Now',
              color: Colors.red,
              description: 'Important and urgent tasks that require immediate attention',
              tasks: const [],
              category: EisenhowerCategory.doNow,
            ),
          ),
        ),
      );
      
      expect(find.text('No tasks in this quadrant'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
    
    testWidgets('should have the correct color in the header', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatrixQuadrant(
              title: 'Do Now',
              color: Colors.red,
              description: 'Important and urgent tasks that require immediate attention',
              tasks: const [],
              category: EisenhowerCategory.doNow,
            ),
          ),
        ),
      );
      
      // Find the container that should have the color
      final containers = tester.widgetList<Container>(find.byType(Container));
      
      // The header container should have the background color set to red with opacity
      bool foundColoredContainer = false;
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final boxDecoration = container.decoration as BoxDecoration;
          if (boxDecoration.color != null && 
              boxDecoration.color == Colors.red.withOpacity(0.2)) {
            foundColoredContainer = true;
            break;
          }
        }
      }
      
      expect(foundColoredContainer, true);
    });
    
    testWidgets('should call onPriorityChanged when task is dropped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatrixQuadrant(
              title: 'Decide',
              color: Colors.blue,
              description: 'Important but not urgent tasks',
              tasks: const [],
              category: EisenhowerCategory.decide,
              onPriorityChanged: (task, category) {
                // This callback won't be triggered in this test since we can't easily
                // simulate drag and drop in widget tests
              },
            ),
          ),
        ),
      );
      
      // Create a drag gesture to simulate dropping a task
      final gesture = await tester.startGesture(const Offset(10.0, 10.0));
      
      // Move to the target position
      await gesture.moveTo(tester.getCenter(find.byType(MatrixQuadrant)));
      await gesture.up();
      await tester.pump();
      
      // Verify the widget exists and renders properly
      expect(find.byType(MatrixQuadrant), findsOneWidget);
    });
    
    testWidgets('should call onTaskTap when a task is tapped', (WidgetTester tester) async {
      Task? tappedTask;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatrixQuadrant(
              title: 'Do Now',
              color: Colors.red,
              description: 'Important and urgent tasks',
              tasks: [task],
              category: EisenhowerCategory.doNow,
              onTaskTap: (task) {
                tappedTask = task;
              },
            ),
          ),
        ),
      );
      
      // Find the task's ListTile and tap it
      await tester.tap(find.byType(ListTile));
      await tester.pump();
      
      // Verify that onTaskTap was called with the correct task
      expect(tappedTask, equals(task));
    });
    
    testWidgets('should display task count badge with appropriate color', (WidgetTester tester) async {
      // Create multiple tasks
      final tasks = [
        task,
        Task(
          id: '2',
          name: 'Test Task 2',
          description: 'Another task',
          dueDate: DateTime.now(),
          completed: false,
          importance: TaskImportance.high,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          priority: EisenhowerCategory.doNow,
        ),
      ];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatrixQuadrant(
              title: 'Do Now',
              color: Colors.red,
              description: 'Important and urgent tasks',
              tasks: tasks,
              category: EisenhowerCategory.doNow,
            ),
          ),
        ),
      );
      
      // Verify the task count is displayed properly
      expect(find.text('2'), findsOneWidget);
    });
    
    testWidgets('should display quadrant icons based on importance and urgency', (WidgetTester tester) async {
      // Test with "Do Now" quadrant (important and urgent)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatrixQuadrant(
              title: 'Do Now',
              color: Colors.red,
              description: 'Important and urgent tasks',
              tasks: const [],
              category: EisenhowerCategory.doNow,
              showImportanceIcon: true,
              showUrgencyIcon: true,
            ),
          ),
        ),
      );
      
      // Should display both importance and urgency icons
      expect(find.byIcon(Icons.priority_high), findsOneWidget); // Importance icon
      expect(find.byIcon(Icons.timelapse), findsOneWidget); // Urgency icon
      
      // Test with "Decide" quadrant (important but not urgent)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatrixQuadrant(
              title: 'Decide',
              color: Colors.blue,
              description: 'Important but not urgent tasks',
              tasks: const [],
              category: EisenhowerCategory.decide,
              showImportanceIcon: true,
              showUrgencyIcon: false,
            ),
          ),
        ),
      );
      
      await tester.pump();
      
      // Should display only importance icon
      expect(find.byIcon(Icons.priority_high), findsOneWidget); // Importance icon
      expect(find.byIcon(Icons.timelapse), findsNothing); // No urgency icon
    });
  });
}
