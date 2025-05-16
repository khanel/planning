import '../../../../domain/entities/task.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/domain/usecases/get_tasks.dart';
import '../../../../core/usecases/usecase.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks; // Assuming a GetTasks use case

  TaskBloc({required this.getTasks}) : super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoadInProgress());
    final result = await getTasks(NoParams()); // Execute the use case

    result.fold(
      (failure) => emit(TaskLoadFailure(message: failure.toString())),
      (tasks) => emit(TaskLoadSuccess(tasks: tasks)),
    );
  }
}
