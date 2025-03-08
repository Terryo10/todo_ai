// invitation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class TodoInvitation {
  final String id;
  final String todoId;
  final String inviterUid;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? email;
  final bool isUsed;

  TodoInvitation({
    required this.id,
    required this.todoId,
    required this.inviterUid,
    required this.createdAt,
    required this.expiresAt,
    this.email,
    this.isUsed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todoId': todoId,
      'inviterUid': inviterUid,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'email': email,
      'isUsed': isUsed,
    };
  }

  factory TodoInvitation.fromMap(Map<String, dynamic> map) {
    return TodoInvitation(
      id: map['id'],
      todoId: map['todoId'],
      inviterUid: map['inviterUid'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      email: map['email'],
      isUsed: map['isUsed'] ?? false,
    );
  }

  // Generate a new invitation
  static Future<TodoInvitation> create({
    required String todoId,
    required String inviterUid,
    String? email,
    Duration validity = const Duration(days: 7),
  }) async {
    final String token = const Uuid().v4();
    final now = DateTime.now();
    
    final invitation = TodoInvitation(
      id: token,
      todoId: todoId,
      inviterUid: inviterUid,
      createdAt: now,
      expiresAt: now.add(validity),
      email: email,
      isUsed: false,
    );
    
    // Store in Firestore
    await FirebaseFirestore.instance
        .collection('invitations')
        .doc(token)
        .set(invitation.toMap());
    
    return invitation;
  }
  
  // Get sharing URL
  String get sharingUrl {
    return 'https://yourtodoapp.com/invite?token=$id';
  }
  
  // Check if invitation is valid
  bool get isValid {
    final now = DateTime.now();
    return !isUsed && now.isBefore(expiresAt);
  }
  
  // Mark as used
  Future<void> markAsUsed() async {
    await FirebaseFirestore.instance
        .collection('invitations')
        .doc(id)
        .update({'isUsed': true});
  }
}