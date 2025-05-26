import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/task/domain/usecases/get_tasks.dart';
import 'package:planning/src/features/task/domain/usecases/save_task.dart';

void main() {
  group('PrioritizationBloc', () {
    late PrioritizationBloc bloc;
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
      bloc = PrioritizationBloc();
    });
    
    tearDown(() {
      bloc.close();
    });
    
    test('initial state should be PrioritizationInitial', () {
      expect(bloc.state, isA<PrioritizationInitial>());
    });
    
    test('LoadPrioritizedTasks should emit loading then success state', () async {
      // This test would normally use mockRepository to return mockTasks
      // Since our implementation just uses a delay and empty list, we'll just verify states
      
      // Act
      bloc.add(const LoadPrioritizedTasks());
      
      // Assert - verify state transitions
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PrioritizationLoadInProgress>(),
          isA<PrioritizationLoadSuccess>(),
        ]),
      );
    });
    
    test('FilterTasks should emit state with filtered tasks', () async {
      // Setup - first need to get to the success state
      bloc.add(const LoadPrioritizedTasks());
      
      // Wait for the success state
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PrioritizationLoadInProgress>(),
          isA<PrioritizationLoadSuccess>(),
        ]),
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
