/// Constants used in the CalendarPage widget for UI configuration and text strings.
/// 
/// Centralizes all string literals, dimensions, and configuration values
/// to improve maintainability and consistency across the calendar page.
class CalendarPageConstants {
  // Prevent instantiation
  CalendarPageConstants._();

  // UI Text Constants
  static const String calendarTitle = 'Calendar';
  static const String loadingMessage = 'Loading calendar events...';
  static const String errorMessage = 'Failed to load events';
  static const String retryButtonText = 'Retry';
  static const String addButtonTooltip = 'Add Event';
  static const String noEventsMessage = 'No events for this day';
  static const String createEventTitle = 'Create Event';
  static const String createEventContent = 'Event creation will be implemented with BLoC integration';
  static const String cancelButtonText = 'Cancel';
  static const String saveButtonText = 'Save';
  
  // UI Spacing and Dimension Constants
  static const double loadingSpacing = 16.0;
  static const double errorIconSize = 48.0;
  static const double errorSpacing = 16.0;
  static const double errorSmallSpacing = 8.0;
  static const double containerMargin = 16.0;
  static const double containerPadding = 16.0;
  static const double eventItemSpacing = 4.0;
  static const double containerBorderRadius = 8.0;
  static const double markerTopMargin = 5.0;
  static const double markerPadding = 2.0;
  static const double markerBorderRadius = 4.0;
  static const double markerFontSize = 12.0;
  
  // UI Style Constants
  static const double selectedDayTitleFontSize = 16.0;
  static const double markerOpacity = 0.7;
}
