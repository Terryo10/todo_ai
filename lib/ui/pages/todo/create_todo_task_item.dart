
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/model/todo_model.dart';

class CreateTodoTaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;

  const CreateTodoTaskListItem({
    super.key,
    required this.task,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.assignedTo != null) Text('Assigned to: ${task.assignedTo}'),
          if (task.reminderTime != null)
            Text(
                'Reminder: ${DateFormat.yMMMd().add_jm().format(task.reminderTime!)}'),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
      leading:
          task.isImportant ? const Icon(Icons.star, color: Colors.amber) : null,
    );
  }
}
