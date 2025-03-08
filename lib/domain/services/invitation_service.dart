import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/todo_invitation.dart';
import '../model/todo_model.dart';
import '../model/user_model.dart';

class InvitationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Generate a share link for a todo
  Future<String> createShareLink(String todoId, UserModel currentUser, {String? targetEmail}) async {
    // Check if user is owner or collaborator
    final todoDoc = await _firestore.collection('todos').doc(todoId).get();
    if (!todoDoc.exists) {
      throw Exception('Todo not found');
    }
    
    final todo = Todo.fromMap(todoDoc.data()!);
    
    // Check if user has permission to share
    if (todo.uid != currentUser.uid && !todo.collaborators.contains(currentUser.uid)) {
      throw Exception('You do not have permission to share this todo');
    }
    
    // Create invitation
    final invitation = await TodoInvitation.create(
      todoId: todoId,
      inviterUid: currentUser.uid,
      email: targetEmail,
    );
    
    return invitation.sharingUrl;
  }
  
  // Process an invitation when someone opens the link
  Future<Todo> acceptInvitation(String token, UserModel currentUser) async {
    // Get the invitation
    final invitationDoc = await _firestore.collection('invitations').doc(token).get();
    
    if (!invitationDoc.exists) {
      throw Exception('Invalid invitation link');
    }
    
    final invitation = TodoInvitation.fromMap(invitationDoc.data()!);
    
    // Check if invitation is valid
    if (!invitation.isValid) {
      throw Exception('Invitation has expired or already been used');
    }
    
    // Check if email-specific invitation
    if (invitation.email != null && invitation.email != currentUser.email) {
      throw Exception('This invitation is for another email address');
    }
    
    // Get the todo
    final todoDoc = await _firestore.collection('todos').doc(invitation.todoId).get();
    
    if (!todoDoc.exists) {
      throw Exception('The shared todo no longer exists');
    }
    
    final todo = Todo.fromMap(todoDoc.data()!);
    
    // Check if user is already a collaborator
    if (todo.collaborators.contains(currentUser.uid)) {
      await invitation.markAsUsed();
      return todo;
    }
    
    // Add user to collaborators
    final updatedCollaborators = List<String>.from(todo.collaborators)..add(currentUser.uid);
    
    await _firestore.collection('todos').doc(todo.id).update({
      'collaborators': updatedCollaborators,
    });
    
    // Mark invitation as used
    await invitation.markAsUsed();
    
    // Return updated todo
    return todo.copyWith(collaborators: updatedCollaborators);
  }
  
  // Get invitation info (for displaying info before accepting)
  Future<Map<String, dynamic>> getInvitationInfo(String token) async {
    final invitationDoc = await _firestore.collection('invitations').doc(token).get();
    
    if (!invitationDoc.exists) {
      throw Exception('Invalid invitation link');
    }
    
    final invitation = TodoInvitation.fromMap(invitationDoc.data()!);
    
    if (!invitation.isValid) {
      throw Exception('Invitation has expired or already been used');
    }
    
    // Get todo details
    final todoDoc = await _firestore.collection('todos').doc(invitation.todoId).get();
    if (!todoDoc.exists) {
      throw Exception('The shared todo no longer exists');
    }
    
    final todo = Todo.fromMap(todoDoc.data()!);
    
    // Get inviter details
    final inviterDoc = await _firestore.collection('users').doc(invitation.inviterUid).get();
    final inviter = inviterDoc.exists 
        ? UserModel.fromMap(inviterDoc.data()!) 
        : null;
    
    return {
      'todo': {
        'name': todo.name,
        'taskCount': todo.tasks.length,
      },
      'inviter': {
        'displayName': inviter?.displayName ?? 'A user',
        'email': inviter?.email,
      },
      'expiresAt': invitation.expiresAt,
    };
  }
}