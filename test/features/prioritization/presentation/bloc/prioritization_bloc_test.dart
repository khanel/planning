import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/task/domain/usecases/get_tasks.dart';
import 'package:planning/src/features/task/domain/usecases/save_task.dart';

// Create mock classes
class MockGetTasks extends Mock implements GetTasks {}
class MockSaveTask extends Mock implements SaveTask {}
class MockNoParams extends Mock implements NoParams {}
class MockSaveTaskParams extends Mock implements SaveTaskParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockNoParams());
    registerFallbackValue(MockSaveTaskParams());
  });
  group('PrioritizationBloc', () {
    late PrioritizationBloc bloc;
    late MockGetTasks mockGetTasks;
    late MockSaveTask mockSaveTask;
    final DateTime now = DateTime.now();
    
    // Sample tasks for testing
    final mockTasks = [
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
    ];
    
    setUp(() {
      mockGetTasks = MockGetTasks();
      mockSaveTask = MockSaveTask();
      
      // Setup the mock to return our tasks
      when(() => mockGetTasks(any())).thenAnswer((_) async => Right(mockTasks));
      
      bloc = PrioritizationBloc(
        getTasks: mockGetTasks,
        saveTask: mockSaveTask,
      );
    });
    
    tearDown(() {
      bloc.close();
    });
    
    test('initial state should be PrioritizationLoadInProgress', () {
      // The bloc now automatically starts loading in the constructor
      expect(bloc.state, isA<PrioritizationLoadInProgress>());
    });
    
    test('LoadPrioritizedTasks should complete loading', () async {
      // Wait for the loading to complete
      await expectLater(
        bloc.stream,
        emits(isA<PrioritizationLoadSuccess>()),
      );
    });
    
    test('FilterTasks should emit state with filtered tasks', () async {
      // Wait for the loading to complete first
      await expectLater(
        bloc.stream,
        emits(isA<PrioritizationLoadSuccess>()),
      );
      
      // Act - apply filter
      bloc.add(const FilterTasks(EisenhowerCategory.doNow));
      
      // Assert - check state has correct filter
      await expectLater(
        bloc.stream,
        emits(
          isA<PrioritizationLoadSuccess>().having(
            (state) => state.currentFilter,
            'currentFilter',
            equals(EisenhowerCategory.doNow),
          ),
        ),
      );
    });
  });
}
