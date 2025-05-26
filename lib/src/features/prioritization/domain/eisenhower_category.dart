import 'package:flutter/material.dart';
import 'priority.dart';

/// Represents the categories in the Eisenhower Matrix for task prioritization.
enum EisenhowerCategory implements Priority {
  /// Important and urgent tasks that require immediate attention
  doNow('Do Now', 'Important and urgent tasks that require immediate attention', Colors.red),

  /// Important but not urgent tasks that require planning
  decide('Decide', 'Important but not urgent tasks that require planning', Colors.blue),

  /// Urgent but not important tasks that can be delegated
  delegate('Delegate', 'Urgent but not important tasks that can be delegated', Colors.amber),

  /// Neither important nor urgent tasks that can be eliminated
  delete('Delete', 'Neither important nor urgent tasks that can be eliminated', Colors.green),

  /// Tasks that have not been prioritized yet
  unprioritized('Unprioritized', 'Tasks that have not been prioritized yet', Colors.grey);

  /// Constructor for EisenhowerCategory
  const EisenhowerCategory(this.name, this.description, this.color);

  /// The display name of the category
  final String name;

  /// The description of the category
  final String description;

  /// The color associated with the category
  final Color color;
}
