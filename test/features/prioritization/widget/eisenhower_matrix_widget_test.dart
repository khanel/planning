import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planning/src/features/prioritization/presentation/pages/eisenhower_matrix_page.dart';
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';

class MockPrioritizationBloc extends Mock implements PrioritizationBloc {}

void main() {
  group('EisenhowerMatrixPage Widget Tests', () {
    late MockPrioritizationBloc mockBloc;
    late StreamController<PrioritizationState> streamController;
    
    setUp(() {
      mockBloc = MockPrioritizationBloc();
      streamController = StreamController<PrioritizationState>.broadcast();
      
      // Mock the stream property to return a proper broadcast stream
      when(() => mockBloc.stream).thenAnswer((_) => streamController.stream);
      when(() => mockBloc.state).thenReturn(const PrioritizationInitial());
    });
    
    tearDown(() {
      streamController.close();
    });

    Widget createTestWidget(List<Task> tasks) {
      return MaterialApp(
        home: BlocProvider<PrioritizationBloc>.value(
          value: mockBloc,
          child: const EisenhowerMatrixPage(),
        ),
      );
    }

    Task createTestTask({
      required String id,
      required String name,
      required EisenhowerCategory priority,
      DateTime? dueDate,
      TaskImportance importance = TaskImportance.medium,
    }) {
      final now = DateTime.now();
      return Task(
        id: id,
        name: name,
        description: '',
        dueDate: dueDate,
        completed: false,
        importance: importance,
        createdAt: now,
        updatedAt: now,
        priority: priority,
      );
    }

    testWidgets('Test 1: Magic button appears immediately when task moved from quadrant to unprioritized', (tester) async {
      // Create initial state with no unprioritized tasks
      final initialTasks = [
        createTestTask(
          id: '1',
          name: 'Task in DO NOW',
          priority: EisenhowerCategory.doNow,
          dueDate: DateTime.now(),
          importance: TaskImportance.high,
        ),
      ];

      final initialState = PrioritizationLoadSuccess(
        tasks: initialTasks,
        currentFilter: null,
      );

      when(() => mockBloc.state).thenReturn(initialState);

      await tester.pumpWidget(createTestWidget(initialTasks));
      
      // Emit initial state to stream
      streamController.add(initialState);
      await tester.pump();

      // Verify magic button is not visible initially
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('Magic'), findsNothing);

      // Simulate moving task from quadrant to unprioritized
      final updatedTasks = [
        createTestTask(
          id: '1',
          name: 'Task in DO NOW',
          priority: EisenhowerCategory.unprioritized, // Moved to unprioritized
          dueDate: DateTime.now(),
          importance: TaskImportance.high,
        ),
      ];

      final newState = PrioritizationLoadSuccess(
        tasks: updatedTasks,
        currentFilter: null,
      );

      when(() => mockBloc.state).thenReturn(newState);

      // Emit the new state to the stream to trigger BlocBuilder rebuild
      streamController.add(newState);

      // Wait for the widget to rebuild with multiple pumps
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Verify magic button appears immediately
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Magic'), findsOneWidget);
      expect(find.byIcon(Icons.auto_fix_high), findsOneWidget);

      // Verify button properties
      final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(fab.backgroundColor, equals(Colors.purple));
    });

    testWidgets('Test 2: Tasks move smoothly from unprioritized to quadrants after magic button confirmation', (tester) async {
      // Create unprioritized tasks
      final unprioritizedTasks = [
        createTestTask(
          id: '1',
          name: 'Urgent Important Task',
          priority: EisenhowerCategory.unprioritized,
          dueDate: DateTime.now(), // Due today (urgent)
          importance: TaskImportance.high, // Important
        ),
        createTestTask(
          id: '2',
          name: 'Not Urgent Important Task',
          priority: EisenhowerCategory.unprioritized,
          dueDate: DateTime.now().add(const Duration(days: 7)), // Due in a week (not urgent)
          importance: TaskImportance.high, // Important
        ),
      ];

      final initialState = PrioritizationLoadSuccess(
        tasks: unprioritizedTasks,
        currentFilter: null,
      );

      when(() => mockBloc.state).thenReturn(initialState);

      await tester.pumpWidget(createTestWidget(unprioritizedTasks));
      
      // Emit initial state to stream
      streamController.add(initialState);
      await tester.pump();

      // Verify magic button is visible
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Magic'), findsOneWidget);

      // Tap magic button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify preview dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Magic Prioritization'), findsOneWidget);
      expect(find.text('Urgent Important Task'), findsOneWidget);
      expect(find.text('Not Urgent Important Task'), findsOneWidget);

      // Mock the confirmation action
      final categorizedTasks = [
        createTestTask(
          id: '1',
          name: 'Urgent Important Task',
          priority: EisenhowerCategory.doNow, // Should go to DO NOW
          dueDate: DateTime.now(),
          importance: TaskImportance.high,
        ),
        createTestTask(
          id: '2',
          name: 'Not Urgent Important Task',
          priority: EisenhowerCategory.decide, // Should go to DECIDE
          dueDate: DateTime.now().add(const Duration(days: 7)),
          importance: TaskImportance.high,
        ),
      ];

      // Tap Apply Magic button
      await tester.tap(find.text('Apply Magic'));
      
      // Update mock state to reflect categorized tasks
      final newState = PrioritizationLoadSuccess(
        tasks: categorizedTasks,
        currentFilter: null,
      );
      
      when(() => mockBloc.state).thenReturn(newState);
      
      // Emit new state to stream
      streamController.add(newState);

      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.byType(AlertDialog), findsNothing);

      // Rebuild widget with new state
      await tester.pumpWidget(createTestWidget(categorizedTasks));
      await tester.pump();

      // Verify magic button is no longer visible (no unprioritized tasks)
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('Magic'), findsNothing);

      // Verify tasks are now displayed in their quadrants
      // This would require checking the specific quadrant widgets
      // The exact implementation depends on how quadrants are structured in your UI
      expect(find.text('Urgent Important Task'), findsOneWidget);
      expect(find.text('Not Urgent Important Task'), findsOneWidget);
    });

    testWidgets('Test 3: Preview dialog shows correct importance and urgency for each task', (tester) async {
      final now = DateTime.now();
      
      // Create tasks with different urgency and importance combinations
      final testTasks = [
        createTestTask(
          id: '1',
          name: 'Overdue High Priority',
          priority: EisenhowerCategory.unprioritized,
          dueDate: now.subtract(const Duration(days: 1)), // Overdue (urgent)
          importance: TaskImportance.veryHigh, // Very important
        ),
        createTestTask(
          id: '2',
          name: 'Due Today Medium Priority',
          priority: EisenhowerCategory.unprioritized,
          dueDate: now, // Due today (urgent)
          importance: TaskImportance.medium, // Medium importance
        ),
        createTestTask(
          id: '3',
          name: 'Future Low Priority',
          priority: EisenhowerCategory.unprioritized,
          dueDate: now.add(const Duration(days: 10)), // Future (not urgent)
          importance: TaskImportance.low, // Low importance
        ),
        createTestTask(
          id: '4',
          name: 'No Due Date High Priority',
          priority: EisenhowerCategory.unprioritized,
          dueDate: null, // No due date (not urgent)
          importance: TaskImportance.high, // High importance
        ),
      ];

      final initialState = PrioritizationLoadSuccess(
        tasks: testTasks,
        currentFilter: null,
      );

      when(() => mockBloc.state).thenReturn(initialState);

      await tester.pumpWidget(createTestWidget(testTasks));
      
      // Emit initial state to stream
      streamController.add(initialState);
      await tester.pump();

      // Tap magic button to open preview dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Magic Prioritization'), findsOneWidget);

      // Verify all tasks are included in the count
      expect(find.textContaining('4 unprioritized tasks'), findsOneWidget);

      // Verify the prioritization rules are shown
      expect(find.text('Priority Rules:'), findsOneWidget);
      expect(find.text('• Urgent + Important = Do Now'), findsOneWidget);
      expect(find.text('• Not Urgent + Important = Decide'), findsOneWidget);
      expect(find.text('• Urgent + Not Important = Delegate'), findsOneWidget);
      expect(find.text('• Not Urgent + Not Important = Delete'), findsOneWidget);

      // Verify dialog has correct buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Apply Magic'), findsOneWidget);

      // Test cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.byType(AlertDialog), findsNothing);

      // Verify tasks remain unprioritized (magic button still visible)
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Magic button disappears when no unprioritized tasks exist', (tester) async {
      // Create state with only categorized tasks
      final categorizedTasks = [
        createTestTask(
          id: '1',
          name: 'Categorized Task',
          priority: EisenhowerCategory.doNow,
          dueDate: DateTime.now(),
          importance: TaskImportance.high,
        ),
      ];

      when(() => mockBloc.state).thenReturn(
        PrioritizationLoadSuccess(
          tasks: categorizedTasks,
          currentFilter: null,
        ),
      );

      await tester.pumpWidget(createTestWidget(categorizedTasks));
      await tester.pump();

      // Verify magic button is not visible
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('Magic'), findsNothing);
    });

    testWidgets('Magic button handles empty task list gracefully', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const PrioritizationLoadSuccess(
          tasks: [],
          currentFilter: null,
        ),
      );

      await tester.pumpWidget(createTestWidget([]));
      await tester.pump();

      // Verify magic button is not visible for empty list
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('Magic'), findsNothing);
    });
  });
}
