import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/task/data/models/unified_record_model.dart';

@module
abstract class HiveModule {
  @preResolve
  Future<Box<UnifiedRecordModel>> get unifiedRecordBox async {
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(UnifiedRecordModelAdapter().typeId)) {
      Hive.registerAdapter(UnifiedRecordModelAdapter());
    }
     if (!Hive.isAdapterRegistered(TaskDataModelAdapter().typeId)) {
      Hive.registerAdapter(TaskDataModelAdapter());
    }
     if (!Hive.isAdapterRegistered(TaskImportanceAdapter().typeId)) {
      Hive.registerAdapter(TaskImportanceAdapter());
    }


    return await Hive.openBox<UnifiedRecordModel>('unifiedRecords');
  }
}
