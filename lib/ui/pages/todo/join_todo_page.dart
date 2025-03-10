import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_ai/domain/bloc/auth_bloc/auth_bloc.dart';
import 'package:todo_ai/domain/bloc/todo_bloc/todo_bloc.dart';

import '../../../domain/services/invitation_service.dart';

@RoutePage()
class JoinTodoPage extends StatefulWidget {
  final String? invitationCode;

  const JoinTodoPage({
    super.key,
    @QueryParam('code') this.invitationCode,
  });

  @override
  State<JoinTodoPage> createState() => _JoinTodoPageState();
}

class _JoinTodoPageState extends State<JoinTodoPage> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _todoId;

  @override
  void initState() {
    super.initState();
    _processInvitation();
  }

  Future<void> _processInvitation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if invitationCode is provided
      if (widget.invitationCode == null || widget.invitationCode!.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid invitation code';
        });
        return;
      }

      // Check if user is authenticated
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticatedState) {
        // Save the invitation code to process after login
        // This could be saved in secure storage or another state management solution
        // For simplicity, we'll just show an error for now
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please login to join this todo';
        });
        return;
      }

      // Process the invitation
      final invitationService = context.read<InvitationService>();
      final todoId = await invitationService.acceptInvitation(widget.invitationCode!);
      
      // Update local state
      setState(() {
        _isLoading = false;
        _todoId = todoId;
      });
      
      // Refresh todos in TodoBloc
      context.read<TodoBloc>().add(LoadTodos());
      
      // Navigate to the todo detail page
      if (mounted) {
        // Using AutoRouter, navigate to the todo detail
        context.router.replaceNamed('/todo/$todoId');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error joining todo: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Todo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processing invitation...'),
                  ],
                )
              : _errorMessage != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.router.pushNamed('/login'),
                          child: const Text('Go to Login'),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Successfully joined the todo!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (_todoId != null) {
                              context.router.pushNamed('/todo/$_todoId');
                            } else {
                              context.router.pushNamed('/todos');
                            }
                          },
                          child: const Text('View Todo'),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}