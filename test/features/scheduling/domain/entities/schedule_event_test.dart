import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';

void main() {
  group('ScheduleEvent', () {
    late ScheduleEvent scheduleEvent;
    final DateTime now = DateTime.now();
    final DateTime startTime = now.add(const Duration(hours: 1));
    final DateTime endTime = now.add(const Duration(hours: 2));

    setUp(() {
      scheduleEvent = ScheduleEvent(
        id: 'event-1',
        title: 'Team Meeting',
        description: 'Weekly team standup meeting',
        startTime: startTime,
        endTime: endTime,
        isAllDay: false,
        createdAt: now,
        updatedAt: now,
      );
    });

    group('Basic Properties', () {
      test('should create ScheduleEvent with required properties', () {
        expect(scheduleEvent.id, 'event-1');
        expect(scheduleEvent.title, 'Team Meeting');
        expect(scheduleEvent.description, 'Weekly team standup meeting');
        expect(scheduleEvent.startTime, startTime);
        expect(scheduleEvent.endTime, endTime);
        expect(scheduleEvent.isAllDay, false);
        expect(scheduleEvent.createdAt, now);
        expect(scheduleEvent.updatedAt, now);
      });

      test('should support all-day events', () {
        final allDayEvent = ScheduleEvent(
          id: 'event-2',
          title: 'Holiday',
          description: 'National Holiday',
          startTime: DateTime(2025, 12, 25),
          endTime: DateTime(2025, 12, 25, 23, 59, 59),
          isAllDay: true,
          createdAt: now,
          updatedAt: now,
        );

        expect(allDayEvent.isAllDay, true);
      });

      test('should support events without descriptions', () {
        final eventWithoutDesc = ScheduleEvent(
          id: 'event-3',
          title: 'Quick Call',
          startTime: startTime,
          endTime: endTime,
          isAllDay: false,
          createdAt: now,
          updatedAt: now,
        );

        expect(eventWithoutDesc.description, isNull);
      });
    });

    group('Google Calendar Integration', () {
      test('should have googleCalendarId for syncing with Google Calendar', () {
        final eventWithGoogleId = ScheduleEvent(
          id: 'event-4',
          title: 'Synced Event',
          description: 'Event synced with Google Calendar',
          startTime: startTime,
          endTime: endTime,
          isAllDay: false,
          createdAt: now,
          updatedAt: now,
          googleCalendarId: 'google-calendar-event-123',
        );

        expect(eventWithGoogleId.googleCalendarId, 'google-calendar-event-123');
      });

      test('should track sync status with Google Calendar', () {
        final syncedEvent = scheduleEvent.copyWith(
          googleCalendarId: 'google-123',
          syncStatus: CalendarSyncStatus.synced,
        );

        expect(syncedEvent.syncStatus, CalendarSyncStatus.synced);
        expect(syncedEvent.googleCalendarId, 'google-123');
      });

      test('should handle sync conflicts', () {
        final conflictEvent = scheduleEvent.copyWith(
          syncStatus: CalendarSyncStatus.conflict,
          lastSyncAt: now.subtract(const Duration(minutes: 30)),
        );

        expect(conflictEvent.syncStatus, CalendarSyncStatus.conflict);
        expect(conflictEvent.lastSyncAt, isNotNull);
      });
    });

    group('Validation', () {
      test('should validate that endTime is after startTime', () {
        expect(scheduleEvent.isValid, true);
        
        final invalidEvent = ScheduleEvent(
          id: 'invalid-1',
          title: 'Invalid Event',
          startTime: endTime,
          endTime: startTime, // End before start
          isAllDay: false,
          createdAt: now,
          updatedAt: now,
        );
        
        expect(invalidEvent.isValid, false);
      });

      test('should calculate duration correctly', () {
        expect(scheduleEvent.duration, const Duration(hours: 1));
      });

      test('should detect overlapping events', () {
        final overlappingEvent = ScheduleEvent(
          id: 'overlap-1',
          title: 'Overlapping Meeting',
          startTime: startTime.add(const Duration(minutes: 30)),
          endTime: endTime.add(const Duration(minutes: 30)),
          isAllDay: false,
          createdAt: now,
          updatedAt: now,
        );

        expect(scheduleEvent.overlapsWith(overlappingEvent), true);
      });

      test('should not detect overlap for non-overlapping events', () {
        final nonOverlappingEvent = ScheduleEvent(
          id: 'non-overlap-1',
          title: 'Later Meeting',
          startTime: endTime.add(const Duration(hours: 1)),
          endTime: endTime.add(const Duration(hours: 2)),
          isAllDay: false,
          createdAt: now,
          updatedAt: now,
        );

        expect(scheduleEvent.overlapsWith(nonOverlappingEvent), false);
      });
    });

    group('Task Integration', () {
      test('should support linking to tasks for task scheduling', () {
        final taskLinkedEvent = scheduleEvent.copyWith(
          linkedTaskId: 'task-123',
        );

        expect(taskLinkedEvent.linkedTaskId, 'task-123');
      });

      test('should support scheduling events from task due dates', () {
        final taskScheduledEvent = ScheduleEvent.fromTask(
          taskId: 'task-456',
          taskTitle: 'Complete project proposal',
          taskDueDate: startTime,
          estimatedDuration: const Duration(hours: 2),
          createdAt: now,
        );

        expect(taskScheduledEvent.linkedTaskId, 'task-456');
        expect(taskScheduledEvent.title, 'Complete project proposal');
        expect(taskScheduledEvent.startTime, startTime);
        expect(taskScheduledEvent.endTime, startTime.add(const Duration(hours: 2)));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedEvent = scheduleEvent.copyWith(
          title: 'Updated Meeting',
          description: 'Updated description',
        );

        expect(updatedEvent.title, 'Updated Meeting');
        expect(updatedEvent.description, 'Updated description');
        expect(updatedEvent.id, scheduleEvent.id); // Unchanged
        expect(updatedEvent.startTime, scheduleEvent.startTime); // Unchanged
      });

      test('should update syncStatus independently', () {
        final syncedEvent = scheduleEvent.copyWith(
          syncStatus: CalendarSyncStatus.syncing,
        );

        expect(syncedEvent.syncStatus, CalendarSyncStatus.syncing);
        expect(syncedEvent.title, scheduleEvent.title); // Unchanged
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final identicalEvent = ScheduleEvent(
          id: scheduleEvent.id,
          title: scheduleEvent.title,
          description: scheduleEvent.description,
          startTime: scheduleEvent.startTime,
          endTime: scheduleEvent.endTime,
          isAllDay: scheduleEvent.isAllDay,
          createdAt: scheduleEvent.createdAt,
          updatedAt: scheduleEvent.updatedAt,
        );

        expect(scheduleEvent, identicalEvent);
      });

      test('should not be equal when properties differ', () {
        final differentEvent = scheduleEvent.copyWith(title: 'Different Title');
        expect(scheduleEvent, isNot(differentEvent));
      });
    });
  });
}
