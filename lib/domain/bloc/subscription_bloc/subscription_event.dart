part of 'subscription_bloc.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscription extends SubscriptionEvent {
  final String userId;
  
  const LoadSubscription({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

class PurchaseSubscription extends SubscriptionEvent {
  final String userId;
  final SubscriptionPlan plan;
  
  const PurchaseSubscription({
    required this.userId,
    required this.plan,
  });
  
  @override
  List<Object> get props => [userId, plan];
}

class SubscriptionPurchaseCompleted extends SubscriptionEvent {
  final String userId;
  final String purchaseId;
  final SubscriptionPlan plan;
  
  const SubscriptionPurchaseCompleted({
    required this.userId,
    required this.purchaseId,
    required this.plan,
  });
  
  @override
  List<Object> get props => [userId, purchaseId, plan];
}

class CancelSubscription extends SubscriptionEvent {
  final String userId;
  final String subscriptionId;
  
  const CancelSubscription({
    required this.userId, 
    required this.subscriptionId,
  });
  
  @override
  List<Object> get props => [userId, subscriptionId];
}

class CheckAiGenerationAvailability extends SubscriptionEvent {
  final String userId;
  
  const CheckAiGenerationAvailability({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

class CheckCollaboratorAvailability extends SubscriptionEvent {
  final String userId;
  final String todoId;
  final int currentCollaboratorsCount;
  
  const CheckCollaboratorAvailability({
    required this.userId,
    required this.todoId,
    required this.currentCollaboratorsCount,
  });
  
  @override
  List<Object> get props => [userId, todoId, currentCollaboratorsCount];
}

class UpdateAiUsage extends SubscriptionEvent {
  final String userId;
  
  const UpdateAiUsage({required this.userId});
  
  @override
  List<Object> get props => [userId];
}
