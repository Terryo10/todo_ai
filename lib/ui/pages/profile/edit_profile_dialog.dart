import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_ai/domain/bloc/edit_profile_bloc/edit_profile_bloc.dart';

import '../../../domain/bloc/auth_bloc/auth_bloc.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String displayName = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void init() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticatedState) {
      setState(() {
        displayName = authState.displayName;
        _nameController.text = authState.displayName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Profie',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Change Display Name',
                  hintText: 'Edit display name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.verified_user),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your display name';
                  }
                  return null;
                },
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticatedState) {
                        return ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<EditProfileBloc>().add(EditProfile(
                                    userId: state.userId,
                                    displayName: _nameController.text,
                                  ));

                              Navigator.of(context).pop(true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              BlocListener<EditProfileBloc, EditProfileState>(
                            listener: (context, state) {
                              if (state is EditProfileErrorState) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.message),
                                    behavior: SnackBarBehavior
                                        .floating, // Makes it appear as a bottom sheet
                                    backgroundColor: Colors
                                        .red, // Highlighting it as an error
                                  ),
                                );
                              } else if (state is EditProfileLoadedState) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.message),
                                    behavior: SnackBarBehavior
                                        .floating, // Makes it appear as a bottom sheet
                                    backgroundColor: Colors
                                        .green, // Highlighting it as an error
                                  ),
                                );
                              }
                            },
                            child:
                                BlocBuilder<EditProfileBloc, EditProfileState>(
                              builder: (context, state) {
                                if (state is EditProfileLoadingState) {
                                  return const Text('Updating Profile');
                                }
                                return const Text('Save Profile');
                              },
                            ),
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
