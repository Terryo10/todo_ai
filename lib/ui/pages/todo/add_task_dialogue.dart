import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/model/todo_model.dart';

class AddTaskDialog extends StatefulWidget {
  final String todoId;

  const AddTaskDialog({
    super.key,
    required this.todoId,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _reminderTime;
  bool _isImportant = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getReminderDescription() {
    if (_reminderTime == null) return 'No reminder set';

    final now = DateTime.now();
    final difference = _reminderTime!.difference(now);

    if (difference.inDays > 0) {
      return 'In ${difference.inDays} day${difference.inDays != 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours != 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''}';
    }

    return 'Reminder set for now';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create a New Task',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Task Name',
                      hintText: 'What needs to be done?',
                      prefixIcon: const Icon(Icons.task_alt_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task name';
                      }
                      return null;
                    }),
          
                const SizedBox(height: 24),
          
                // Reminder Section with Creative Touch
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.alarm, color: Colors.deepPurple),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _getReminderDescription(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
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
                          child: Text(
                            _reminderTime != null
                                ? DateFormat('MMM d, h:mm a')
                                    .format(_reminderTime!)
                                : 'Set Reminder',
                            style: const TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          
                const SizedBox(height: 24),
          
                // Important Task Section with Creative Design
                Row(
                  children: [
                    const Text(
                      'Priority Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: _isImportant
                            ? Colors.deepPurple.shade100
                            : Colors.grey.shade200,
                      ),
                      child: Switch(
                        value: _isImportant,
                        activeColor: Colors.deepPurple,
                        activeTrackColor: Colors.deepPurple.shade100,
                        onChanged: (value) {
                          setState(() {
                            _isImportant = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
          
                const SizedBox(height: 24),
          
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final task = Task(
                              id: const Uuid().v4(),
                              todoId: widget.todoId,
                              name: _nameController.text,
                              reminderTime: _reminderTime,
                              isImportant: _isImportant,
                            );
                            Navigator.of(context).pop(task);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Add Task'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
