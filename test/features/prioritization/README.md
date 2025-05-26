# Eisenhower Matrix Testing Suite

This directory contains tests for the Eisenhower Matrix feature of the planning application. The tests are organized to cover all aspects of the feature from individual units to integration tests.

## Test Structure

The test suite is organized into the following structure:

```
test/features/prioritization/
  ├── domain/                    # Domain layer tests
  │   ├── eisenhower_category_test.dart
  │   ├── eisenhower_strategy_test.dart
  │   └── task_prioritization_test.dart
  ├── presentation/              # Presentation layer tests
  │   ├── bloc/
  │   │   └── prioritization_bloc_test.dart
  │   ├── widgets/
  │   │   ├── matrix_quadrant_test.dart
  │   │   ├── eisenhower_matrix_test.dart
  │   │   └── drag_drop_test.dart
  │   └── pages/
  │       └── eisenhower_matrix_page_test.dart
  └── integration/               # Integration tests
      └── eisenhower_matrix_page_integration_test.dart
```

## Domain Layer Tests

### EisenhowerCategory Tests

Tests that verify the Eisenhower categories (Do Now, Decide, Delegate, Delete, Unprioritized) have the correct properties and values.

### EisenhowerStrategy Tests

Tests that verify the strategy for calculating priorities based on importance and urgency combinations.

### Task Prioritization Tests

Tests that verify task prioritization logic, including:
- Updating priority when a user assigns a new category
- Calculating urgency based on due dates
- Determining Eisenhower categories based on task attributes

## Presentation Layer Tests

### Bloc Tests

Tests for the state management of the prioritization feature:
- Loading tasks
- Filtering tasks by category
- Handling errors

### Widget Tests

#### MatrixQuadrant Tests

Tests for the individual quadrant widget:
- Displaying the correct title and description
- Showing tasks within the quadrant
- Displaying empty state when no tasks are available
- Showing the correct count of tasks

#### EisenhowerMatrix Tests

Tests for the matrix widget that displays all quadrants:
- Showing axis labels correctly
- Displaying all quadrants with their titles
- Handling unprioritized tasks section
- Formatting dates correctly

#### Drag and Drop Tests

Tests for the drag and drop functionality:
- Making tasks draggable
- Showing visual feedback during drag operations
- Handling task drops between quadrants

### Page Tests

Tests for the main Eisenhower Matrix page:
- Rendering the correct UI based on state
- Handling filtering operations
- Showing loading and error states

## Integration Tests

Tests that combine multiple components to verify the feature works as a whole:
- Full workflow from loading tasks to displaying in the matrix
- Filtering tasks and updating the UI
- Error handling and recovery

## Test Coverage

The test suite aims to cover all requirements specified in the SRS document, including:
- UI Layout (2x2 grid, unprioritized list, visual styling)
- Task Data Model (task entities, priority attributes)
- Functional Requirements (displaying tasks, drag-and-drop interactions)
- Non-Functional Requirements (performance, usability, accessibility)

## Running the Tests

Run all tests with:

```bash
flutter test test/features/prioritization/
```

Run specific test file:

```bash
flutter test test/features/prioritization/domain/eisenhower_category_test.dart
```

## Key Testing Considerations

1. **Drag and Drop Testing**: Special attention is given to testing drag-and-drop interactions since they are central to the feature's functionality.

2. **Visual Feedback**: Tests verify that appropriate visual feedback is provided during user interactions.

3. **Task Filtering**: Tests ensure that tasks appear in the correct quadrants based on their priority attributes.

4. **Empty States**: Tests verify that appropriate UI is shown when no tasks are available in a quadrant.

5. **Error Handling**: Tests ensure proper error states are displayed and recovery mechanisms work.

## Future Test Improvements

1. Golden tests for visual appearance verification
2. Accessibility testing for screen readers and keyboard navigation
3. Performance testing for large numbers of tasks
4. End-to-end tests for complete user workflows
