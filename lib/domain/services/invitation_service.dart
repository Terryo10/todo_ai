import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InvitationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  InvitationService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  // Collection references
  CollectionReference get _invitationsCollection => 
      _firestore.collection('invitations');
  
  CollectionReference get _todosCollection => 
      _firestore.collection('todos');

  // Generate a random 8-character invitation code
  String _generateInvitationCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Create an invitation for a specific todo
  Future<String> createInvitation(String todoId) async {
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
      
      // Check if user is authorized to share this todo
      if (todoData['uid'] != currentUserId && 
          !(todoData['collaborators'] as List<dynamic>).contains(currentUserId)) {
        throw Exception('Not authorized to share this todo');
      }

      // Generate a unique invitation code
      String invitationCode = _generateInvitationCode();
      bool isUnique = false;

      // Ensure the invitation code is unique
      while (!isUnique) {
        final existingInvitation = await _invitationsCollection
            .where('code', isEqualTo: invitationCode)
            .limit(1)
            .get();

        if (existingInvitation.docs.isEmpty) {
          isUnique = true;
        } else {
          invitationCode = _generateInvitationCode();
        }
      }

      // Create the invitation document
      await _invitationsCollection.doc(invitationCode).set({
        'code': invitationCode,
        'todoId': todoId,
        'createdBy': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return invitationCode;
    } catch (e) {
      debugPrint('Error creating invitation: $e');
      rethrow;
    }
  }

  // Accept an invitation and add the user as a collaborator
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

      return todoId;
    } catch (e) {
      debugPrint('Error accepting invitation: $e');
      rethrow;
    }
  }

  // Generate a shareable link using the invitation code
  String generateShareableLink(String invitationCode) {
    // This is a placeholder for your actual app link format
    // For example: https://yourtodoapp.com/join?code=ABCD1234
    return 'https://yourtodoapp.com/join?code=$invitationCode';
  }

  // Deactivate an invitation
  Future<void> deactivateInvitation(String invitationCode) async {
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
      
      // Check if user is authorized to deactivate this invitation
      if (invitationData['createdBy'] != currentUserId) {
        final todoId = invitationData['todoId'] as String;
        final todoDoc = await _todosCollection.doc(todoId).get();
        
        if (!todoDoc.exists) {
          throw Exception('Todo not found');
        }
        
        final todoData = todoDoc.data() as Map<String, dynamic>;
        
        if (todoData['uid'] != currentUserId) {
          throw Exception('Not authorized to deactivate this invitation');
        }
      }

      // Deactivate the invitation
      await _invitationsCollection.doc(invitationCode).update({
        'isActive': false,
      });
    } catch (e) {
      debugPrint('Error deactivating invitation: $e');
      rethrow;
    }
  }
}