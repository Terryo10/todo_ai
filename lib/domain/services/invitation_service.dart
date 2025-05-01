// lib/domain/services/invitation_service.dart
// Modify the existing service to send notifications instead of generating links

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/notifications_model.dart';
import '../repositories/notification_repository/notification_repository.dart';

class InvitationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NotificationRepository _notificationRepository;

  InvitationService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required NotificationRepository notificationRepository,
  })  : _firestore = firestore,
        _auth = auth,
        _notificationRepository = notificationRepository;

  // Collection references
  CollectionReference get _invitationsCollection => 
      _firestore.collection('invitations');
  
  CollectionReference get _todosCollection => 
      _firestore.collection('todos');

  // Generate a random 8-character invitation code
  String _generateInvitationCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Create an invitation and send it as a notification
  Future<void> inviteUser({
    required String todoId,
    required String email, // Email of the user to invite
  }) async {
    try {
      // Check if the current user is the owner or a collaborator of the todo
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get the todo
      final todoDoc = await _todosCollection.doc(todoId).get();
      if (!todoDoc.exists) {
        throw Exception('Todo not found');
      }

      final todoData = todoDoc.data() as Map<String, dynamic>;
      final todoName = todoData['name'] as String;
      
      // Check if user is authorized to share this todo
      if (todoData['uid'] != currentUserId && 
          !(todoData['collaborators'] as List<dynamic>).contains(currentUserId)) {
        throw Exception('Not authorized to share this todo');
      }

      // Find the user with the given email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('User with this email not found');
      }

      final recipientId = userQuery.docs.first.id;
      
      // Check if already a collaborator
      if ((todoData['collaborators'] as List<dynamic>).contains(recipientId) ||
          todoData['uid'] == recipientId) {
        throw Exception('User is already a collaborator');
      }
      
      // Get inviter's display name
      final inviterDoc = await _firestore.collection('users').doc(currentUserId).get();
      final inviterName = inviterDoc.exists 
          ? (inviterDoc.data() as Map<String, dynamic>)['displayName'] ?? 'Someone'
          : 'Someone';

      // Generate invitation code
      final invitationCode = _generateInvitationCode();
      
      // Create the invitation document
      await _invitationsCollection.doc(invitationCode).set({
        'code': invitationCode,
        'todoId': todoId,
        'todoName': todoName,
        'inviterUid': currentUserId,
        'recipientUid': recipientId,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Send a notification to the recipient
      await _notificationRepository.createNotification(
        userId: recipientId,
        title: 'New Todo Invitation',
        body: '$inviterName invited you to collaborate on "$todoName"',
        type: NotificationType.todoInvitation,
        data: {
          'invitationCode': invitationCode,
          'todoId': todoId,
          'todoName': todoName,
          'inviterId': currentUserId,
          'inviterName': inviterName,
        },
      );
    } catch (e) {
      debugPrint('Error creating invitation: $e');
      rethrow;
    }
  }

  // Accept an invitation via notification
  Future<String> acceptInvitation(String invitationCode) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get the invitation
      final invitationDoc = await _invitationsCollection.doc(invitationCode).get();
      
      if (!invitationDoc.exists) {
        throw Exception('Invitation not found');
      }

      final invitationData = invitationDoc.data() as Map<String, dynamic>;
      
      // Check if invitation is active
      if (invitationData['isActive'] != true) {
        throw Exception('Invitation is no longer active');
      }
      
      // Verify invitation is for this user
      if (invitationData['recipientUid'] != currentUserId) {
        throw Exception('This invitation is not for you');
      }

      final todoId = invitationData['todoId'] as String;

      // Get the todo
      final todoDoc = await _todosCollection.doc(todoId).get();
      if (!todoDoc.exists) {
        // Mark invitation as inactive if the todo doesn't exist
        await _invitationsCollection.doc(invitationCode).update({
          'isActive': false,
        });
        throw Exception('Todo not found');
      }

      final todoData = todoDoc.data() as Map<String, dynamic>;
      List<dynamic> collaborators = List.from(todoData['collaborators'] ?? []);

      // Check if user is already a collaborator
      if (todoData['uid'] == currentUserId || collaborators.contains(currentUserId)) {
        return todoId; // User is already owner or collaborator
      }

      // Add user as collaborator
      collaborators.add(currentUserId);
      await _todosCollection.doc(todoId).update({
        'collaborators': collaborators,
      });
      
      // Mark invitation as used
      await _invitationsCollection.doc(invitationCode).update({
        'isActive': false,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to todo owner
      await _notificationRepository.createNotification(
        userId: todoData['uid'],
        title: 'Invitation Accepted',
        body: '${_auth.currentUser?.displayName ?? "Someone"} accepted your invitation to collaborate on "${todoData['name']}"',
        type: NotificationType.other,
        data: {
          'todoId': todoId,
          'type': 'invitation_accepted',
        },
      );

      return todoId;
    } catch (e) {
      debugPrint('Error accepting invitation: $e');
      rethrow;
    }
  }

  // Decline an invitation
  Future<void> declineInvitation(String invitationCode) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get the invitation
      final invitationDoc = await _invitationsCollection.doc(invitationCode).get();
      
      if (!invitationDoc.exists) {
        throw Exception('Invitation not found');
      }

      final invitationData = invitationDoc.data() as Map<String, dynamic>;
      
      // Verify invitation is for this user
      if (invitationData['recipientUid'] != currentUserId) {
        throw Exception('This invitation is not for you');
      }

      // Mark invitation as declined
      await _invitationsCollection.doc(invitationCode).update({
        'isActive': false,
        'declined': true,
        'declinedAt': FieldValue.serverTimestamp(),
      });

      // Optional: Send notification to inviter
      final inviterId = invitationData['inviterUid'];
      final todoName = invitationData['todoName'];
      
      await _notificationRepository.createNotification(
        userId: inviterId,
        title: 'Invitation Declined',
        body: '${_auth.currentUser?.displayName ?? "Someone"} declined your invitation to collaborate on "$todoName"',
        type: NotificationType.other,
        data: {
          'todoId': invitationData['todoId'],
          'type': 'invitation_declined',
        },
      );
    } catch (e) {
      debugPrint('Error declining invitation: $e');
      rethrow;
    }
  }
}