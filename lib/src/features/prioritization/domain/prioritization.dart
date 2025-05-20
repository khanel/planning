import 'package:flutter/material.dart';
import 'package:planning/src/core/utils/logger.dart';
import 'package:planning/src/features/prioritization/domain/priority.dart';
import 'package:planning/src/features/prioritization/domain/prioritization_strategy.dart';

/// A service that uses a specific prioritization strategy to calculate and manage priorities.
///
/// Type parameter T is the specific type of Priority this service works with.
class Prioritization<T extends Priority> {
  /// The strategy used for priority calculation
  final PrioritizationStrategy<T> strategy;

  Prioritization(this.strategy) {
    log.fine('Prioritization initialized with strategy: ${strategy.runtimeType}');
  }

  /// Calculate the priority based on importance and urgency
  T calculatePriority({
    required bool isImportant,
    required bool isUrgent,
  }) {
    log.info(
        'Calculating priority with strategy ${strategy.runtimeType}: Important=$isImportant, Urgent=$isUrgent');
    final category = strategy.calculatePriority(
      isImportant: isImportant,
      isUrgent: isUrgent,
    );
    log.fine('Calculated category: $category');
    return category;
  }

  /// Get a description for the given priority
  String getDescription(T priority) {
    log.info('Getting description for priority: $priority using strategy ${strategy.runtimeType}');
    final description = strategy.getDescription(priority);
    log.fine('Description for $priority: $description');
    return description;
  }

  /// Get the color associated with the given priority for UI representation
  Color getColor(T priority) {
    log.info('Getting color for priority: $priority using strategy ${strategy.runtimeType}');
    final color = strategy.getColor(priority);
    log.fine('Color for $priority: $color');
    return color;
  }
}
