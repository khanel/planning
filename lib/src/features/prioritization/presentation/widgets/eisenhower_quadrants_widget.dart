import 'package:flutter/material.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';

class EisenhowerQuadrantsWidget extends StatelessWidget {
  final Map<EisenhowerCategory, List<Task>> categorizedTasks;

  const EisenhowerQuadrantsWidget({Key? key, required this.categorizedTasks})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Importance Axis Label (Above top row)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: Center(
            child: Text(
              'Importance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          flex: 2, // Allocate more space to quadrants
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Urgency Axis Label (Left of quadrants)
              const RotatedBox(
                quarterTurns: -1,
                child: Center(
                  child: Text(
                    'Urgency',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Quadrants Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top row: Urgent & Important (Do) and Not Urgent & Important (Decide)
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Urgent & Not Important (Delegate)
                          Expanded(
                            child: Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Center(
                                      child: Text(
                                        EisenhowerCategory.delegate
                                            .toString()
                                            .split('.')
                                            .last,
                                        style: TextStyle(
                                          fontSize: 40,
                                          color: Colors.grey.withOpacity(0.3),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // You can add a summary or count of tasks here later
                                        // Expanded(child: TaskListView(tasks: categorizedTasks[EisenhowerCategory.delegate] ?? [])), // Optional: display tasks within quadrant
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Urgent & Important (Do)
                          Expanded(
                            child: Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Center(
                                      child: Text(
                                        EisenhowerCategory.doIt
                                            .toString()
                                            .split('.')
                                            .last,
                                        style: TextStyle(
                                          fontSize: 40,
                                          color: Colors.grey.withOpacity(0.3),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // You can add a summary or count of tasks here later
                                        // Expanded(child: TaskListView(tasks: categorizedTasks[EisenhowerCategory.doIt] ?? [])), // Optional: display tasks within quadrant
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom row: Urgent & Not Important (Delegate) and Not Urgent & Not Important (Delete)
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Not Urgent & Not Important (Delete)
                          Expanded(
                            child: Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Center(
                                      child: Text(
                                        EisenhowerCategory.delete
                                            .toString()
                                            .split('.')
                                            .last,
                                        style: TextStyle(
                                          fontSize: 40,
                                          color: Colors.grey.withOpacity(0.3),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // You can add a summary or count of tasks here later
                                        // Expanded(child: TaskListView(tasks: categorizedTasks[EisenhowerCategory.delete] ?? [])), // Optional: display tasks within quadrant
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Not Urgent & Important (Decide)
                          Expanded(
                            child: Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Center(
                                      child: Text(
                                        EisenhowerCategory.decide
                                            .toString()
                                            .split('.')
                                            .last,
                                        style: TextStyle(
                                          fontSize: 40,
                                          color: Colors.grey.withOpacity(0.3),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // You can add a summary or count of tasks here later
                                        // Expanded(child: TaskListView(tasks: categorizedTasks[EisenhowerCategory.decide] ?? [])), // Optional: display tasks within quadrant
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
