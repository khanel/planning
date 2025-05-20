import 'package:flutter/material.dart';
import 'package:planning/src/features/prioritization/domain/priority.dart';

/// A strategy interface for different priority calculation methods.
///
/// Type parameter T is the specific type of Priority this strategy works with.
abstract class PrioritizationStrategy<T extends Priority> {
  /// The display name of this prioritization strategy
  String get name;
  
  /// Calculate the priority based on the given parameters
  T calculatePriority({
    required bool isImportant,
    required bool isUrgent,
  });

  /// Get a description for the given priority
  String getDescription(T priority);
  
  /// Get the color associated with the given priority for UI representation
  Color getColor(T priority);
}
