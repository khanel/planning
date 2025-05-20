import 'package:flutter/material.dart';

/// Base class for all priority types in the application.
/// This provides a common interface for different priority systems.
abstract class Priority {
  /// The display name of the priority
  String get name;
  
  /// A description of what this priority means
  String get description;
  
  /// The color associated with this priority for UI representation
  Color get color;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Priority &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
  
  @override
  String toString() => 'Priority(name: $name)';
}
