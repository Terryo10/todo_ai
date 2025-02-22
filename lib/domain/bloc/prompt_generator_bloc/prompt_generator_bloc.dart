import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/todo_repository/todo_provider.dart';

part 'prompt_generator_event.dart';
part 'prompt_generator_state.dart';

class PromptGeneratorBloc
    extends Bloc<PromptGeneratorEvent, PromptGeneratorState> {
  final TodoProvider todoProvider;
  PromptGeneratorBloc({required this.todoProvider})
      : super(PromptGeneratorInitial()) {
    on<GeneratePrompt>((event, emit) async {
      try {
        emit(PromptLoadingState());
        List<String> data =
            await todoProvider.getTasksFromGemini(prompt: event.prompt);
        emit(PromptLoadedState(taskList: data));
      } catch (e) {
        emit(PromptErrorState());
      }
    });
  }
}
