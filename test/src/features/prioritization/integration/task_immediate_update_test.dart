import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/eisenhower_matrix.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';

class MockPrioritizationBloc extends Mock implements PrioritizationBloc {}

void main() {
  group('Task Immediate Update Test', () {
    late MockPrioritizationBloc mockBloc;
    late Task testTask;
    final DateTime now = DateTime.now();
    
    setUp(() {
      mockBloc = MockPrioritizationBloc();
      testTask = Task(
        id: '1',
        name: 'Test Task',
        description: 'Description',
        dueDate: now,
        completed: false,
        importance: TaskImportance.high,
        createdAt: now,
        updatedAt: now,
        priority: EisenhowerCategory.unprioritized,
      );

      // Register fallback values
      registerFallbackValue(
        UpdateTaskPriority(
          task: testTask,
          newPriority: EisenhowerCategory.doNow,
        ),
      );
    });

    testWidgets('should immediately update task location after drag and drop', (WidgetTester tester) async {
      // Prepare task lists for different states
      final initialTasks = [testTask];
      
      final updatedTask = testTask.copyWith(
        priority: EisenhowerCategory.doNow,
      );
      
      final updatedTasks = [updatedTask];

      // Set up initial state
      when(() => mockBloc.state).thenReturn(
        PrioritizationLoadSuccess(
          tasks: initialTasks,
          currentFilter: null,
        ),
      );

      // Set up the mock to update state when UpdateTaskPriority is added
      when(() => mockBloc.add(any(that: isA<UpdateTaskPriority>())))
          .thenAnswer((_) {
        // Update the mock state to reflect the task's new location
        when(() => mockBloc.state).thenReturn(
          PrioritizationLoadSuccess(
            tasks: updatedTasks,
            currentFilter: null,
          ),
        );
      });

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: Scaffold(
              body: EisenhowerMatrix(
                tasks: initialTasks,
                onPriorityChanged: (task, newPriority) {
                  mockBloc.add(
                    UpdateTaskPriority(
                      task: task,
                      newPriority: newPriority,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Verify initial state - task should be in unprioritized section
      expect(find.text('Unprioritized Tasks (1)'), findsOneWidget);
      
      // Find the task to drag
      final taskItem = find.text('Test Task').last;
      expect(taskItem, findsOneWidget);
      
      // Find the target quadrant
      final doNowQuadrant = find.text('Do Now').first;
      expect(doNowQuadrant, findsOneWidget);
      
      // Perform drag and drop
      final taskLocation = tester.getCenter(taskItem);
      final targetLocation = tester.getCenter(doNowQuadrant);
      
      await tester.dragFrom(taskLocation, targetLocation - taskLocation);
      await tester.pump(); // Process the drag
      
      // Verify the bloc received the event
      verify(() => mockBloc.add(any(that: isA<UpdateTaskPriority>()))).called(1);
      
      // Update the widget tree with the new state
      await tester.pump();
      
      // Now check that the task appears in the Do Now quadrant
      // and the unprioritized section shows 0 tasks
      expect(find.text('Unprioritized Tasks (0)'), findsOneWidget); // Now always visible with (0)
      expect(find.text('Unprioritized Tasks (1)'), findsNothing);
      
      // Rebuild the widget with the updated tasks list to simulate bloc state change
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: Scaffold(
              body: EisenhowerMatrix(
                tasks: updatedTasks,
                onPriorityChanged: (task, newPriority) {
                  mockBloc.add(
                    UpdateTaskPriority(
                      task: task,
                      newPriority: newPriority,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      
      // Check that the task is now in the Do Now quadrant
      final doNowTaskText = find.descendant(
        of: find.ancestor(
          of: find.text('Do Now'),
          matching: find.byType(Column),
        ),
        matching: find.text('Test Task'),
      );
      
      expect(doNowTaskText, findsOneWidget, reason: 'Task should appear in Do Now quadrant immediately after drop');
    });
  });
}
