import 'package:flutter/material.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart' as eisenhower;
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/core/utils/logger.dart';

class EisenhowerQuadrantsWidget extends StatelessWidget {
  final Map<eisenhower.EisenhowerCategory, List<Task>> categorizedTasks;
  final void Function(Task task, eisenhower.EisenhowerCategory newCategory)?
      onTaskDropped;

  const EisenhowerQuadrantsWidget(
      {Key? key, required this.categorizedTasks, this.onTaskDropped})
      : super(key: key);

  /// Helper method to build quick action buttons for moving tasks between quadrants
  Widget _buildQuickActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    log.fine(
        'EisenhowerQuadrantsWidget: build called with ${categorizedTasks.length} categories.');

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
              // Urgency Axis Label (Left side)
              const RotatedBox(
                quarterTurns: 3,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Urgency',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              // Quadrant grid rendering
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top row: DoIt and Decide
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // DoIt (Urgent & Important)
                          Expanded(
                            child: DragTarget<Task>(
                              onWillAcceptWithDetails: (details) {
                                log.fine(
                                    'EisenhowerQuadrantsWidget: onWillAcceptWithDetails for DoIt quadrant, task: ${details.data.name}');
                                return true;
                              },
                              onAcceptWithDetails: (details) {
                                log.info(
                                    'EisenhowerQuadrantsWidget: onAcceptWithDetails for DoIt quadrant, task: ${details.data.name}');
                                if (onTaskDropped != null) {
                                  onTaskDropped!(details.data,
                                      eisenhower.EisenhowerCategory.doNow);
                                  log.fine(
                                      'EisenhowerQuadrantsWidget: onTaskDropped called for DoIt with task ${details.data.name}');
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                log.finest(
                                    'EisenhowerQuadrantsWidget: Building DoIt quadrant DragTarget. Candidates: ${candidateData.length}, Rejected: ${rejectedData.length}');
                                final tasks = categorizedTasks[
                                        eisenhower.EisenhowerCategory.doNow] ??
                                    [];

                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  color: candidateData.isNotEmpty
                                      ? Colors.red.withValues(alpha: 50)
                                      : Colors.red[50],
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            'DO',
                                            style: TextStyle(
                                              fontSize: 40,
                                              color: Colors.grey
                                                  .withValues(alpha: 75),
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
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text('Do First',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16)),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    '${tasks.length}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: tasks.length,
                                                itemBuilder: (context, index) {
                                                  final task = tasks[index];
                                                  return LongPressDraggable<
                                                      Task>(
                                                    data: task,
                                                    feedback: Material(
                                                      child: ListTile(
                                                        title: Text(task.name),
                                                        subtitle: Text(
                                                            task.description),
                                                        tileColor:
                                                            Colors.red[200],
                                                      ),
                                                    ),
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4,
                                                          horizontal: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha: 10),
                                                            blurRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                    0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              task.name,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            if (task.description
                                                                .isNotEmpty) ...[
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                task.description,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ],
                                                            const SizedBox(
                                                                height: 8),
                                                            SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  // Quick action buttons for moving tasks
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .doNow)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .priority_high,
                                                                      color: Colors
                                                                          .red,
                                                                      tooltip:
                                                                          'Move to Do First',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.doNow);
                                                                        }
                                                                      },
                                                                    ),
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .decide)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .calendar_today,
                                                                      color: Colors
                                                                          .blue,
                                                                      tooltip:
                                                                          'Move to Schedule',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.decide);
                                                                        }
                                                                      },
                                                                    ),
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .delegate)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .person_outline,
                                                                      color: Colors
                                                                          .orange,
                                                                      tooltip:
                                                                          'Move to Delegate',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.delegate);
                                                                        }
                                                                      },
                                                                    ),
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .delete)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .delete_outline,
                                                                      color: Colors
                                                                          .grey,
                                                                      tooltip:
                                                                          'Move to Eliminate',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.delete);
                                                                        }
                                                                      },
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
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
                                );
                              },
                            ),
                          ),
                          // Decide (Not Urgent & Important)
                          Expanded(
                            child: DragTarget<Task>(
                              onWillAcceptWithDetails: (details) {
                                log.fine(
                                    'EisenhowerQuadrantsWidget: onWillAcceptWithDetails for Decide quadrant, task: ${details.data.name}');
                                return true;
                              },
                              onAcceptWithDetails: (details) {
                                log.info(
                                    'EisenhowerQuadrantsWidget: onAcceptWithDetails for Decide quadrant, task: ${details.data.name}');
                                if (onTaskDropped != null) {
                                  onTaskDropped!(details.data,
                                      eisenhower.EisenhowerCategory.decide);
                                  log.fine(
                                      'EisenhowerQuadrantsWidget: onTaskDropped called for Decide with task ${details.data.name}');
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                log.finest(
                                    'EisenhowerQuadrantsWidget: Building Decide quadrant DragTarget. Candidates: ${candidateData.length}, Rejected: ${rejectedData.length}');
                                final tasks = categorizedTasks[
                                        eisenhower.EisenhowerCategory.decide] ??
                                    [];

                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  color: candidateData.isNotEmpty
                                      ? Colors.blue.withValues(alpha: 50)
                                      : Colors.blue[50],
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            'SCHEDULE',
                                            style: TextStyle(
                                              fontSize: 40,
                                              color: Colors.grey
                                                  .withValues(alpha: 75),
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
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text('Schedule',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16)),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    '${tasks.length}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: tasks.length,
                                                itemBuilder: (context, index) {
                                                  final task = tasks[index];
                                                  return LongPressDraggable<
                                                      Task>(
                                                    data: task,
                                                    feedback: Material(
                                                      child: ListTile(
                                                        title: Text(task.name),
                                                        subtitle: Text(
                                                            task.description),
                                                        tileColor:
                                                            Colors.blue[200],
                                                      ),
                                                    ),
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4,
                                                          horizontal: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha: 10),
                                                            blurRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                    0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              task.name,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            if (task.description
                                                                .isNotEmpty) ...[
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                task.description,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ],
                                                            const SizedBox(
                                                                height: 8),
                                                            SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  // Quick action buttons for moving tasks
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .doNow)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .priority_high,
                                                                      color: Colors
                                                                          .red,
                                                                      tooltip:
                                                                          'Move to Do First',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.doNow);
                                                                        }
                                                                      },
                                                                    ),
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .decide)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .calendar_today,
                                                                      color: Colors
                                                                          .blue,
                                                                      tooltip:
                                                                          'Move to Schedule',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.decide);
                                                                        }
                                                                      },
                                                                    ),
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .delegate)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .person_outline,
                                                                      color: Colors
                                                                          .orange,
                                                                      tooltip:
                                                                          'Move to Delegate',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.delegate);
                                                                        }
                                                                      },
                                                                    ),
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .delete)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .delete_outline,
                                                                      color: Colors
                                                                          .grey,
                                                                      tooltip:
                                                                          'Move to Eliminate',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.delete);
                                                                        }
                                                                      },
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
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
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom row: Delegate and Delete
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Delegate (Urgent & Not Important)
                          Expanded(
                            child: DragTarget<Task>(
                              onWillAcceptWithDetails: (details) {
                                log.fine(
                                    'EisenhowerQuadrantsWidget: onWillAcceptWithDetails for Delegate quadrant, task: ${details.data.name}');
                                return true;
                              },
                              onAcceptWithDetails: (details) {
                                log.info(
                                    'EisenhowerQuadrantsWidget: onAcceptWithDetails for Delegate quadrant, task: ${details.data.name}');
                                if (onTaskDropped != null) {
                                  onTaskDropped!(details.data,
                                      eisenhower.EisenhowerCategory.delegate);
                                  log.fine(
                                      'EisenhowerQuadrantsWidget: onTaskDropped called for Delegate with task ${details.data.name}');
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                log.finest(
                                    'EisenhowerQuadrantsWidget: Building Delegate quadrant DragTarget. Candidates: ${candidateData.length}, Rejected: ${rejectedData.length}');
                                final tasks = categorizedTasks[eisenhower
                                        .EisenhowerCategory.delegate] ??
                                    [];

                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  color: candidateData.isNotEmpty
                                      ? Colors.orange.withValues(alpha: 50)
                                      : Colors.orange[50],
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            'DELEGATE',
                                            style: TextStyle(
                                              fontSize: 40,
                                              color: Colors.grey
                                                  .withValues(alpha: 75),
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
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text('Delegate',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16)),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    '${tasks.length}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: tasks.length,
                                                itemBuilder: (context, index) {
                                                  final task = tasks[index];
                                                  return LongPressDraggable<
                                                      Task>(
                                                    data: task,
                                                    feedback: Material(
                                                      child: ListTile(
                                                        title: Text(task.name),
                                                        subtitle: Text(
                                                            task.description),
                                                        tileColor:
                                                            Colors.orange[200],
                                                      ),
                                                    ),
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4,
                                                          horizontal: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha: 10),
                                                            blurRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                    0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              task.name,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            if (task.description
                                                                .isNotEmpty) ...[
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                task.description,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ],
                                                            const SizedBox(
                                                                height: 8),
                                                            SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  // Quick action buttons for moving tasks
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .doNow)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .priority_high,
                                                                      color: Colors
                                                                          .red,
                                                                      tooltip:
                                                                          'Move to Do First',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.doNow);
                                                                        }
                                                                      },
                                                                    ),
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .decide)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .calendar_today,
                                                                      color: Colors
                                                                          .blue,
                                                                      tooltip:
                                                                          'Move to Schedule',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.decide);
                                                                        }
                                                                      },
                                                                    ),
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .delegate)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .person_outline,
                                                                      color: Colors
                                                                          .orange,
                                                                      tooltip:
                                                                          'Move to Delegate',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.delegate);
                                                                        }
                                                                      },
                                                                    ),
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .delete)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .delete_outline,
                                                                      color: Colors
                                                                          .grey,
                                                                      tooltip:
                                                                          'Move to Eliminate',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.delete);
                                                                        }
                                                                      },
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
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
                                );
                              },
                            ),
                          ),
                          // Delete (Not Urgent & Not Important)
                          Expanded(
                            child: DragTarget<Task>(
                              onWillAcceptWithDetails: (details) {
                                log.fine(
                                    'EisenhowerQuadrantsWidget: onWillAcceptWithDetails for Delete quadrant, task: ${details.data.name}');
                                return true;
                              },
                              onAcceptWithDetails: (details) {
                                log.info(
                                    'EisenhowerQuadrantsWidget: onAcceptWithDetails for Delete quadrant, task: ${details.data.name}');
                                if (onTaskDropped != null) {
                                  onTaskDropped!(details.data,
                                      eisenhower.EisenhowerCategory.delete);
                                  log.fine(
                                      'EisenhowerQuadrantsWidget: onTaskDropped called for Delete with task ${details.data.name}');
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                log.finest(
                                    'EisenhowerQuadrantsWidget: Building Delete quadrant DragTarget. Candidates: ${candidateData.length}, Rejected: ${rejectedData.length}');
                                final tasks = categorizedTasks[
                                        eisenhower.EisenhowerCategory.delete] ??
                                    [];

                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  color: candidateData.isNotEmpty
                                      ? Colors.grey.withValues(alpha: 50)
                                      : Colors.grey[50],
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            'ELIMINATE',
                                            style: TextStyle(
                                              fontSize: 40,
                                              color: Colors.grey
                                                  .withValues(alpha: 75),
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
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text('Eliminate',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16)),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    '${tasks.length}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: tasks.length,
                                                itemBuilder: (context, index) {
                                                  final task = tasks[index];
                                                  return LongPressDraggable<
                                                      Task>(
                                                    data: task,
                                                    feedback: Material(
                                                      child: ListTile(
                                                        title: Text(task.name),
                                                        subtitle: Text(
                                                            task.description),
                                                        tileColor:
                                                            Colors.grey[300],
                                                      ),
                                                    ),
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4,
                                                          horizontal: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha: 10),
                                                            blurRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                    0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              task.name,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            if (task.description
                                                                .isNotEmpty) ...[
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                task.description,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ],
                                                            const SizedBox(
                                                                height: 8),
                                                            SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  // Quick action buttons for moving tasks
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .doNow)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .priority_high,
                                                                      color: Colors
                                                                          .red,
                                                                      tooltip:
                                                                          'Move to Do First',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.doNow);
                                                                        }
                                                                      },
                                                                    ),
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .decide)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .calendar_today,
                                                                      color: Colors
                                                                          .blue,
                                                                      tooltip:
                                                                          'Move to Schedule',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.decide);
                                                                        }
                                                                      },
                                                                    ),
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .delegate)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .person_outline,
                                                                      color: Colors
                                                                          .orange,
                                                                      tooltip:
                                                                          'Move to Delegate',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.delegate);
                                                                        }
                                                                      },
                                                                    ),
                                                                  if (task.eisenhowerCategory !=
                                                                      eisenhower
                                                                          .EisenhowerCategory
                                                                          .delete)
                                                                    _buildQuickActionButton(
                                                                      icon: Icons
                                                                          .delete_outline,
                                                                      color: Colors
                                                                          .grey,
                                                                      tooltip:
                                                                          'Move to Eliminate',
                                                                      onPressed:
                                                                          () {
                                                                        if (onTaskDropped !=
                                                                            null) {
                                                                          onTaskDropped!(
                                                                              task,
                                                                              eisenhower.EisenhowerCategory.delete);
                                                                        }
                                                                      },
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
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
        // Unprioritized List (bottom section)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Unprioritized',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${categorizedTasks[eisenhower.EisenhowerCategory.unprioritized]?.length ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              DragTarget<Task>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) {
                  if (onTaskDropped != null) {
                    onTaskDropped!(details.data,
                        eisenhower.EisenhowerCategory.unprioritized);
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  final unprioritizedTasks = categorizedTasks[
                          eisenhower.EisenhowerCategory.unprioritized] ??
                      [];
                  return Semantics(
                    label: 'Unprioritized tasks list',
                    child: Card(
                      color: candidateData.isNotEmpty
                          ? Colors.grey[200]
                          : Colors.white,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: unprioritizedTasks.length,
                        itemBuilder: (context, index) {
                          final task = unprioritizedTasks[index];
                          return LongPressDraggable<Task>(
                            data: task,
                            feedback: Material(
                              child: ListTile(
                                title: Text(task.name),
                                subtitle: Text(task.description),
                                tileColor: Colors.grey[300],
                              ),
                            ),
                            child: ListTile(
                              title: Text(task.name),
                              subtitle: Text(task.description),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
