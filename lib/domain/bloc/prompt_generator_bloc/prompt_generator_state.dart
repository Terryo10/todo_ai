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

  const PromptLoadedState({required this.taskList, required this.topic});

   @override
  List<Object> get props => [taskList];
}

final class PromptErrorState extends PromptGeneratorState {}
