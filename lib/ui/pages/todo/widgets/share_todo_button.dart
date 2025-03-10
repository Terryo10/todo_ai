import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../domain/services/invitation_service.dart';

class ShareTodoButton extends StatefulWidget {
  final String todoId;
  final InvitationService invitationService;

  const ShareTodoButton({
    Key? key,
    required this.todoId,
    required this.invitationService,
  }) : super(key: key);

  @override
  State<ShareTodoButton> createState() => _ShareTodoButtonState();
}

class _ShareTodoButtonState extends State<ShareTodoButton> {
  bool _isLoading = false;

  Future<void> _shareLink() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Generate invitation code
      final invitationCode = await widget.invitationService.createInvitation(widget.todoId);
      
      // Create shareable link
      final shareableLink = widget.invitationService.generateShareableLink(invitationCode);
      
      // Share the link
      await Share.share(
        'Join this Todo on TodoAI: $shareableLink',
        subject: 'TodoAI Collaboration Invitation',
      );
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing todo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isLoading 
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.share),
      onPressed: _isLoading ? null : _shareLink,
      tooltip: 'Share Todo',
    );
  }
}

// Optional separate widget for displaying a more elaborate share dialog
class ShareTodoDialog extends StatefulWidget {
  final String todoId;
  final String todoName;
  final InvitationService invitationService;

  const ShareTodoDialog({
    Key? key,
    required this.todoId,
    required this.todoName,
    required this.invitationService,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String todoId,
    required String todoName,
    required InvitationService invitationService,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ShareTodoDialog(
        todoId: todoId,
        todoName: todoName,
        invitationService: invitationService,
      ),
    );
  }

  @override
  State<ShareTodoDialog> createState() => _ShareTodoDialogState();
}

class _ShareTodoDialogState extends State<ShareTodoDialog> {
  bool _isLoading = false;
  String? _invitationLink;

  @override
  void initState() {
    super.initState();
    _generateLink();
  }

  Future<void> _generateLink() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Generate invitation code
      final invitationCode = await widget.invitationService.createInvitation(widget.todoId);
      
      // Create shareable link
      final shareableLink = widget.invitationService.generateShareableLink(invitationCode);
      
      setState(() {
        _invitationLink = shareableLink;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _shareLink() async {
    if (_invitationLink == null) return;
    
    await Share.share(
      'Join this Todo on TodoAI: $_invitationLink',
      subject: 'TodoAI Collaboration Invitation',
    );
  }

  Future<void> _copyLink() async {
    if (_invitationLink == null) return;
    
    await Clipboard.setData(ClipboardData(text: _invitationLink!));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Share "${widget.todoName}"'),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Share this link with others to collaborate on this Todo:',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _invitationLink ?? '',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: _copyLink,
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
          child: const Text('CANCEL'),
        ),
        if (!_isLoading && _invitationLink != null)
          ElevatedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('SHARE'),
            onPressed: () {
              _shareLink();
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }
}