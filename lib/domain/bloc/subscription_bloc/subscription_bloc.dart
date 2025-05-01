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
    on<PurchasePackage>(_onPurchasePackage);
    on<RestorePurchases>(_onRestorePurchases);
    on<CheckAiGenerationAvailability>(_onCheckAiGenerationAvailability);
    on<CheckCollaboratorAvailability>(_onCheckCollaboratorAvailability);
    on<UpdateAiUsage>(_onUpdateAiUsage);
    on<InitializeRevenueCat>(_onInitializeRevenueCat);
    on<LoadAvailablePackages>(_onLoadAvailablePackages);
  }

  Future<void> _onInitializeRevenueCat(
    InitializeRevenueCat event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      await _subscriptionService.initialize(event.userId);
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
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
      
      emit(SubscriptionLoaded(subscription: subscription));
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onLoadAvailablePackages(
    LoadAvailablePackages event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionLoading());

      final packages = await _subscriptionService.getAvailablePackages();
      
      if (state is SubscriptionLoaded) {
        final currentState = state as SubscriptionLoaded;
        emit(currentState.copyWith(availablePackages: packages));
      } else {
        final subscription = await _subscriptionService.getUserSubscription(
          event.userId,
        );
        emit(SubscriptionLoaded(
          subscription: subscription,
          availablePackages: packages,
        ));
      }
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onPurchasePackage(
    PurchasePackage event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionProcessing());

      final success = await _subscriptionService.purchasePackage(
        event.packageIdentifier,
      );

      if (success) {
        add(LoadSubscription(userId: event.userId));
      } else {
        emit(SubscriptionPurchaseError(message: 'Purchase failed'));
      }
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionProcessing());

      final success = await _subscriptionService.restorePurchases();

      if (success) {
        add(LoadSubscription(userId: event.userId));
      } else {
        emit(SubscriptionPurchaseError(message: 'Restore failed'));
      }
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