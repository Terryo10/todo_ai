import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/model/todo_model.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _assignedTo;
  DateTime? _reminderTime;
  bool _isImportant = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                hintText: 'Enter task name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Assign To',
                hintText: 'Enter email',
              ),
              onChanged: (value) {
                setState(() {
                  _assignedTo = value.isEmpty ? null : value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Set Reminder'),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    
                    if (date != null && context.mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      
                      if (time != null) {
                        setState(() {
                          _reminderTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Text(_reminderTime != null
                    ? DateFormat.yMd().add_jm().format(_reminderTime!)
                    : 'Select Date & Time'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Important'),
                const Spacer(),
                Switch(
                  value: _isImportant,
                  onChanged: (value) {
                    setState(() {
                      _isImportant = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final task = Task(
                id: '', // Will be set when added to todo
                name: _nameController.text,
                assignedTo: _assignedTo,
                reminderTime: _reminderTime,
                isImportant: _isImportant,
              );
              Navigator.of(context).pop(task);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class AddCollaboratorDialog extends StatefulWidget {
  const AddCollaboratorDialog({super.key});

  @override
  State<AddCollaboratorDialog> createState() => _AddCollaboratorDialogState();
}

class _AddCollaboratorDialogState extends State<AddCollaboratorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Collaborator'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter collaborator\'s email',
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an email';
            }
            if (!_isValidEmail(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_emailController.text);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}