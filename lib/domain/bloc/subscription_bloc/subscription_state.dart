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

class SubscriptionLoaded extends SubscriptionState {
  final Subscription subscription;
  final bool? canUseAiGeneration;
  final bool? canAddCollaborator;

  const SubscriptionLoaded({
    required this.subscription,
    this.canUseAiGeneration,
    this.canAddCollaborator,
  });

  @override
  List<Object> get props => [
        subscription,
        canUseAiGeneration ?? false,
        canAddCollaborator ?? false,
      ];

  SubscriptionLoaded copyWith({
    Subscription? subscription,
    bool? canUseAiGeneration,
    bool? canAddCollaborator,
  }) {
    return SubscriptionLoaded(
      subscription: subscription ?? this.subscription,
      canUseAiGeneration: canUseAiGeneration ?? this.canUseAiGeneration,
      canAddCollaborator: canAddCollaborator ?? this.canAddCollaborator,
    );
  }
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object> get props => [message];
}
