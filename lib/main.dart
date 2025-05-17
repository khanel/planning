import 'package:planning/src/features/task/presentation/screens/task_screen.dart';
import 'package:planning/src/features/task/presentation/screens/eisenhower_matrix_screen.dart'; // Import EisenhowerMatrixScreen
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/task/presentation/bloc/task_bloc.dart' as task_bloc;
import 'package:planning/src/features/task/domain/usecases/get_tasks.dart';
import 'package:planning/src/features/task/domain/usecases/save_task.dart';
import 'package:planning/src/features/task/domain/usecases/delete_task.dart' as task_usecase;
// import 'package:planning/src/features/task/domain/repositories/task_repository.dart';
import 'package:planning/src/features/task/data/repositories/task_repository_impl.dart';
import 'package:planning/src/features/task/data/datasources/task_local_data_source_impl.dart';
import 'package:planning/src/data/models/unified_record_model.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart'; // Import go_router

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UnifiedRecordModelAdapter());
  }
  final taskBox = await Hive.openBox<UnifiedRecordModel>('unifiedRecords');
  final taskLocalDataSource = TaskLocalDataSourceImpl(taskBox: taskBox);
  final taskRepository = TaskRepositoryImpl(localDataSource: taskLocalDataSource);
  final getTasks = GetTasks(taskRepository);
  final saveTask = SaveTask(taskRepository);
  final deleteTask = task_usecase.DeleteTask(taskRepository);
  runApp(
    BlocProvider(
      create: (_) => task_bloc.TaskBloc(
        getTasks: getTasks,
        saveTask: saveTask,
        deleteTask: deleteTask,
      ),
      child: MyApp(),
    ),
  );
}

// Configure GoRouter
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TaskScreen(),
    ),
    GoRoute(
      path: '/eisenhower',
      builder: (context, state) => const EisenhowerMatrixScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router( // Use MaterialApp.router
      title: 'Planning App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _router, // Provide the router configuration
    );
  }
}
