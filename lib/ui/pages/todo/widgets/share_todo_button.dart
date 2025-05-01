// lib/ui/pages/todo/widgets/share_todo_button.dart
import 'package:flutter/material.dart';

import 'todo_invitation_dialogue.dart';

class ShareTodoButton extends StatelessWidget {
  final String todoId;
  final String todoName;

  const ShareTodoButton({
    super.key,
    required this.todoId,
    required this.todoName,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.person_add),
      tooltip: 'Invite Collaborator',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => TodoInvitationDialog(
            todoId: todoId,
            todoName: todoName,
          ),
        );
      },
    );
  }
}