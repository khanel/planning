/// Utility class for validating event form inputs
class EventValidation {
  /// Validates event title input
  /// Returns error message if invalid, null if valid
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an event title';
    }
    return null;
  }
}
