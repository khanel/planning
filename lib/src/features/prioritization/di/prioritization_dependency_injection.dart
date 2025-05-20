import 'package:injectable/injectable.dart';
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart';
import 'package:planning/src/features/task/domain/usecases/get_tasks.dart'; // Import GetTasks
import 'package:planning/src/core/utils/logger.dart';

@module
abstract class PrioritizationDependencyInjection {
  @lazySingleton
  PrioritizationBloc prioritizationBloc(GetTasks getTasks) {
    log.info('Creating PrioritizationBloc instance for DI');
    final bloc = PrioritizationBloc(getTasks: getTasks);
    log.fine('PrioritizationBloc instance created: $bloc');
    return bloc;
  }
}
