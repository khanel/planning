// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive/hive.dart' as _i979;
import 'package:injectable/injectable.dart' as _i526;
import 'package:planning/src/features/task/data/models/unified_record_model.dart' as _i216;

import '../../features/task/data/datasources/task_local_data_source.dart'
    as _i1043;
import '../../features/task/di/task_dependency_injection.dart' as _i649;
import '../../features/task/domain/repositories/task_repository.dart' as _i81;
import '../../features/task/domain/usecases/delete_task.dart' as _i227;
import '../../features/task/domain/usecases/get_tasks.dart' as _i477;
import '../../features/task/domain/usecases/save_task.dart' as _i130;
import 'hive_module.dart' as _i576;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final hiveModule = _$HiveModule();
    final taskDependencyInjection = _$TaskDependencyInjection();
    await gh.factoryAsync<_i979.Box<_i216.UnifiedRecordModel>>(
      () => hiveModule.unifiedRecordBox,
      preResolve: true,
    );
    gh.lazySingleton<_i1043.TaskLocalDataSource>(
        () => taskDependencyInjection.taskLocalDataSource);
    gh.lazySingleton<_i81.TaskRepository>(
        () => taskDependencyInjection.taskRepository);
    gh.lazySingleton<_i477.GetTasks>(
        () => taskDependencyInjection.getTasksUseCase);
    gh.lazySingleton<_i130.SaveTask>(
        () => taskDependencyInjection.saveTaskUseCase);
    gh.lazySingleton<_i227.DeleteTask>(
        () => taskDependencyInjection.deleteTaskUseCase);
    return this;
  }
}

class _$HiveModule extends _i576.HiveModule {}

class _$TaskDependencyInjection extends _i649.TaskDependencyInjection {}
