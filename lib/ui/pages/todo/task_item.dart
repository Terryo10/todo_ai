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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (task.isImportant)
                  const Icon(Icons.star, color: Colors.amber),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: Colors.red,
                ),
              ],
            ),
            if (task.assignedTo != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    task.assignedTo!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            if (task.reminderTime != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat.yMMMd().add_jm().format(task.reminderTime!),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}