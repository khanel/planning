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
            ),
          ),
        ),
      );
      
      expect(find.text('Do Now'), findsOneWidget);
      expect(find.text('Important and urgent tasks that require immediate attention'), findsOneWidget);
      expect(find.text('(0)'), findsOneWidget); // Task count should be 0
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
            ),
          ),
        ),
      );
      
      expect(find.text('Do Now'), findsOneWidget);
      expect(find.text('(1)'), findsOneWidget); // Task count should be 1
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
  });
}
