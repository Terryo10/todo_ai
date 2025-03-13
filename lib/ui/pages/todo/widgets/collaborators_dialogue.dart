  import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/bloc/todo_bloc/todo_bloc.dart';
import '../../../../domain/model/todo_model.dart';
import 'collaborator_chip.dart';

Future<void> showCollaboratorsDialog(BuildContext context, Todo todo) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Collaborators',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  child: CollaboratorList(
                    todoId: todo.id,
                    ownerUid: todo.uid,
                    collaborators: todo.collaborators,
                    canManage:
                        todo.uid == FirebaseAuth.instance.currentUser?.uid,
                    onCollaboratorsChanged: () {
                      // Refresh the todo data if needed
                      context.read<TodoBloc>().add(LoadTodos());
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
