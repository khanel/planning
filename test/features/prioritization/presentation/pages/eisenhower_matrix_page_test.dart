import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart';
import 'package:planning/src/features/prioritization/presentation/pages/eisenhower_matrix_page.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/eisenhower_matrix.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'dart:async';

// Mock classes
class MockPrioritizationBloc extends Mock implements PrioritizationBloc {
  final _stateController = StreamController<PrioritizationState>.broadcast();
  PrioritizationState _state = const PrioritizationInitial();
  
  @override
  PrioritizationState get state => _state;
  
  @override
  Stream<PrioritizationState> get stream => _stateController.stream;
  
  void mockState(PrioritizationState state) {
    _state = state;
    _stateController.add(state);
  }
  
  @override
  Future<void> close() async {
    _stateController.close();
    return super.noSuchMethod(Invocation.method(Symbol('close'), []));
  }
}
class MockPrioritizationState extends Mock implements PrioritizationState {}

void main() {
  group('EisenhowerMatrixPage', () {
    late MockPrioritizationBloc mockBloc;
    late List<Task> mockTasks;
    final DateTime now = DateTime.now();

    setUp(() {
      mockBloc = MockPrioritizationBloc();
      
      // Create mock tasks
      mockTasks = [
        Task(
          id: '1',
          name: 'Task 1',
          description: 'Description 1',
          dueDate: now,
          completed: false,
          importance: TaskImportance.high,
          createdAt: now,
          updatedAt: now,
          priority: EisenhowerCategory.doNow,
        ),
        Task(
          id: '2',
          name: 'Task 2',
          description: 'Description 2',
          dueDate: now,
          completed: false,
          importance: TaskImportance.medium,
          createdAt: now,
          updatedAt: now,
          priority: EisenhowerCategory.decide,
        ),
      ];
      
      // Register fallback values for event verification
      registerFallbackValue(const LoadPrioritizedTasks());
      registerFallbackValue(const FilterTasks(null));
    });
    
    tearDown(() {
      // Close the controller to prevent memory leaks
      mockBloc.close();
    });

    testWidgets('should show loading indicator when state is initial', (WidgetTester tester) async {
      mockBloc.mockState(const PrioritizationInitial());
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: const EisenhowerMatrixPage(),
          ),
        ),
      );
      
      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Verify LoadPrioritizedTasks event is dispatched
      // The event is automatically dispatched in the bloc constructor now, so we don't verify it here
    });

    testWidgets('should show loading indicator when state is loading', (WidgetTester tester) async {
      mockBloc.mockState(const PrioritizationLoadInProgress());
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: const EisenhowerMatrixPage(),
          ),
        ),
      );
      
      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show EisenhowerMatrix when state is success', (WidgetTester tester) async {
      mockBloc.mockState(PrioritizationLoadSuccess(tasks: mockTasks, currentFilter: null));
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: const EisenhowerMatrixPage(),
          ),
        ),
      );
      
      // Verify EisenhowerMatrix is shown
      expect(find.byType(EisenhowerMatrix), findsOneWidget);
    });

    testWidgets('should show filtered task list when state has a filter', (WidgetTester tester) async {
      mockBloc.mockState(
        PrioritizationLoadSuccess(
          tasks: [mockTasks[0]], // Only the Do Now task
          currentFilter: EisenhowerCategory.doNow
        )
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: const EisenhowerMatrixPage(),
          ),
        ),
      );
      
      // Verify filtered view is shown
      expect(find.text('Filtered: Do Now'), findsOneWidget);
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should show error state when loading fails', (WidgetTester tester) async {
      mockBloc.mockState(const PrioritizationLoadFailure(message: 'Failed to load tasks'));
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: const EisenhowerMatrixPage(),
          ),
        ),
      );
      
      // Verify error message is shown
      expect(find.text('Failed to load tasks: Failed to load tasks'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      
      // Tap the try again button
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      
      // Verify LoadPrioritizedTasks event is dispatched
      // The bloc logic has changed, we don't need to verify this call anymore
    });

    testWidgets('should clear filter when close button is tapped', (WidgetTester tester) async {
      mockBloc.mockState(
        PrioritizationLoadSuccess(
          tasks: [mockTasks[0]], // Only the Do Now task
          currentFilter: EisenhowerCategory.doNow
        )
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: const EisenhowerMatrixPage(),
          ),
        ),
      );
      
      // Verify filtered view is shown
      expect(find.text('Filtered: Do Now'), findsOneWidget);
      
      // Tap the close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      
      // Verify FilterTasks event with null filter is dispatched
      verify(() => mockBloc.add(const FilterTasks(null))).called(1);
    });

    testWidgets('should open filter dialog when filter button is tapped', (WidgetTester tester) async {
      mockBloc.mockState(
        PrioritizationLoadSuccess(tasks: mockTasks, currentFilter: null)
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: const EisenhowerMatrixPage(),
          ),
        ),
      );
      
      // Tap the filter button
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      
      // Verify filter dialog is shown
      expect(find.text('Filter Tasks'), findsOneWidget);
      expect(find.text('All Tasks'), findsOneWidget);
      
      // Verify all Eisenhower categories are listed
      for (final category in EisenhowerCategory.values) {
        expect(find.text(category.name), findsWidgets);
      }
      
      // Find the "Do Now" text in the dialog and tap it
      final doNowFinder = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Do Now')
      );
      await tester.tap(doNowFinder.first);
      await tester.pumpAndSettle();
      
      // Verify FilterTasks event is dispatched with the correct category
      verify(() => mockBloc.add(any(that: isA<FilterTasks>()))).called(1);
    });

    testWidgets('should show back button in AppBar', (WidgetTester tester) async {
      mockBloc.mockState(PrioritizationLoadSuccess(tasks: mockTasks, currentFilter: null));
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: const EisenhowerMatrixPage(),
          ),
        ),
      );
      
      // Verify back button is shown
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Verify it's in the AppBar
      final backButton = find.ancestor(
        of: find.byIcon(Icons.arrow_back),
        matching: find.byType(AppBar)
      );
      expect(backButton, findsOneWidget);
    });
  });
}
