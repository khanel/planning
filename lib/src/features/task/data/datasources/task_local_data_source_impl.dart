import 'package:hive/hive.dart';
import 'package:planning/src/core/errors/exceptions.dart';
import 'package:planning/src/features/task/data/models/unified_record_model.dart';
import 'package:planning/src/features/task/data/datasources/task_local_data_source.dart';

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<UnifiedRecordModel> taskBox;

  TaskLocalDataSourceImpl({required this.taskBox});

  @override
  Future<List<UnifiedRecordModel>> getTasks() {
    try {
      // Filter for records of type 'task'
      return Future.value(taskBox.values.where((record) => record.type == 'task').toList());
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<UnifiedRecordModel> getTask(String id) {
    try {
      final record = taskBox.get(id);
      if (record != null && record.type == 'task') {
        return Future.value(record);
      } else {
        throw CacheException(); // Or a more specific NotFoundException
      }
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveTask(UnifiedRecordModel taskRecord) {
    try {
      // Ensure the record is of type 'task' before saving
      if (taskRecord.type != 'task') {
         throw ArgumentError('UnifiedRecordModel must be of type "task"');
      }
      return taskBox.put(taskRecord.id, taskRecord);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteTask(String id) {
    try {
      return taskBox.delete(id);
    } catch (e) {
      throw CacheException();
    }
  }
}