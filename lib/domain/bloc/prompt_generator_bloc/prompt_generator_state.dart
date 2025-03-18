part of 'prompt_generator_bloc.dart';

sealed class PromptGeneratorState extends Equatable {
  const PromptGeneratorState();

  @override
  List<Object> get props => [];
}

final class PromptGeneratorInitial extends PromptGeneratorState {}

final class PromptLoadingState extends PromptGeneratorState {}

final class PromptLoadedState extends PromptGeneratorState {
  final List<String> taskList;
  final String topic;

  const PromptLoadedState({
    required this.taskList,
    required this.topic,
  });

  @override
  List<Object> get props => [taskList];
}

class PromptSubscriptionRequiredState extends PromptGeneratorState {
  final SubscriptionPlan plan;
  final String message;

  const PromptSubscriptionRequiredState({
    required this.plan,
    required this.message,
  });

  @override
  List<Object> get props => [plan, message];
}

class PromptErrorState extends PromptGeneratorState {
  final String message;

  const PromptErrorState({this.message = "An error occurred"});

  @override
  List<Object> get props => [message];
}
