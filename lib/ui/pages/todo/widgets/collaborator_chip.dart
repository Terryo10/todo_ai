import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../domain/services/invitation_service.dart';

class CollaboratorList extends StatefulWidget {
  final String todoId;
  final String ownerUid;
  final List<String> collaborators;
  final bool canManage;
  final Function? onCollaboratorsChanged;

  const CollaboratorList({
    super.key,
    required this.todoId,
    required this.ownerUid,
    required this.collaborators,
    this.canManage = false,
    this.onCollaboratorsChanged,
  });

  @override
  State<CollaboratorList> createState() => _CollaboratorListState();
}

class _CollaboratorListState extends State<CollaboratorList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _collaboratorDetails = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid;
    _loadCollaboratorDetails();
  }

  @override
  void didUpdateWidget(CollaboratorList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collaborators != widget.collaborators) {
      _loadCollaboratorDetails();
    }
  }

  Future<void> _loadCollaboratorDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> details = [];

      // Add the owner
      final ownerDoc =
          await _firestore.collection('users').doc(widget.ownerUid).get();
      if (ownerDoc.exists) {
        final ownerData = ownerDoc.data();
        if (ownerData != null) {
          details.add({
            'id': widget.ownerUid,
            'name': ownerData['displayName'] ?? ownerData['email'] ?? 'Owner',
            'email': ownerData['email'] ?? '',
            'photoUrl': ownerData['photoURL'],
            'isOwner': true,
            'isCurrentUser': widget.ownerUid == _currentUserId,
          });
        }
      }

      // Add collaborators
      for (final collaboratorId in widget.collaborators) {
        // Skip if this is the owner (already added)
        if (collaboratorId == widget.ownerUid) continue;

        final userDoc =
            await _firestore.collection('users').doc(collaboratorId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null) {
            details.add({
              'id': collaboratorId,
              'name': userData['displayName'] ??
                  userData['email'] ??
                  'Collaborator',
              'email': userData['email'] ?? '',
              'photoUrl': userData['photoURL'],
              'isOwner': false,
              'isCurrentUser': collaboratorId == _currentUserId,
            });
          }
        }
      }

      setState(() {
        _collaboratorDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading collaborator details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeCollaborator(String collaboratorId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update the todo document to remove this collaborator
      await _firestore.collection('todos').doc(widget.todoId).update({
        'collaborators': FieldValue.arrayRemove([collaboratorId]),
      });

      // Remove from local state
      setState(() {
        _collaboratorDetails.removeWhere((c) => c['id'] == collaboratorId);
        _isLoading = false;
      });

      // Notify parent if callback provided
      if (widget.onCollaboratorsChanged != null) {
        widget.onCollaboratorsChanged!();
      }
    } catch (e) {
      debugPrint('Error removing collaborator: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing collaborator: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showInviteDialog() async {
    // Show a loading indicator
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Generating invitation link...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      // Get the invitation service
      final invitationService = InvitationService(
        firestore: _firestore,
        auth: _auth,
      );

      // Generate invitation code
      final invitationCode =
          await invitationService.createInvitation(widget.todoId);

      // Create shareable link
      final shareableLink =
          invitationService.generateShareableLink(invitationCode);

      // Show dialog with the link
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invite Collaborators'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share this link with others to collaborate on this Todo:',
                ),
                const SizedBox(height: 16),
                Container(
                  // padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          shareableLink,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: shareableLink));
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Link copied to clipboard'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        tooltip: 'Copy link',
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CLOSE'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('SHARE'),
                onPressed: () async {
                  await Share.share(
                    'Join this Todo on TodoAI: $shareableLink',
                    subject: 'TodoAI Collaboration Invitation',
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error creating invitation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Collaborators',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.canManage)
                TextButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Invite'),
                  onPressed: _showInviteDialog,
                ),
            ],
          ),
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (_collaboratorDetails.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'No collaborators yet',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _collaboratorDetails.length,
            itemBuilder: (context, index) {
              final collaborator = _collaboratorDetails[index];
              final bool isCurrentUser = collaborator['isCurrentUser'] == true;
              final bool isOwner = collaborator['isOwner'] == true;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isOwner
                      ? Colors.amber.withOpacity(0.2)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  backgroundImage: collaborator['photoUrl'] != null
                      ? NetworkImage(collaborator['photoUrl'])
                      : null,
                  child: collaborator['photoUrl'] == null
                      ? Text(
                          collaborator['name'][0].toUpperCase(),
                          style: TextStyle(
                            color: isOwner
                                ? Colors.amber.shade800
                                : Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : null,
                ),
                title: Row(
                  children: [
                    Text(
                      collaborator['name'],
                      style: TextStyle(
                        fontWeight: isCurrentUser || isOwner
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isCurrentUser)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (isOwner)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Owner',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  collaborator['email'],
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                trailing: widget.canManage &&
                        !isCurrentUser &&
                        !isOwner &&
                        _currentUserId == widget.ownerUid
                    ? IconButton(
                        icon: const Icon(Icons.person_remove),
                        tooltip: 'Remove collaborator',
                        onPressed: () async {
                          // Show confirmation dialog
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Remove Collaborator'),
                              content: Text(
                                'Are you sure you want to remove ${collaborator['name']} from this Todo?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('CANCEL'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('REMOVE'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await _removeCollaborator(collaborator['id']);
                          }
                        },
                      )
                    : null,
              );
            },
          ),
      ],
    );
  }
}
