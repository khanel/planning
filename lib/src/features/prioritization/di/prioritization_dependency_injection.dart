import 'package:injectable/injectable.dart';
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart';
import 'package:planning/src/features/task/domain/usecases/get_tasks.dart'; // Import GetTasks

@module
abstract class PrioritizationDependencyInjection {
  @lazySingleton
  PrioritizationBloc prioritizationBloc(GetTasks getTasks) {
    return PrioritizationBloc(getTasks: getTasks);
  }
}
