import 'package:planning/src/data/models/unified_record_model.dart';

abstract class TaskLocalDataSource {
  Future<List<UnifiedRecordModel>> getTasks();
  Future<UnifiedRecordModel> getTask(String id);
  Future<void> saveTask(UnifiedRecordModel taskRecord);
  Future<void> deleteTask(String id);
}