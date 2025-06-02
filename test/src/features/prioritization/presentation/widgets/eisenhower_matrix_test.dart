import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/eisenhower_matrix.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'testable_eisenhower_matrix.dart';

void main() {
  group('EisenhowerMatrix Widget', () {
    final DateTime now = DateTime.now();
    late List<Task> tasks;
    
    setUp(() {
      tasks = [
        // Do Now task
        Task(
          id: '1',
          name: 'Do Now Task',
          description: 'Description 1',
          dueDate: now.subtract(const Duration(days: 1)), // Yesterday (urgent)
          completed: false,
          importance: TaskImportance.high, // Important
          createdAt: now,
          updatedAt: now,
          priority: EisenhowerCategory.doNow,
        ),
        // Decide task
        Task(
          id: '2',
          name: 'Decide Task',
          description: 'Description 2',
          dueDate: now.add(const Duration(days: 7)), // Not urgent
          completed: false,
          importance: TaskImportance.high, // Important
          createdAt: now,
          updatedAt: now,
          priority: EisenhowerCategory.decide,
        ),
        // Delegate task
        Task(
          id: '3',
          name: 'Delegate Task',
          description: 'Description 3',
          dueDate: now.subtract(const Duration(days: 1)), // Urgent
          completed: false,
          importance: TaskImportance.low, // Not important
          createdAt: now,
          updatedAt: now,
          priority: EisenhowerCategory.delegate,
        ),
        // Delete task
        Task(
          id: '4',
          name: 'Delete Task',
          description: 'Description 4',
          dueDate: now.add(const Duration(days: 7)), // Not urgent
          completed: false,
          importance: TaskImportance.low, // Not important
          createdAt: now,
          updatedAt: now,
          priority: EisenhowerCategory.delete,
        ),
        // Unprioritized task
        Task(
          id: '5',
          name: 'Unprioritized Task',
          description: 'Description 5',
          dueDate: now.add(const Duration(days: 3)),
          completed: false,
          importance: TaskImportance.medium,
          createdAt: now,
          updatedAt: now,
          priority: EisenhowerCategory.unprioritized,
        ),
      ];
    });
    
    testWidgets('should display all axis labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: tasks,
            ),
          ),
        ),
      );
      
      // Check for axis labels
      expect(find.text('URGENT'), findsOneWidget);
      expect(find.text('NOT URGENT'), findsOneWidget);
      expect(find.text('IMPORTANT'), findsOneWidget);
      expect(find.text('NOT IMPORTANT'), findsOneWidget);
    });
    
    testWidgets('should display all quadrants with correct titles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: tasks,
            ),
          ),
        ),
      );
      
      // Check for quadrant titles
      expect(find.text('Do Now'), findsOneWidget);
      expect(find.text('Decide'), findsOneWidget);
      expect(find.text('Delegate'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
    
    testWidgets('should display unprioritized tasks section when there are unprioritized tasks', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: tasks,
            ),
          ),
        ),
      );
      
      // Check for unprioritized section
      expect(find.text('Unprioritized Tasks (1)'), findsOneWidget);
      expect(find.text('Unprioritized Task'), findsOneWidget);
    });
    
    testWidgets('should display empty unprioritized tasks section when there are no unprioritized tasks', 
        (WidgetTester tester) async {
      // Remove the unprioritized task
      final tasksWithoutUnprioritized = tasks.where(
        (task) => task.priority != EisenhowerCategory.unprioritized
      ).toList();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EisenhowerMatrix(
              tasks: tasksWithoutUnprioritized,
            ),
          ),
        ),
      );
      
      // Should find the unprioritized section with (0) tasks
      expect(find.text('Unprioritized Tasks (0)'), findsOneWidget);
      // Should find the empty state message
      expect(find.text('Drag tasks here to unprioritize them'), findsOneWidget);
    });
    
    testWidgets('should format dates correctly in unprioritized tasks', 
        (WidgetTester tester) async {
      // Create tasks with different dates
      final overdueTask = Task(
        id: '6',
        name: 'Overdue Task',
        description: 'Description',
        dueDate: now.subtract(const Duration(days: 2)), // 2 days ago
        completed: false,
        importance: TaskImportance.medium,
        createdAt: now,
        updatedAt: now,
        priority: EisenhowerCategory.unprioritized,
      );
      
      final todayTask = Task(
        id: '7',
        name: 'Today Task',
        description: 'Description',
        dueDate: DateTime(now.year, now.month, now.day), // Today
        completed: false,
        importance: TaskImportance.medium,
        createdAt: now,
        updatedAt: now,
        priority: EisenhowerCategory.unprioritized,
      );
      
      final tomorrowTask = Task(
        id: '8',
        name: 'Tomorrow Task',
        description: 'Description',
        dueDate: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)), // Tomorrow
        completed: false,
        importance: TaskImportance.medium,
        createdAt: now,
        updatedAt: now,
        priority: EisenhowerCategory.unprioritized,
      );
      
      final tasksWithDifferentDates = [overdueTask, todayTask, tomorrowTask];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestableEisenhowerMatrix(
              tasks: tasksWithDifferentDates,
            ),
          ),
        ),
      );
      
      // Check for formatted dates
      expect(find.text('Due: Overdue'), findsOneWidget);
      expect(find.text('Due: Today'), findsOneWidget);
      expect(find.text('Due: Tomorrow'), findsOneWidget);
    });
  });
}
