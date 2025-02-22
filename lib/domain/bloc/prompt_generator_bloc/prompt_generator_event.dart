part of 'prompt_generator_bloc.dart';

sealed class PromptGeneratorEvent extends Equatable {
  const PromptGeneratorEvent();

  @override
  List<Object> get props => [];
}

final class GeneratePrompt extends PromptGeneratorEvent {
  final String prompt;

  const GeneratePrompt({required this.prompt});
}
