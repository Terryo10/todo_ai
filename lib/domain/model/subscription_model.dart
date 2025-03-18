import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionPlan {
  free,
  monthly,
  annual
}

extension SubscriptionPlanExtension on SubscriptionPlan {
  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.monthly:
        return 'Monthly Premium';
      case SubscriptionPlan.annual:
        return 'Annual Premium';
    }
  }

  double get price {
    switch (this) {
      case SubscriptionPlan.free:
        return 0.0;
      case SubscriptionPlan.monthly:
        return 4.99;
      case SubscriptionPlan.annual:
        return 49.99;
    }
  }
}

class Subscription {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final DateTime startDate;
  final DateTime endDate;
  final String? paymentId;
  final bool isActive;
  final int aiTaskGenerationsRemaining; // For free users with limited generations
  final int maxCollaborators; // Limit for collaborators per todo

  Subscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.startDate,
    required this.endDate,
    this.paymentId,
    this.isActive = true,
    this.aiTaskGenerationsRemaining = 0,
    this.maxCollaborators = 1,
  });

  int get remainingDays {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  bool get isValid {
    return isActive && DateTime.now().isBefore(endDate);
  }

  // Calculate limits based on subscription plan
  int get maxGenerationsPerMonth {
    switch (plan) {
      case SubscriptionPlan.free:
        return 5;
      case SubscriptionPlan.monthly:
        return 100;
      case SubscriptionPlan.annual:
        return 500;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'plan': plan.toString().split('.').last,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'paymentId': paymentId,
      'isActive': isActive,
      'aiTaskGenerationsRemaining': aiTaskGenerationsRemaining,
      'maxCollaborators': maxCollaborators,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      plan: _planFromString(map['plan'] ?? 'free'),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      paymentId: map['paymentId'],
      isActive: map['isActive'] ?? false,
      aiTaskGenerationsRemaining: map['aiTaskGenerationsRemaining'] ?? 0,
      maxCollaborators: map['maxCollaborators'] ?? 1,
    );
  }

  static SubscriptionPlan _planFromString(String plan) {
    switch (plan) {
      case 'monthly':
        return SubscriptionPlan.monthly;
      case 'annual':
        return SubscriptionPlan.annual;
      default:
        return SubscriptionPlan.free;
    }
  }

  // Create a default free subscription for new users
  factory Subscription.createFree(String userId) {
    final now = DateTime.now();
    // Free plan is valid for a very long time (10 years)
    final endDate = now.add(const Duration(days: 3650));
    
    return Subscription(
      id: 'free_${userId}_${now.millisecondsSinceEpoch}',
      userId: userId,
      plan: SubscriptionPlan.free,
      startDate: now,
      endDate: endDate,
      isActive: true,
      aiTaskGenerationsRemaining: 5, // Start with 5 free generations
      maxCollaborators: 1, // Free users can have 1 collaborator per todo
    );
  }

  Subscription copyWith({
    String? id,
    String? userId,
    SubscriptionPlan? plan,
    DateTime? startDate,
    DateTime? endDate,
    String? paymentId,
    bool? isActive,
    int? aiTaskGenerationsRemaining,
    int? maxCollaborators,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentId: paymentId ?? this.paymentId,
      isActive: isActive ?? this.isActive,
      aiTaskGenerationsRemaining: aiTaskGenerationsRemaining ?? this.aiTaskGenerationsRemaining,
      maxCollaborators: maxCollaborators ?? this.maxCollaborators,
    );
  }
}