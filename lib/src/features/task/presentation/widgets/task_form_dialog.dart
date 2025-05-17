import 'package:flutter/material.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/data/models/task_data_model.dart';

class TaskFormDialog extends StatefulWidget {
  final void Function(Task) onSubmit;
  final Task? initialTask;

  const TaskFormDialog({super.key, required this.onSubmit, this.initialTask});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String description;
  late DateTime? dueDate;
  late TaskImportance importance;

  @override
  void initState() {
    super.initState();
    name = widget.initialTask?.name ?? '';
    description = widget.initialTask?.description ?? '';
    dueDate = widget.initialTask?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    importance = widget.initialTask?.importance ?? TaskImportance.medium;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialTask == null ? 'Add Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.isEmpty ? 'Enter a name' : null,
                onSaved: (value) => name = value ?? '',
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value ?? '',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Due Date:'),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: dueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          dueDate = picked;
                        });
                      }
                    },
                    child: Text(dueDate != null ? '${dueDate!.toLocal()}'.split(' ')[0] : 'Select'),
                  ),
                ],
              ),
              DropdownButtonFormField<TaskImportance>(
                value: importance,
                decoration: const InputDecoration(labelText: 'Importance'),
                items: TaskImportance.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => importance = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              final taskToSubmit = Task(
                id: widget.initialTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                description: description,
                completed: widget.initialTask?.completed ?? false,
                dueDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
                importance: importance,
                createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );
              widget.onSubmit(taskToSubmit);
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.initialTask == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
