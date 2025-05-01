part of 'subscription_bloc.dart';

sealed class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionProcessing extends SubscriptionState {}

class SubscriptionPurchaseInitiated extends SubscriptionState {}

class SubscriptionPurchaseError extends SubscriptionState {
  final String message;

  const SubscriptionPurchaseError({required this.message});

  @override
  List<Object> get props => [message];
}

class SubscriptionLoaded extends SubscriptionState {
  final Subscription subscription;
  final bool? canUseAiGeneration;
  final bool? canAddCollaborator;
  final List<Map<String, dynamic>>? availablePackages;

  const SubscriptionLoaded({
    required this.subscription,
    this.canUseAiGeneration,
    this.canAddCollaborator,
    this.availablePackages,
  });

  @override
  List<Object> get props => [
        subscription,
        canUseAiGeneration ?? false,
        canAddCollaborator ?? false,
        availablePackages ?? [],
      ];

  SubscriptionLoaded copyWith({
    Subscription? subscription,
    bool? canUseAiGeneration,
    bool? canAddCollaborator,
    List<Map<String, dynamic>>? availablePackages,
  }) {
    return SubscriptionLoaded(
      subscription: subscription ?? this.subscription,
      canUseAiGeneration: canUseAiGeneration ?? this.canUseAiGeneration,
      canAddCollaborator: canAddCollaborator ?? this.canAddCollaborator,
      availablePackages: availablePackages ?? this.availablePackages,
    );
  }
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object> get props => [message];
}