import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/scheduling_bloc.dart';
import '../../domain/entities/schedule_event.dart';
import '../../domain/entities/calendar_sync_status.dart';

/// Page for adding or editing schedule events.
/// 
/// This page provides a form for creating new events or editing existing ones.
/// It uses the SchedulingBloc to handle create and update operations.
class AddEditEventPage extends StatefulWidget {
  final ScheduleEvent? event;

  const AddEditEventPage({super.key, this.event});

  @override
  State<AddEditEventPage> createState() => _AddEditEventPageState();
}

class _AddEditEventPageState extends State<AddEditEventPage> {
  // Constants
  static const double _defaultSpacing = 16.0;
  static const double _buttonSpacing = 32.0;
  static const int _descriptionMaxLines = 3;
  static const String _titleRequiredMessage = 'Please enter a title';
  
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late bool _isAllDay;

  @override
  void initState() {
    super.initState();
    
    if (widget.event != null) {
      // Editing existing event
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description ?? '';
      _startDate = DateTime(
        widget.event!.startTime.year,
        widget.event!.startTime.month,
        widget.event!.startTime.day,
      );
      _startTime = TimeOfDay.fromDateTime(widget.event!.startTime);
      _endDate = DateTime(
        widget.event!.endTime.year,
        widget.event!.endTime.month,
        widget.event!.endTime.day,
      );
      _endTime = TimeOfDay.fromDateTime(widget.event!.endTime);
      _isAllDay = widget.event!.isAllDay;
    } else {
      // Creating new event
      _titleController.text = '';
      _descriptionController.text = '';
      final now = DateTime.now();
      _startDate = DateTime(now.year, now.month, now.day);
      _startTime = TimeOfDay(hour: now.hour, minute: 0);
      _endDate = DateTime(now.year, now.month, now.day);
      _endTime = TimeOfDay(hour: now.hour + 1, minute: 0);
      _isAllDay = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'Edit Event' : 'Add Event'),
      ),
      body: BlocConsumer<SchedulingBloc, SchedulingState>(
        listener: (context, state) {
          if (state is SchedulingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is SchedulingEventsLoaded) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is SchedulingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is SchedulingError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.message,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildForm()),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTitleField(),
            SizedBox(height: _defaultSpacing),
            _buildDescriptionField(),
            SizedBox(height: _defaultSpacing),
            _buildAllDaySwitch(),
            SizedBox(height: _defaultSpacing),
            _buildDateTimeFields(),
            SizedBox(height: _buttonSpacing),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(labelText: 'Title'),
      validator: _validateTitle,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(labelText: 'Description'),
      maxLines: _descriptionMaxLines,
    );
  }

  Widget _buildAllDaySwitch() {
    return SwitchListTile(
      title: const Text('All Day'),
      value: _isAllDay,
      onChanged: (value) {
        setState(() {
          _isAllDay = value;
        });
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveEvent,
      child: const Text('Save'),
    );
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return _titleRequiredMessage;
    }
    return null;
  }

  Widget _buildDateTimeFields() {
    return Column(
      children: [
        ListTile(
          title: const Text('Start Date'),
          subtitle: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
          onTap: () => _selectDate(context, true),
        ),
        if (!_isAllDay)
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(_startTime.format(context)),
            onTap: () => _selectTime(context, true),
          ),
        ListTile(
          title: const Text('End Date'),
          subtitle: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
          onTap: () => _selectDate(context, false),
        ),
        if (!_isAllDay)
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(_endTime.format(context)),
            onTap: () => _selectTime(context, false),
          ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );

    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final event = _createEventFromForm();
      _dispatchEventToBloc(event);
    }
  }

  ScheduleEvent _createEventFromForm() {
    final startDateTime = _createStartDateTime();
    final endDateTime = _createEndDateTime();
    
    return ScheduleEvent(
      id: widget.event?.id ?? _generateEventId(),
      title: _titleController.text,
      description: _getDescriptionOrNull(),
      startTime: startDateTime,
      endTime: endDateTime,
      isAllDay: _isAllDay,
      createdAt: widget.event?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      googleCalendarId: widget.event?.googleCalendarId,
      syncStatus: widget.event?.syncStatus ?? CalendarSyncStatus.notSynced,
      lastSyncAt: widget.event?.lastSyncAt,
      linkedTaskId: widget.event?.linkedTaskId,
    );
  }

  DateTime _createStartDateTime() {
    return _isAllDay
        ? _startDate
        : DateTime(
            _startDate.year,
            _startDate.month,
            _startDate.day,
            _startTime.hour,
            _startTime.minute,
          );
  }

  DateTime _createEndDateTime() {
    return _isAllDay
        ? DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59)
        : DateTime(
            _endDate.year,
            _endDate.month,
            _endDate.day,
            _endTime.hour,
            _endTime.minute,
          );
  }

  String _generateEventId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String? _getDescriptionOrNull() {
    return _descriptionController.text.isEmpty ? null : _descriptionController.text;
  }

  void _dispatchEventToBloc(ScheduleEvent event) {
    if (widget.event != null) {
      context.read<SchedulingBloc>().add(UpdateEvent(event: event));
    } else {
      context.read<SchedulingBloc>().add(CreateEvent(event: event));
    }
  }
}
