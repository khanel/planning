import 'package:flutter/material.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/calendar/presentation/utils/date_time_formatter.dart';
import 'package:planning/src/features/calendar/presentation/utils/event_validation.dart';

class EventCreationDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(ScheduleEvent)? onEventCreated;

  const EventCreationDialog({
    super.key,
    required this.selectedDate,
    this.onEventCreated,
  });

  @override
  State<EventCreationDialog> createState() => _EventCreationDialogState();
}

class _EventCreationDialogState extends State<EventCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Event'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildTimeField(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveEvent,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      key: const Key('event_title_field'),
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Event Title',
      ),
      validator: EventValidation.validateTitle,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      key: const Key('event_date_field'),
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
        ),
        child: Text(DateTimeFormatter.formatDate(_selectedDate)),
      ),
    );
  }

  Widget _buildTimeField() {
    return InkWell(
      key: const Key('event_time_field'),
      onTap: _selectTime,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Time',
        ),
        child: Text(DateTimeFormatter.formatTime(_selectedTime)),
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      final event = ScheduleEvent(
        id: now.millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: '',
        startTime: startDateTime,
        endTime: startDateTime.add(const Duration(hours: 1)),
        createdAt: now,
        updatedAt: now,
      );

      widget.onEventCreated?.call(event);
      Navigator.of(context).pop();
    }
  }
}
