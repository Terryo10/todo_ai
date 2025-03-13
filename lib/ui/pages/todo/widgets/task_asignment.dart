import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_ai/domain/bloc/todo_bloc/todo_bloc.dart';

class TaskAssignmentDialog extends StatefulWidget {
  final String todoId;
  final String taskId;
  final String taskName;
  final String? currentAssignee;
  final List<String> collaborators;

  const TaskAssignmentDialog({
    super.key,
    required this.todoId,
    required this.taskId,
    required this.taskName,
    this.currentAssignee,
    required this.collaborators,
  });

  @override
  State<TaskAssignmentDialog> createState() => _TaskAssignmentDialogState();
}

class _TaskAssignmentDialogState extends State<TaskAssignmentDialog> {
  String? _selectedUserId;
  bool _isLoading = true;
  final List<Map<String, dynamic>> _collaboratorDetails = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.currentAssignee;
    _loadCollaboratorDetails();
  }

  Future<void> _loadCollaboratorDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Add the current user to the list
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        _collaboratorDetails.add({
          'id': currentUser.uid,
          'name': currentUser.displayName ?? currentUser.email ?? 'Me',
          'email': currentUser.email ?? '',
          'photoUrl': currentUser.photoURL,
          'isCurrentUser': true,
        });
      }

      // Load collaborator details from Firestore
      for (final collaboratorId in widget.collaborators) {
        // Skip if this is the current user
        if (currentUser != null && collaboratorId == currentUser.uid) {
          continue;
        }

        final userDoc =
            await _firestore.collection('users').doc(collaboratorId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null) {
            _collaboratorDetails.add({
              'id': collaboratorId,
              'name': userData['displayName'] ??
                  userData['email'] ??
                  'Unknown User',
              'email': userData['email'] ?? '',
              'photoUrl': userData['photoURL'],
              'isCurrentUser': false,
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading collaborator details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Task: ${widget.taskName}',
          style: TextStyle(fontSize: 16)),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select a collaborator to assign this task:'),
                  const SizedBox(height: 16),
                  if (_collaboratorDetails.isEmpty) ...[
                    const Center(
                      child: Text(
                        'No collaborators available',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ] else ...[
                    // Option to unassign
                    RadioListTile<String?>(
                      title: const Text('Unassigned'),
                      value: null,
                      groupValue: _selectedUserId,
                      onChanged: (value) {
                        setState(() {
                          _selectedUserId = value;
                        });
                      },
                    ),
                    const Divider(),
                    ..._collaboratorDetails.map((collaborator) {
                      return RadioListTile<String>(
                        title: Text(
                          collaborator['name'],
                          style: collaborator['isCurrentUser']
                              ? const TextStyle(fontWeight: FontWeight.bold)
                              : null,
                        ),
                        subtitle: Text(collaborator['email']),
                        value: collaborator['id'],
                        groupValue: _selectedUserId,
                        onChanged: (value) {
                          setState(() {
                            _selectedUserId = value;
                          });
                        },
                        secondary: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          backgroundImage: collaborator['photoUrl'] != null
                              ? NetworkImage(collaborator['photoUrl'])
                              : null,
                          child: collaborator['photoUrl'] == null
                              ? Text(
                                  collaborator['name'][0].toUpperCase(),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              : null,
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  // Dispatch event to assign task
                  context.read<TodoBloc>().add(
                        AssignTask(
                          todoId: widget.todoId,
                          taskId: widget.taskId,
                          userId: _selectedUserId,
                        ),
                      );
                  Navigator.of(context).pop();
                },
          child: const Text('ASSIGN'),
        ),
      ],
    );
  }
}

// Helper method to show the dialog
Future<void> showTaskAssignmentDialog(
  BuildContext context, {
  required String todoId,
  required String taskId,
  required String taskName,
  String? currentAssignee,
  required List<String> collaborators,
}) {
  return showDialog(
    context: context,
    builder: (context) => TaskAssignmentDialog(
      todoId: todoId,
      taskId: taskId,
      taskName: taskName,
      currentAssignee: currentAssignee,
      collaborators: collaborators,
    ),
  );
}
