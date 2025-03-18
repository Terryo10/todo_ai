import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_ai/domain/model/subscription_model.dart';
import 'package:todo_ai/domain/services/subscription_service.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionService _subscriptionService;

  SubscriptionBloc({
    required SubscriptionService subscriptionService,
  })  : _subscriptionService = subscriptionService,
        super(SubscriptionInitial()) {
    on<LoadSubscription>(_onLoadSubscription);
    on<PurchaseSubscription>(_onPurchaseSubscription);
    on<CancelSubscription>(_onCancelSubscription);
    on<CheckAiGenerationAvailability>(_onCheckAiGenerationAvailability);
    on<CheckCollaboratorAvailability>(_onCheckCollaboratorAvailability);
    on<UpdateAiUsage>(_onUpdateAiUsage);
  }

  Future<void> _onLoadSubscription(
    LoadSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionLoading());

      final subscription = await _subscriptionService.getUserSubscription(
        event.userId,
      );
      print('loading subsctiption kkkkkk');
      emit(SubscriptionLoaded(subscription: subscription));
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onPurchaseSubscription(
    PurchaseSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionProcessing());

      await _subscriptionService.purchaseSubscription(
        event.userId,
        event.plan,
      );

      // Note: The actual subscription update will happen when the
      // purchase is completed via the InAppPurchase plugin's listener.
      // This is a simplified version.

      emit(SubscriptionPurchaseInitiated());
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onCancelSubscription(
    CancelSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionProcessing());

      await _subscriptionService.cancelSubscription(
        event.userId,
        event.subscriptionId,
      );

      final freeSubscription = await _subscriptionService.getUserSubscription(
        event.userId,
      );

      emit(SubscriptionLoaded(subscription: freeSubscription));
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onCheckAiGenerationAvailability(
    CheckAiGenerationAvailability event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final canUse = await _subscriptionService.canUseAiGeneration(
        event.userId,
      );

      if (state is SubscriptionLoaded) {
        final currentState = state as SubscriptionLoaded;
        emit(
          currentState.copyWith(
            canUseAiGeneration: canUse,
          ),
        );
      } else {
        final subscription = await _subscriptionService.getUserSubscription(
          event.userId,
        );

        emit(
          SubscriptionLoaded(
            subscription: subscription,
            canUseAiGeneration: canUse,
          ),
        );
      }
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onCheckCollaboratorAvailability(
    CheckCollaboratorAvailability event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final canAdd = await _subscriptionService.canAddCollaborator(
        event.userId,
        event.todoId,
        event.currentCollaboratorsCount,
      );

      if (state is SubscriptionLoaded) {
        final currentState = state as SubscriptionLoaded;
        emit(
          currentState.copyWith(
            canAddCollaborator: canAdd,
          ),
        );
      } else {
        final subscription = await _subscriptionService.getUserSubscription(
          event.userId,
        );

        emit(
          SubscriptionLoaded(
            subscription: subscription,
            canAddCollaborator: canAdd,
          ),
        );
      }
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onUpdateAiUsage(
    UpdateAiUsage event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final updatedSubscription =
          await _subscriptionService.updateSubscriptionUsage(
        event.userId,
        decrementGenerations: 1,
      );

      if (state is SubscriptionLoaded) {
        final canUseAiGeneration =
            updatedSubscription.aiTaskGenerationsRemaining > 0;

        emit(
          SubscriptionLoaded(
            subscription: updatedSubscription,
            canUseAiGeneration: canUseAiGeneration,
            canAddCollaborator:
                (state as SubscriptionLoaded).canAddCollaborator,
          ),
        );
      } else {
        emit(
          SubscriptionLoaded(
            subscription: updatedSubscription,
          ),
        );
      }
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }
}
