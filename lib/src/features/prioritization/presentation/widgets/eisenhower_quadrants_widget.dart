import 'package:flutter/material.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/core/utils/logger.dart';

class EisenhowerQuadrantsWidget extends StatelessWidget {
  final Map<EisenhowerCategory, List<Task>> categorizedTasks;
  final void Function(Task task, EisenhowerCategory newCategory)? onTaskDropped;

  const EisenhowerQuadrantsWidget({Key? key, required this.categorizedTasks, this.onTaskDropped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine('EisenhowerQuadrantsWidget: build called with ${categorizedTasks.length} categories.');
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
                            child: DragTarget<Task>(
                              onWillAcceptWithDetails: (details) {
                                log.fine('EisenhowerQuadrantsWidget: onWillAcceptWithDetails for Delegate quadrant, task: ${details.data.name}');
                                return true;
                              },
                              onAcceptWithDetails: (details) {
                                log.info('EisenhowerQuadrantsWidget: onAcceptWithDetails for Delegate quadrant, task: ${details.data.name}');
                                if (onTaskDropped != null) {
                                  onTaskDropped!(details.data, EisenhowerCategory.delegate);
                                  log.fine('EisenhowerQuadrantsWidget: onTaskDropped called for Delegate with task ${details.data.name}');
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                log.finest('EisenhowerQuadrantsWidget: Building Delegate quadrant DragTarget. Candidates: ${candidateData.length}, Rejected: ${rejectedData.length}');
                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  color: candidateData.isNotEmpty ? Colors.orange.withValues(alpha: .2) : null,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            EisenhowerCategory.delegate.toString().split('.').last,
                                            style: TextStyle(
                                              fontSize: 40,
                                              color: Colors.grey.withValues(alpha: .3),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // You can add a summary or count of tasks here later
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          // Urgent & Important (Do)
                          Expanded(
                            child: DragTarget<Task>(
                              onWillAcceptWithDetails: (details) {
                                log.fine('EisenhowerQuadrantsWidget: onWillAcceptWithDetails for DoIt quadrant, task: ${details.data.name}');
                                return true;
                              },
                              onAcceptWithDetails: (details) {
                                log.info('EisenhowerQuadrantsWidget: onAcceptWithDetails for DoIt quadrant, task: ${details.data.name}');
                                if (onTaskDropped != null) {
                                  onTaskDropped!(details.data, EisenhowerCategory.doIt);
                                  log.fine('EisenhowerQuadrantsWidget: onTaskDropped called for DoIt with task ${details.data.name}');
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                log.finest('EisenhowerQuadrantsWidget: Building DoIt quadrant DragTarget. Candidates: ${candidateData.length}, Rejected: ${rejectedData.length}');
                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  color: candidateData.isNotEmpty ? Colors.red.withValues(alpha: .2) : null,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            EisenhowerCategory.doIt.toString().split('.').last,
                                            style: TextStyle(
                                              fontSize: 40,
                                              color: Colors.grey.withValues(alpha: .3),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // You can add a summary or count of tasks here later
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
                            child: DragTarget<Task>(
                              onWillAcceptWithDetails: (details) {
                                log.fine('EisenhowerQuadrantsWidget: onWillAcceptWithDetails for Delete quadrant, task: ${details.data.name}');
                                return true;
                              },
                              onAcceptWithDetails: (details) {
                                log.info('EisenhowerQuadrantsWidget: onAcceptWithDetails for Delete quadrant, task: ${details.data.name}');
                                if (onTaskDropped != null) {
                                  onTaskDropped!(details.data, EisenhowerCategory.delete);
                                  log.fine('EisenhowerQuadrantsWidget: onTaskDropped called for Delete with task ${details.data.name}');
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                log.finest('EisenhowerQuadrantsWidget: Building Delete quadrant DragTarget. Candidates: ${candidateData.length}, Rejected: ${rejectedData.length}');
                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  color: candidateData.isNotEmpty ? Colors.grey.withValues(alpha: .2) : null,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            EisenhowerCategory.delete.toString().split('.').last,
                                            style: TextStyle(
                                              fontSize: 40,
                                              color: Colors.grey.withValues(alpha: 0.3),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // You can add a summary or count of tasks here later
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          // Not Urgent & Important (Decide)
                          Expanded(
                            child: DragTarget<Task>(
                              onWillAcceptWithDetails: (details) {
                                log.fine('EisenhowerQuadrantsWidget: onWillAcceptWithDetails for Decide quadrant, task: ${details.data.name}');
                                return true;
                              },
                              onAcceptWithDetails: (details) {
                                log.info('EisenhowerQuadrantsWidget: onAcceptWithDetails for Decide quadrant, task: ${details.data.name}');
                                if (onTaskDropped != null) {
                                  onTaskDropped!(details.data, EisenhowerCategory.decide);
                                  log.fine('EisenhowerQuadrantsWidget: onTaskDropped called for Decide with task ${details.data.name}');
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                log.finest('EisenhowerQuadrantsWidget: Building Decide quadrant DragTarget. Candidates: ${candidateData.length}, Rejected: ${rejectedData.length}');
                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  color: candidateData.isNotEmpty ? Colors.blue.withValues(alpha: .2) : null,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            EisenhowerCategory.decide.toString().split('.').last,
                                            style: TextStyle(
                                              fontSize: 40,
                                              color: Colors.grey.withValues(alpha: .3),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // You can add a summary or count of tasks here later
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
