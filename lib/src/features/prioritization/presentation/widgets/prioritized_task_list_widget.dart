import 'package:flutter/material.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/core/utils/logger.dart';

class PrioritizedTaskListWidget extends StatelessWidget {
  final List<Task> tasks;

  const PrioritizedTaskListWidget({Key? key, required this.tasks})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine('PrioritizedTaskListWidget: build called with ${tasks.length} tasks.');
    if (tasks.isEmpty) {
      log.info('PrioritizedTaskListWidget: No tasks to display.');
      return const Center(child: Text('No task to display.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0), // Outer space from other elements
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Tasks',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            ...tasks
                .map((task) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: LongPressDraggable<Task>(
                          data: task,
                          onDragStarted: () {
                            log.fine('PrioritizedTaskListWidget: Drag started for task: ${task.name}');
                          },
                          onDragEnd: (details) {
                            log.fine('PrioritizedTaskListWidget: Drag ended for task: ${task.name}. Accepted: ${details.wasAccepted}');
                          },
                          feedback: Material(
                            color: Colors.transparent,
                            child: Card(
                              elevation: 6.0,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  task.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: Card(
                              elevation: 2.0,
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      task.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    if (task.description.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          task.description,
                                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                                        ),
                                      ),
                                    if (task.dueDate != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          'Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}',
                                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Importance: ${task.importance.toString().split('.').last}',
                                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          child: Card(
                            elevation: 2.0,
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    task.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  if (task.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        task.description,
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ),
                                  if (task.dueDate != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}',
                                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'Importance: ${task.importance.toString().split('.').last}',
                                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ))
                ,
          ],
        ),
      ),
    );
  }
}
