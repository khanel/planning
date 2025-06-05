import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:planning/src/features/task/presentation/screens/task_screen.dart';
import 'package:planning/src/features/task/presentation/bloc/task_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

class MockTaskBloc extends MockBloc<TaskEvent, TaskState> implements TaskBloc {}

void main() {
  group('TaskScreen Navigation', () {
    late TaskBloc mockTaskBloc;
    late GoRouter testRouter;
    String? navigatedRoute;

    setUp(() {
      mockTaskBloc = MockTaskBloc();
      navigatedRoute = null;
      
      // Configure the mock to return TaskLoadSuccess when asked
      whenListen(
        mockTaskBloc,
        Stream.fromIterable([const TaskLoadSuccess(tasks: [])]),
        initialState: const TaskInitial(),
      );
      
      // Create a test router that captures navigation
      testRouter = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const TaskScreen(),
          ),
          GoRoute(
            path: '/eisenhower',
            builder: (context, state) {
              navigatedRoute = '/eisenhower';
              return const Scaffold(body: Text('Eisenhower'));
            },
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) {
              navigatedRoute = '/calendar';
              return const Scaffold(body: Text('Calendar'));
            },
          ),
        ],
      );
    });

    Widget buildTaskScreen() {
      return BlocProvider<TaskBloc>.value(
        value: mockTaskBloc,
        child: MaterialApp.router(
          routerConfig: testRouter,
        ),
      );
    }

    testWidgets('should have calendar navigation button in AppBar', (tester) async {
      await tester.pumpWidget(buildTaskScreen());
      await tester.pumpAndSettle();

      // Find the AppBar
      expect(find.byType(AppBar), findsOneWidget);

      // Find calendar icon button in AppBar actions
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.calendar_today),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should navigate to calendar page when calendar button is tapped', (tester) async {
      await tester.pumpWidget(buildTaskScreen());
      await tester.pumpAndSettle();

      // Find and tap the calendar button
      final calendarButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.calendar_today),
      );
      
      expect(calendarButton, findsOneWidget);
      await tester.tap(calendarButton);
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(navigatedRoute, equals('/calendar'));
    });

    testWidgets('should have both eisenhower and calendar navigation buttons', (tester) async {
      await tester.pumpWidget(buildTaskScreen());
      await tester.pumpAndSettle();

      // Should have eisenhower button (existing)
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.grid_view),
        ),
        findsOneWidget,
      );

      // Should have calendar button (new)
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.calendar_today),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should maintain existing eisenhower navigation functionality', (tester) async {
      await tester.pumpWidget(buildTaskScreen());
      await tester.pumpAndSettle();

      // Find and tap the eisenhower button
      final eisenhowerButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.grid_view),
      );
      
      expect(eisenhowerButton, findsOneWidget);
      await tester.tap(eisenhowerButton);
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(navigatedRoute, equals('/eisenhower'));
    });
  });
}
