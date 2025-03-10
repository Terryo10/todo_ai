import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AssigneeChip extends StatefulWidget {
  final String? assigneeId;
  final VoidCallback? onTap;
  final bool showUnassigned;

  const AssigneeChip({
    super.key,
    this.assigneeId,
    this.onTap,
    this.showUnassigned = false,
  });

  @override
  State<AssigneeChip> createState() => _AssigneeChipState();
}

class _AssigneeChipState extends State<AssigneeChip> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  String _displayName = '';
  String? _photoUrl;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  @override
  void didUpdateWidget(AssigneeChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assigneeId != widget.assigneeId) {
      _loadUserDetails();
    }
  }

  Future<void> _loadUserDetails() async {
    if (widget.assigneeId == null) {
      setState(() {
        _isLoading = false;
        _displayName = 'Unassigned';
        _photoUrl = null;
        _isCurrentUser = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _auth.currentUser;
      final isCurrentUser =
          currentUser != null && widget.assigneeId == currentUser.uid;

      if (isCurrentUser) {
        // This is the current user
        setState(() {
          _isLoading = false;
          _displayName = currentUser.displayName ?? currentUser.email ?? 'Me';
          _photoUrl = currentUser.photoURL;
          _isCurrentUser = true;
        });
      } else {
        // Load from Firestore
        final userDoc =
            await _firestore.collection('users').doc(widget.assigneeId).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null) {
            setState(() {
              _isLoading = false;
              _displayName = userData['displayName'] ??
                  userData['email'] ??
                  'Unknown User';
              _photoUrl = userData['photoURL'];
              _isCurrentUser = false;
            });
          } else {
            setState(() {
              _isLoading = false;
              _displayName = 'Unknown User';
              _photoUrl = null;
              _isCurrentUser = false;
            });
          }
        } else {
          setState(() {
            _isLoading = false;
            _displayName = 'Unknown User';
            _photoUrl = null;
            _isCurrentUser = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user details: $e');
      setState(() {
        _isLoading = false;
        _displayName = 'Not Assigned';
        _photoUrl = null;
        _isCurrentUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no assignee and not showing unassigned, return nothing
    if (widget.assigneeId == null && !widget.showUnassigned) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        avatar: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                backgroundImage:
                    _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                child: _photoUrl == null
                    ? Text(
                        _displayName.isNotEmpty
                            ? _displayName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : null,
              ),
        label: _isLoading
            ? const Text('Loading...')
            : Text(
                _isCurrentUser ? 'Me' : _displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      _isCurrentUser ? FontWeight.bold : FontWeight.normal,
                ),
              ),
        backgroundColor: _isCurrentUser
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).chipTheme.backgroundColor,
      ),
    );
  }
}
