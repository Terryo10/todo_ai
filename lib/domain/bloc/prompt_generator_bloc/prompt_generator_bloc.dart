import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_ai/domain/bloc/auth_bloc/auth_bloc.dart';
import 'package:todo_ai/domain/model/subscription_model.dart';

import '../../repositories/todo_repository/todo_provider.dart';
import '../subscription_bloc/subscription_bloc.dart';

part 'prompt_generator_event.dart';
part 'prompt_generator_state.dart';

class PromptGeneratorBloc
    extends Bloc<PromptGeneratorEvent, PromptGeneratorState> {
  final TodoProvider todoProvider;
  final SubscriptionBloc subscriptionBloc;
  final AuthBloc _authBloc;
  String? _currentUserId;

  PromptGeneratorBloc(
    this._authBloc, {
    required this.todoProvider,
    required this.subscriptionBloc,
  }) : super(PromptGeneratorInitial()) {
    _initializeUserId();

    on<GeneratePrompt>(
      (event, emit) async {
        try {
          emit(PromptLoadingState());
          print('Starting prompt generation process');

          // Ensure we have a valid user ID
          if (_currentUserId == null || _currentUserId!.isEmpty) {
            print('No user ID found');
            emit(PromptErrorState(message: "User not authenticated"));
            return;
          }

          print('Checking subscription availability for user $_currentUserId');
          // Get the current subscription through our helper method
          final subscription =
              await _checkSubscriptionAvailability(_currentUserId!);

          print(
              'Subscription check result: canUseAi=${subscription.canUseAi}, plan=${subscription.plan}');

          if (subscription.canUseAi) {
            // User can use AI generation, proceed
            print(
                'User can use AI generation, proceeding with Gemini API call');

            List<String> data = await todoProvider.getTasksFromGemini(
              prompt: event.prompt,
            );
            print('Received ${data.length} tasks from Gemini');

            String topic = await todoProvider.getTodoTopicFromGemini(
              prompt: event.prompt,
            );
            print('Generated topic: $topic');

            // Update AI usage to decrement the counter
            print('Updating AI usage for user $_currentUserId');
            subscriptionBloc.add(UpdateAiUsage(userId: _currentUserId!));

            emit(
              PromptLoadedState(
                taskList: data,
                topic: topic,
              ),
            );
            print('Emitted PromptLoadedState');
          } else {
            // User cannot use AI generation
            print('User cannot use AI generation, suggesting upgrade');
            emit(
              PromptSubscriptionRequiredState(
                  plan: _getRequiredPlan(subscription.plan),
                  message:
                      "You've reached your AI generation limit. Upgrade to continue generating tasks."),
            );
            print('Emitted PromptSubscriptionRequiredState');
          }
        } catch (e) {
          print('Error in GeneratePrompt event: $e');
          emit(PromptErrorState(message: e.toString()));
        }
      },
    );
  }

  void _initializeUserId() {
    if (_authBloc.state is AuthAuthenticatedState) {
      _currentUserId = (_authBloc.state as AuthAuthenticatedState).userId;
      print('User ID initialized: $_currentUserId');
    } else {
      print('Auth state is not authenticated: ${_authBloc.state}');
    }

    // Listen for authentication state changes
    _authBloc.stream.listen((state) {
      if (state is AuthAuthenticatedState) {
        _currentUserId = state.userId;
        print('User ID updated: $_currentUserId');
      }
    });
  }

  // A more reliable way to check subscription using streams
  Future<_SubscriptionStatus> _checkSubscriptionAvailability(
      String userId) async {
    try {
      print('checking subscription availability kkk');
      // First, load the subscription to ensure we have fresh data
      subscriptionBloc.add(LoadSubscription(userId: userId));

      // Then check AI generation availability
      subscriptionBloc.add(CheckAiGenerationAvailability(userId: userId));

      // Wait for the subscription state to update
      final subscription = await _waitForSubscriptionState();

      if (subscription.canUseAi && subscription.plan != SubscriptionPlan.free) {
        return _SubscriptionStatus(
          canUseAi: true,
          plan: subscription.plan,
        );
      } else if (subscription.canUseAi &&
          subscription.plan == SubscriptionPlan.free) {
        // For free plan, check if they still have generations left
        return _SubscriptionStatus(
          canUseAi: subscription.generationsRemaining > 0,
          plan: subscription.plan,
        );
      } else {
        return _SubscriptionStatus(
          canUseAi: false,
          plan: subscription.plan,
        );
      }
    } catch (e) {
      print('Error checking subscription: $e');
      return _SubscriptionStatus(canUseAi: false, plan: SubscriptionPlan.free);
    }
  }

  // Wait for subscription state to update and return relevant info
  Future<_SubscriptionInfo> _waitForSubscriptionState() async {
    // Create a completer that will be resolved when we get a SubscriptionLoaded state
    final completer = Completer<_SubscriptionInfo>();

    // Current subscription state
    SubscriptionState currentState = subscriptionBloc.state;

    // If we already have a loaded state, use it
    if (currentState is SubscriptionLoaded) {
      return _SubscriptionInfo(
        plan: currentState.subscription.plan,
        canUseAi: currentState.canUseAiGeneration ?? false,
        generationsRemaining:
            currentState.subscription.aiTaskGenerationsRemaining,
      );
    }

    // Otherwise listen for state changes
    final subscription = subscriptionBloc.stream.listen((state) {
      if (state is SubscriptionLoaded && !completer.isCompleted) {
        completer.complete(_SubscriptionInfo(
          plan: state.subscription.plan,
          canUseAi: state.canUseAiGeneration ?? false,
          generationsRemaining: state.subscription.aiTaskGenerationsRemaining,
        ));
      } else if (state is SubscriptionError && !completer.isCompleted) {
        // Complete with a default value on error
        print('pano lol kkkkk ${state.message}');
        completer.complete(_SubscriptionInfo(
          plan: SubscriptionPlan.free,
          canUseAi: false,
          generationsRemaining: 0,
        ));
      }
    });

    // Set a timeout to prevent waiting forever
    Future.delayed(Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        print('Subscription check timed out');
        completer.complete(_SubscriptionInfo(
          plan: SubscriptionPlan.free,
          canUseAi: false,
          generationsRemaining: 0,
        ));
      }
    });

    // Wait for the completer to resolve
    final result = await completer.future;

    // Clean up the subscription to avoid memory leaks
    subscription.cancel();

    return result;
  }

  SubscriptionPlan _getRequiredPlan(SubscriptionPlan currentPlan) {
    // If free, suggest monthly
    if (currentPlan == SubscriptionPlan.free) {
      return SubscriptionPlan.monthly;
    }

    // If monthly, suggest annual
    if (currentPlan == SubscriptionPlan.monthly) {
      return SubscriptionPlan.annual;
    }

    // Default to monthly
    return SubscriptionPlan.monthly;
  }
}

// Helper classes for subscription state management
class _SubscriptionStatus {
  final bool canUseAi;
  final SubscriptionPlan plan;

  _SubscriptionStatus({required this.canUseAi, required this.plan});
}

class _SubscriptionInfo {
  final SubscriptionPlan plan;
  final bool canUseAi;
  final int generationsRemaining;

  _SubscriptionInfo({
    required this.plan,
    required this.canUseAi,
    required this.generationsRemaining,
  });
}
