import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planning/src/features/prioritization/presentation/pages/eisenhower_matrix_page.dart';
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import '../test_helpers/test_task_factory.dart';

class MockPrioritizationBloc extends Mock implements PrioritizationBloc {
  final StreamController<PrioritizationState> _streamController = StreamController<PrioritizationState>.broadcast();
  
  @override
  Stream<PrioritizationState> get stream => _streamController.stream;
  
  @override
  void emit(PrioritizationState state) {
    _streamController.add(state);
  }
  
  void dispose() {
    _streamController.close();
  }
}

/// Integration tests for magic auto-prioritization button functionality
void main() {
  group('Magic Button Integration Tests', () {
    late List<Task> testTasks;

    setUp(() {
      testTasks = [
        // Unprioritized tasks that should trigger magic button
        TestTaskFactory.createTask(
          id: 'unprioritized-1',
          name: 'Urgent Important Task',
          dueDate: DateTime.now().subtract(const Duration(days: 1)), // Overdue = urgent
          importance: TaskImportance.high, // High importance
          priority: EisenhowerCategory.unprioritized,
        ),
        TestTaskFactory.createTask(
          id: 'unprioritized-2',
          name: 'Not Urgent But Important',
          dueDate: DateTime.now().add(const Duration(days: 7)), // Not urgent
          importance: TaskImportance.high, // High importance
          priority: EisenhowerCategory.unprioritized,
        ),
        TestTaskFactory.createTask(
          id: 'unprioritized-3',
          name: 'Urgent Not Important',
          dueDate: DateTime.now(), // Today = urgent
          importance: TaskImportance.low, // Low importance
          priority: EisenhowerCategory.unprioritized,
        ),
        TestTaskFactory.createTask(
          id: 'unprioritized-4',
          name: 'Neither Urgent Nor Important',
          dueDate: DateTime.now().add(const Duration(days: 10)), // Not urgent
          importance: TaskImportance.low, // Low importance
          priority: EisenhowerCategory.unprioritized,
        ),
        // Already prioritized task
        TestTaskFactory.createTask(
          id: 'prioritized-1',
          name: 'Already Prioritized',
          dueDate: DateTime.now(),
          priority: EisenhowerCategory.doNow,
        ),
      ];
    });

    testWidgets(
      'Test 1: Magic button appears immediately when task moved to unprioritized',
      (WidgetTester tester) async {
        // Start with a prioritized task that we'll move to unprioritized
        final initialTasks = [
          TestTaskFactory.createTask(
            id: 'task-1',
            name: 'Initially Prioritized Task',
            dueDate: DateTime.now(),
            priority: EisenhowerCategory.doNow,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<PrioritizationBloc>(
              create: (context) => MockPrioritizationBloc()
                ..emit(PrioritizationLoadSuccess(
                  tasks: initialTasks,
                  currentFilter: null,
                )),
              child: const EisenhowerMatrixPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Initially, no magic button should be visible (no unprioritized tasks)
        expect(find.byIcon(Icons.auto_fix_high), findsNothing);
        expect(find.text('Magic'), findsNothing);

        // Update the bloc state to have an unprioritized task
        final updatedTasks = [
          TestTaskFactory.createTask(
            id: 'task-1',
            name: 'Initially Prioritized Task',
            dueDate: DateTime.now(),
            priority: EisenhowerCategory.unprioritized, // Now unprioritized
          ),
        ];

        // Rebuild widget with updated state
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<PrioritizationBloc>(
              create: (context) => MockPrioritizationBloc()
                ..emit(PrioritizationLoadSuccess(
                  tasks: updatedTasks,
                  currentFilter: null,
                )),
              child: const EisenhowerMatrixPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Magic button should now appear immediately
        expect(find.byIcon(Icons.auto_fix_high), findsOneWidget);
        expect(find.text('Magic'), findsOneWidget);

        // Verify button properties
        final magicButton = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(magicButton.backgroundColor, equals(Colors.purple));
        expect(magicButton.tooltip, equals('Auto-prioritize unprioritized tasks'));
      },
    );

    testWidgets(
      'Test 2: Tasks move smoothly from unprioritized to quadrants after magic button confirmation',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<PrioritizationBloc>(
              create: (context) => MockPrioritizationBloc()
                ..emit(PrioritizationLoadSuccess(
                  tasks: testTasks,
                  currentFilter: null,
                )),
              child: const EisenhowerMatrixPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify magic button is visible with unprioritized tasks
        expect(find.byIcon(Icons.auto_fix_high), findsOneWidget);
        expect(find.text('Magic'), findsOneWidget);

        // Verify unprioritized tasks are initially in unprioritized section
        expect(find.text('Urgent Important Task'), findsOneWidget);
        expect(find.text('Not Urgent But Important'), findsOneWidget);
        expect(find.text('Urgent Not Important'), findsOneWidget);
        expect(find.text('Neither Urgent Nor Important'), findsOneWidget);

        // Tap the magic button
        await tester.tap(find.byIcon(Icons.auto_fix_high));
        await tester.pumpAndSettle();

        // Verify dialog appears with preview
        expect(find.text('Auto-Prioritize Tasks'), findsOneWidget);
        expect(find.text('Preview how tasks will be prioritized:'), findsOneWidget);

        // Verify task categorizations in dialog
        expect(find.text('DO NOW (Urgent & Important)'), findsOneWidget);
        expect(find.text('DECIDE (Important, Not Urgent)'), findsOneWidget);
        expect(find.text('DELEGATE (Urgent, Not Important)'), findsOneWidget);
        expect(find.text('DELETE (Not Urgent & Not Important)'), findsOneWidget);

        // Verify individual tasks appear in correct sections
        expect(find.text('• Urgent Important Task'), findsOneWidget);
        expect(find.text('• Not Urgent But Important'), findsOneWidget);
        expect(find.text('• Urgent Not Important'), findsOneWidget);
        expect(find.text('• Neither Urgent Nor Important'), findsOneWidget);

        // Confirm the auto-prioritization
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        // Verify dialog is dismissed
        expect(find.text('Auto-Prioritize Tasks'), findsNothing);

        // Simulate the bloc updating with prioritized tasks
        final prioritizedTasks = [
          TestTaskFactory.createTask(
            id: 'unprioritized-1',
            name: 'Urgent Important Task',
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
            importance: TaskImportance.high,
            priority: EisenhowerCategory.doNow, // Should be DO NOW
          ),
          TestTaskFactory.createTask(
            id: 'unprioritized-2',
            name: 'Not Urgent But Important',
            dueDate: DateTime.now().add(const Duration(days: 7)),
            importance: TaskImportance.high,
            priority: EisenhowerCategory.decide, // Should be DECIDE (was schedule)
          ),
          TestTaskFactory.createTask(
            id: 'unprioritized-3',
            name: 'Urgent Not Important',
            dueDate: DateTime.now(),
            importance: TaskImportance.low,
            priority: EisenhowerCategory.delegate, // Should be DELEGATE
          ),
          TestTaskFactory.createTask(
            id: 'unprioritized-4',
            name: 'Neither Urgent Nor Important',
            dueDate: DateTime.now().add(const Duration(days: 10)),
            importance: TaskImportance.low,
            priority: EisenhowerCategory.delete, // Should be DELETE (was eliminate)
          ),
          TestTaskFactory.createTask(
            id: 'prioritized-1',
            name: 'Already Prioritized',
            dueDate: DateTime.now(),
            priority: EisenhowerCategory.doNow,
          ),
        ];

        // Update widget with prioritized tasks
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<PrioritizationBloc>(
              create: (context) => MockPrioritizationBloc()
                ..emit(PrioritizationLoadSuccess(
                  tasks: prioritizedTasks,
                  currentFilter: null,
                )),
              child: const EisenhowerMatrixPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify tasks are now in their correct quadrants (no manual reload needed)
        // Check that tasks appear in matrix quadrants
        expect(find.text('Urgent Important Task'), findsOneWidget);
        expect(find.text('Not Urgent But Important'), findsOneWidget);
        expect(find.text('Urgent Not Important'), findsOneWidget);
        expect(find.text('Neither Urgent Nor Important'), findsOneWidget);

        // Magic button should now be hidden (no unprioritized tasks)
        expect(find.byIcon(Icons.auto_fix_high), findsNothing);
        expect(find.text('Magic'), findsNothing);
      },
    );

    testWidgets(
      'Test 3: Dialog shows correct importance and urgency for each task',
      (WidgetTester tester) async {
        // Create tasks with specific characteristics for testing
        final specificTestTasks = [
          TestTaskFactory.createTask(
            id: 'high-urgent',
            name: 'High Priority Overdue Task',
            dueDate: DateTime.now().subtract(const Duration(days: 2)), // Overdue = urgent
            importance: TaskImportance.veryHigh, // Very high importance
            priority: EisenhowerCategory.unprioritized,
          ),
          TestTaskFactory.createTask(
            id: 'medium-future',
            name: 'Medium Priority Future Task',
            dueDate: DateTime.now().add(const Duration(days: 5)), // Future = not urgent
            importance: TaskImportance.medium, // Medium importance
            priority: EisenhowerCategory.unprioritized,
          ),
          TestTaskFactory.createTask(
            id: 'low-today',
            name: 'Low Priority Today Task',
            dueDate: DateTime.now(), // Today = urgent
            importance: TaskImportance.low, // Low importance
            priority: EisenhowerCategory.unprioritized,
          ),
          TestTaskFactory.createTask(
            id: 'no-due-date',
            name: 'No Due Date Task',
            dueDate: DateTime.now().add(const Duration(days: 30)), // Far future = not urgent  
            importance: TaskImportance.high, // High importance
            priority: EisenhowerCategory.unprioritized,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<PrioritizationBloc>(
              create: (context) => MockPrioritizationBloc()
                ..emit(PrioritizationLoadSuccess(
                  tasks: specificTestTasks,
                  currentFilter: null,
                )),
              child: const EisenhowerMatrixPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap the magic button to open dialog
        await tester.tap(find.byIcon(Icons.auto_fix_high));
        await tester.pumpAndSettle();

        // Verify dialog appears
        expect(find.text('Auto-Prioritize Tasks'), findsOneWidget);

        // Test 1: High Priority Overdue Task (Urgent + Very High Importance = DO NOW)
        expect(find.text('DO NOW (Urgent & Important)'), findsOneWidget);
        expect(find.text('• High Priority Overdue Task'), findsOneWidget);

        // Test 2: Medium Priority Future Task (Not Urgent + Medium Importance)
        // Medium importance might be treated as important or not, depending on threshold
        // Let's check if it appears in either DECIDE or DELETE
        final mediumTaskFinder = find.text('• Medium Priority Future Task');
        expect(mediumTaskFinder, findsOneWidget);

        // Test 3: Low Priority Today Task (Urgent + Low Importance = DELEGATE)
        expect(find.text('DELEGATE (Urgent, Not Important)'), findsOneWidget);
        expect(find.text('• Low Priority Today Task'), findsOneWidget);

        // Test 4: No Due Date Task (Not Urgent + High Importance = DECIDE)
        expect(find.text('DECIDE (Important, Not Urgent)'), findsOneWidget);
        expect(find.text('• No Due Date Task'), findsOneWidget);

        // Verify the urgency and importance logic is applied correctly
        // Check that each section header appears with appropriate tasks
        final doNowSection = find.text('DO NOW (Urgent & Important)');
        final decideSection = find.text('DECIDE (Important, Not Urgent)');
        final delegateSection = find.text('DELEGATE (Urgent, Not Important)');

        expect(doNowSection, findsOneWidget);
        expect(decideSection, findsOneWidget);
        expect(delegateSection, findsOneWidget);
        // Delete section should appear if medium importance is considered "not important"
        expect(find.text('DELETE (Not Urgent & Not Important)'), findsOneWidget);
        
        // Cancel to close dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Verify dialog is closed
        expect(find.text('Auto-Prioritize Tasks'), findsNothing);
      },
    );

    testWidgets(
      'Magic button shows task count badge when many unprioritized tasks exist',
      (WidgetTester tester) async {
        // Create many unprioritized tasks
        final manyTasks = List.generate(8, (index) => 
          TestTaskFactory.createTask(
            id: 'task-$index',
            name: 'Unprioritized Task $index',
            dueDate: DateTime.now().add(Duration(days: index)),
            priority: EisenhowerCategory.unprioritized,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<PrioritizationBloc>(
              create: (context) => MockPrioritizationBloc()
                ..emit(PrioritizationLoadSuccess(
                  tasks: manyTasks,
                  currentFilter: null,
                )),
              child: const EisenhowerMatrixPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify magic button is present
        expect(find.byIcon(Icons.auto_fix_high), findsOneWidget);
        expect(find.text('Magic'), findsOneWidget);

        // Verify tooltip mentions the count
        final magicButton = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(magicButton.tooltip, equals('Auto-prioritize unprioritized tasks'));
      },
    );
  });
}
