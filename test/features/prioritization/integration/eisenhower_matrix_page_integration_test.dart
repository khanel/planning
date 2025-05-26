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

class MockPrioritizationEvent extends Mock implements PrioritizationEvent {}
class MockPrioritizationState extends Mock implements PrioritizationState {}

void main() {
  group('EisenhowerMatrixPage Integration Tests', () {
    late MockPrioritizationBloc mockBloc;
    late List<Task> mockTasks;
    final DateTime now = DateTime.now();

    setUp(() {
      mockBloc = MockPrioritizationBloc();

      // Create a list of tasks for testing
      mockTasks = [
        // Do Now task
        Task(
          id: '1',
          name: 'Do Now Task',
          description: 'Description 1',
          dueDate: now.subtract(const Duration(days: 1)), 
          completed: false,
          importance: TaskImportance.high,
          createdAt: now,
          updatedAt: now,
          priority: EisenhowerCategory.doNow,
        ),
        // Decide task
        Task(
          id: '2',
          name: 'Decide Task',
          description: 'Description 2',
          dueDate: now.add(const Duration(days: 7)),
          completed: false,
          importance: TaskImportance.high,
          createdAt: now,
          updatedAt: now,
          priority: EisenhowerCategory.decide,
        ),
        // Delegate task
        Task(
          id: '3',
          name: 'Delegate Task',
          description: 'Description 3',
          dueDate: now.subtract(const Duration(days: 1)),
          completed: false,
          importance: TaskImportance.low,
          createdAt: now,
          updatedAt: now,
          priority: EisenhowerCategory.delegate,
        ),
        // Delete task
        Task(
          id: '4',
          name: 'Delete Task',
          description: 'Description 4',
          dueDate: now.add(const Duration(days: 7)),
          completed: false,
          importance: TaskImportance.low,
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

      // Register fallback values
      registerFallbackValue(const LoadPrioritizedTasks());
      registerFallbackValue(const FilterTasks(null));
    });

    tearDown(() {
      // Close the controller to prevent memory leaks
      mockBloc.close();
    });

    testWidgets('should show loading indicator initially and then load tasks', 
        (WidgetTester tester) async {
      // Set up the initial state
      mockBloc.mockState(const PrioritizationInitial());
      
      // Set up the response when LoadPrioritizedTasks is added
      when(() => mockBloc.add(any(that: isA<LoadPrioritizedTasks>())))
          .thenAnswer((_) {
        // First transition to loading state
        mockBloc.mockState(const PrioritizationLoadInProgress());
        
        // Then to success state after a small delay
        Future.microtask(() {
          mockBloc.mockState(PrioritizationLoadSuccess(
            tasks: mockTasks,
            currentFilter: null,
          ));
        });
      });
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: const EisenhowerMatrixPage(),
          ),
        ),
      );
      
      // Verify that loading indicator is shown initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Verify that LoadPrioritizedTasks event is dispatched
      verify(() => mockBloc.add(const LoadPrioritizedTasks())).called(1);
      
      // Wait for the state to change to success
      await tester.pump(); // Process initial frame
      await tester.pump(); // Process microtask queue
      await tester.pumpAndSettle(); // Wait for any animations to complete
      
      // Verify that the Eisenhower Matrix is shown
      expect(find.byType(EisenhowerMatrix), findsOneWidget);
    });

    testWidgets('should show error state when loading fails', 
        (WidgetTester tester) async {
      // Set up the initial state
      mockBloc.mockState(const PrioritizationInitial());
      
      // Set up the response when LoadPrioritizedTasks is added
      when(() => mockBloc.add(any(that: isA<LoadPrioritizedTasks>())))
          .thenAnswer((_) {
        // First transition to loading state
        mockBloc.mockState(const PrioritizationLoadInProgress());
        
        // Then to failure state after a small delay
        Future.microtask(() {
          mockBloc.mockState(const PrioritizationLoadFailure(
            message: 'Error loading tasks'
          ));
        });
      });
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: const EisenhowerMatrixPage(),
          ),
        ),
      );
      
      // Verify that loading indicator is shown initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for the state to change to failure
      await tester.pump(); // Process initial frame
      await tester.pump(); // Process microtask queue
      await tester.pumpAndSettle(); // Wait for any animations to complete
      
      // Verify that error message is shown
      expect(find.text('Failed to load tasks: Error loading tasks'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      
      // Reset the mock counter for the next verification
      reset(mockBloc);
      when(() => mockBloc.add(any(that: isA<LoadPrioritizedTasks>()))).thenAnswer((_) {});
      
      // Tap the try again button
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      
      // Verify that LoadPrioritizedTasks event is dispatched again
      verify(() => mockBloc.add(const LoadPrioritizedTasks())).called(1);
    });

    testWidgets('should filter tasks when filter is applied', 
        (WidgetTester tester) async {
      // Mock the bloc to emit success state with filter
      final successState = PrioritizationLoadSuccess(
        tasks: mockTasks.where((t) => t.priority == EisenhowerCategory.doNow).toList(),
        currentFilter: EisenhowerCategory.doNow,
      );
      
      mockBloc.mockState(successState);
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: const EisenhowerMatrixPage(),
          ),
        ),
      );
      
      // Verify that filtered view is shown
      expect(find.text('Filtered: Do Now'), findsOneWidget);
      expect(find.text('Do Now Task'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      
      // Tap the clear filter button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      
      // Verify that FilterTasks event with null is dispatched
      verify(() => mockBloc.add(const FilterTasks(null))).called(1);
    });

    testWidgets('should open filter dialog when filter button is tapped', 
        (WidgetTester tester) async {
      // Mock the bloc to emit success state
      final successState = PrioritizationLoadSuccess(
        tasks: mockTasks,
        currentFilter: null,
      );
      
      mockBloc.mockState(successState);
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PrioritizationBloc>.value(
            value: mockBloc,
            child: const EisenhowerMatrixPage(),
          ),
        ),
      );
      
      // Tap the filter button in the app bar
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle(); // Wait for dialog animation
      
      // Verify that filter dialog is shown
      expect(find.text('Filter Tasks'), findsOneWidget);
      expect(find.text('All Tasks'), findsOneWidget);
      
      // Verify that all Eisenhower categories are listed
      for (final category in EisenhowerCategory.values) {
        // Should find at least one widget with this text, specific location not checked
        expect(find.text(category.name), findsWidgets);
      }
      
      // Find the "Do Now" text specifically in the dialog and tap it
      final doNowInDialog = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Do Now')
      ).first; // Use first to handle multiple matches
      
      await tester.tap(doNowInDialog);
      await tester.pumpAndSettle();
      
      // Verify that FilterTasks event is dispatched with the correct category
      verify(() => mockBloc.add(any(that: isA<FilterTasks>()))).called(1);
    });
  });
}
