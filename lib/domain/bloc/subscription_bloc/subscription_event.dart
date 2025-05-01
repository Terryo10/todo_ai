part of 'subscription_bloc.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class InitializeRevenueCat extends SubscriptionEvent {
  final String userId;
  
  const InitializeRevenueCat({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

class LoadSubscription extends SubscriptionEvent {
  final String userId;
  
  const LoadSubscription({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

class LoadAvailablePackages extends SubscriptionEvent {
  final String userId;
  
  const LoadAvailablePackages({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

class PurchasePackage extends SubscriptionEvent {
  final String userId;
  final String packageIdentifier;
  
  const PurchasePackage({
    required this.userId,
    required this.packageIdentifier,
  });
  
  @override
  List<Object> get props => [userId, packageIdentifier];
}

class RestorePurchases extends SubscriptionEvent {
  final String userId;
  
  const RestorePurchases({required this.userId});
  
  @override
  List<Object> get props => [userId];
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