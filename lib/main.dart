import 'package:flutter/material.dart';
import 'package:planning/src/features/task/presentation/screens/task_screen.dart';
import 'package:planning/src/features/prioritization/presentation/pages/eisenhower_matrix_page.dart';
import 'package:planning/src/features/calendar/presentation/pages/calendar_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/task/presentation/bloc/task_bloc.dart' as task_bloc;
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart';
import 'package:planning/src/features/task/domain/usecases/get_tasks.dart';
import 'package:planning/src/features/task/domain/usecases/save_task.dart';
import 'package:planning/src/features/task/domain/usecases/delete_task.dart' as task_usecase;
import 'package:planning/src/features/task/data/repositories/task_repository_impl.dart';
import 'package:planning/src/features/task/data/datasources/task_local_data_source_impl.dart';
import 'package:planning/src/features/task/data/models/unified_record_model.dart';
import 'package:go_router/go_router.dart';
import 'package:planning/src/core/utils/logger.dart';
import 'package:logging/logging.dart'; // Add this import for Level enum


import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLogger(level: Level.ALL); // Explicitly set level to ALL
  log.warning('!!!!!!!!!! LOGGER INITIALIZED IN MAIN.DART !!!!!!!!!!'); // Test log message
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UnifiedRecordModelAdapter());
  }
  final taskBox = await Hive.openBox<UnifiedRecordModel>('unifiedRecords');
  final taskLocalDataSource = TaskLocalDataSourceImpl(taskBox: taskBox);
  final taskRepository = TaskRepositoryImpl(
    localDataSource: taskLocalDataSource,
  );
  final getTasks = GetTasks(taskRepository);
  final saveTask = SaveTask(taskRepository);
  final deleteTask = task_usecase.DeleteTask(taskRepository);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => task_bloc.TaskBloc(
            getTasks: getTasks,
            saveTask: saveTask,
            deleteTask: deleteTask,
          ),
        ),
        BlocProvider(
          create: (_) => PrioritizationBloc(
            getTasks: getTasks,
            saveTask: saveTask,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

// Configure GoRouter
final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const TaskScreen()),
    GoRoute(
      path: '/eisenhower',
      builder: (context, state) => const EisenhowerMatrixPage(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Use MaterialApp.router
      title: 'Planning App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _router, // Provide the router configuration
    );
  }
}
